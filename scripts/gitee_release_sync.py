#!/usr/bin/env python3
"""Bootstrap and synchronize the public Gitee release mirror.

The Gitee access token is read from ``GITEE_TOKEN`` or Windows Git Credential
Manager. It is never stored in this repository or printed by this script.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import hashlib
import json
import mimetypes
import os
from pathlib import Path
import secrets
import subprocess
import sys
import tempfile
from typing import Iterable
import urllib.error
import urllib.parse
import urllib.request


GITEE_API_BASE = "https://gitee.com/api/v5"
GITHUB_API_BASE = "https://api.github.com"
DEFAULT_GITEE_OWNER = "shan-yujun"
DEFAULT_GITEE_REPO = "Communist-Manifesto-Releases"
DEFAULT_GITHUB_REPO = "Lijinzh/Communist-Manifesto-Releases"
DEFAULT_DESCRIPTION = (
    "AutoClipboard installers, ZKO AI Coding Handle firmware, Skills and documentation. "
    "China-accessible mirror of the GitHub release channel."
)
USER_AGENT = "Communist-Manifesto-Releases-Gitee-Sync/1.0"
DOWNLOAD_CHUNK_BYTES = 1024 * 1024


class ApiError(RuntimeError):
    def __init__(self, status: int, message: str) -> None:
        super().__init__(message)
        self.status = status


@dataclass(frozen=True)
class SyncResult:
    repository: str
    tag: str
    uploaded: tuple[str, ...]
    replaced: tuple[str, ...]
    skipped: tuple[str, ...]
    pruned: tuple[str, ...]


def _credential_token(owner: str) -> str:
    token = os.environ.get("GITEE_TOKEN", "").strip()
    if token:
        return token

    payload = f"protocol=https\nhost=gitee.com\nusername={owner}\n\n"
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    result = subprocess.run(
        ["git", "credential", "fill"],
        input=payload,
        text=True,
        capture_output=True,
        env=env,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(
            "No Gitee token is available in Windows Git Credential Manager. "
            "Run the local Gitee bootstrap first."
        )
    fields = {}
    for line in result.stdout.splitlines():
        key, separator, value = line.partition("=")
        if separator:
            fields[key] = value
    token = fields.get("password", "").strip()
    if not token:
        raise RuntimeError("Windows Git Credential Manager returned no Gitee token.")
    return token


def _optional_github_token() -> str:
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if token:
        return token
    result = subprocess.run(
        ["git", "credential", "fill"],
        input="protocol=https\nhost=github.com\n\n",
        text=True,
        capture_output=True,
        env={**os.environ, "GIT_TERMINAL_PROMPT": "0"},
        check=False,
    )
    if result.returncode != 0:
        return ""
    fields = {}
    for line in result.stdout.splitlines():
        key, separator, value = line.partition("=")
        if separator:
            fields[key] = value
    return fields.get("password", "").strip()


class GiteeClient:
    def __init__(self, token: str) -> None:
        self._token = token

    def request_json(
        self,
        method: str,
        path: str,
        *,
        fields: dict[str, object] | None = None,
        expected: Iterable[int] = (200,),
    ) -> object:
        method = method.upper()
        values = {key: str(value).lower() if isinstance(value, bool) else str(value) for key, value in (fields or {}).items()}
        if method in {"GET", "DELETE"}:
            query = urllib.parse.urlencode({"access_token": self._token, **values})
            url = f"{GITEE_API_BASE}{path}?{query}"
            data = None
        else:
            url = f"{GITEE_API_BASE}{path}"
            data = urllib.parse.urlencode({"access_token": self._token, **values}).encode("utf-8")
        request = urllib.request.Request(
            url,
            data=data,
            method=method,
            headers={"Accept": "application/json", "User-Agent": USER_AGENT},
        )
        return _read_json_response(request, expected)

    def upload(self, path: str, file_path: Path) -> dict[str, object]:
        boundary = f"----gitee-sync-{secrets.token_hex(16)}"
        content_type = mimetypes.guess_type(file_path.name)[0] or "application/octet-stream"
        prefix = (
            f"--{boundary}\r\n"
            'Content-Disposition: form-data; name="access_token"\r\n\r\n'
            f"{self._token}\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="file"; filename="{file_path.name}"\r\n'
            f"Content-Type: {content_type}\r\n\r\n"
        ).encode("utf-8")
        suffix = f"\r\n--{boundary}--\r\n".encode("ascii")
        body = prefix + file_path.read_bytes() + suffix
        request = urllib.request.Request(
            f"{GITEE_API_BASE}{path}",
            data=body,
            method="POST",
            headers={
                "Accept": "application/json",
                "Content-Type": f"multipart/form-data; boundary={boundary}",
                "Content-Length": str(len(body)),
                "User-Agent": USER_AGENT,
            },
        )
        payload = _read_json_response(request, (201,))
        if not isinstance(payload, dict):
            raise RuntimeError("Gitee attachment upload returned an unexpected payload.")
        return payload


def _read_json_response(request: urllib.request.Request, expected: Iterable[int]) -> object:
    expected_set = set(expected)
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            status = int(getattr(response, "status", response.getcode()))
            body = response.read()
    except urllib.error.HTTPError as exc:
        status = exc.code
        body = exc.read()
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Could not reach Gitee: {exc.reason}") from exc
    text = body.decode("utf-8", errors="replace")
    if status not in expected_set:
        message = text[:600]
        try:
            parsed = json.loads(text)
            if isinstance(parsed, dict):
                message = str(parsed.get("message") or parsed.get("error") or message)
        except json.JSONDecodeError:
            pass
        raise ApiError(status, f"Gitee API request failed with HTTP {status}: {message}")
    if not text.strip():
        return {}
    try:
        return json.loads(text)
    except json.JSONDecodeError as exc:
        raise RuntimeError("Gitee API returned non-JSON data.") from exc


def _github_json(path: str) -> object:
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": USER_AGENT,
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = _optional_github_token()
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(
        f"{GITHUB_API_BASE}{path}",
        headers=headers,
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Could not read the GitHub release: {exc.reason}") from exc


def ensure_repository(client: GiteeClient, owner: str, repo: str) -> dict[str, object]:
    path = f"/repos/{urllib.parse.quote(owner)}/{urllib.parse.quote(repo)}"
    try:
        payload = client.request_json("GET", path)
    except ApiError as exc:
        if exc.status != 404:
            raise
        payload = client.request_json(
            "POST",
            "/user/repos",
            fields={
                "name": repo,
                "path": repo,
                "description": DEFAULT_DESCRIPTION,
                "homepage": "https://github.com/Lijinzh/Communist-Manifesto-Releases",
                "public": True,
                "auto_init": False,
                "has_issues": False,
                "has_wiki": False,
                "can_comment": False,
            },
            expected=(201,),
        )
    if not isinstance(payload, dict):
        raise RuntimeError("Gitee repository bootstrap returned an unexpected payload.")
    return payload


def make_repository_public(client: GiteeClient, owner: str, repo: str) -> dict[str, object]:
    payload = client.request_json(
        "PATCH",
        f"/repos/{urllib.parse.quote(owner)}/{urllib.parse.quote(repo)}",
        fields={
            "name": repo,
            "private": False,
            "description": DEFAULT_DESCRIPTION,
            "homepage": "https://github.com/Lijinzh/Communist-Manifesto-Releases",
            "has_issues": False,
            "has_wiki": False,
            "can_comment": False,
        },
    )
    if not isinstance(payload, dict):
        raise RuntimeError("Gitee repository visibility update returned an unexpected payload.")
    if payload.get("private") is not False:
        raise RuntimeError("The Gitee release mirror could not be made public.")
    return payload


def ensure_ssh_key(client: GiteeClient, public_key_path: Path) -> dict[str, object]:
    public_key = public_key_path.read_text(encoding="utf-8").strip()
    keys = client.request_json("GET", "/user/keys", fields={"per_page": 100})
    if not isinstance(keys, list):
        raise RuntimeError("Gitee SSH key listing returned an unexpected payload.")
    for item in keys:
        if isinstance(item, dict) and str(item.get("key") or "").strip() == public_key:
            return item
    payload = client.request_json(
        "POST",
        "/user/keys",
        fields={"title": "Codex Windows Release Publisher", "key": public_key},
        expected=(201,),
    )
    if not isinstance(payload, dict):
        raise RuntimeError("Gitee SSH key creation returned an unexpected payload.")
    return payload


def _release_by_tag(client: GiteeClient, owner: str, repo: str, tag: str) -> dict[str, object] | None:
    path = (
        f"/repos/{urllib.parse.quote(owner)}/{urllib.parse.quote(repo)}"
        f"/releases/tags/{urllib.parse.quote(tag)}"
    )
    try:
        payload = client.request_json("GET", path)
    except ApiError as exc:
        if exc.status == 404:
            return None
        raise
    if payload is None:
        return None
    if not isinstance(payload, dict):
        raise RuntimeError("Gitee release lookup returned an unexpected payload.")
    return payload


def _ensure_release(
    client: GiteeClient,
    owner: str,
    repo: str,
    github_release: dict[str, object],
) -> dict[str, object]:
    tag = str(github_release.get("tag_name") or "").strip()
    if not tag:
        raise RuntimeError("GitHub latest release has no tag name.")
    existing = _release_by_tag(client, owner, repo, tag)
    fields = {
        "tag_name": tag,
        "name": str(github_release.get("name") or tag),
        "body": str(github_release.get("body") or ""),
        "prerelease": bool(github_release.get("prerelease")),
        "target_commitish": str(github_release.get("target_commitish") or "main"),
    }
    base = f"/repos/{urllib.parse.quote(owner)}/{urllib.parse.quote(repo)}/releases"
    if existing is None:
        payload = client.request_json("POST", base, fields=fields, expected=(201,))
    else:
        release_id = int(existing["id"])
        payload = client.request_json("PATCH", f"{base}/{release_id}", fields=fields)
    if not isinstance(payload, dict):
        raise RuntimeError("Gitee release creation returned an unexpected payload.")
    return payload


def _download_asset(asset: dict[str, object], destination: Path) -> str:
    name = str(asset.get("name") or "")
    url = str(asset.get("browser_download_url") or "")
    expected_size = int(asset.get("size") or 0)
    if not name or Path(name).name != name or not url or expected_size <= 0:
        raise RuntimeError("GitHub release asset metadata is incomplete.")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    digest = hashlib.sha256()
    total = 0
    try:
        with urllib.request.urlopen(request, timeout=300) as response, destination.open("wb") as output:
            while True:
                chunk = response.read(DOWNLOAD_CHUNK_BYTES)
                if not chunk:
                    break
                output.write(chunk)
                digest.update(chunk)
                total += len(chunk)
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Could not download GitHub asset {name}: {exc.reason}") from exc
    if total != expected_size:
        raise RuntimeError(f"GitHub asset {name} size mismatch: expected {expected_size}, got {total}.")
    return digest.hexdigest()


def sync_latest_release(
    client: GiteeClient,
    owner: str,
    repo: str,
    github_repo: str,
    *,
    replace_existing: bool,
    prune: bool,
) -> SyncResult:
    github_payload = _github_json(f"/repos/{github_repo}/releases/latest")
    if not isinstance(github_payload, dict):
        raise RuntimeError("GitHub latest release returned an unexpected payload.")
    assets = github_payload.get("assets")
    if not isinstance(assets, list) or not assets:
        raise RuntimeError("GitHub latest release contains no assets.")

    release = _ensure_release(client, owner, repo, github_payload)
    release_id = int(release["id"])
    attachments_path = (
        f"/repos/{urllib.parse.quote(owner)}/{urllib.parse.quote(repo)}"
        f"/releases/{release_id}/attach_files"
    )
    existing_payload = client.request_json("GET", attachments_path, fields={"per_page": 100})
    if not isinstance(existing_payload, list):
        raise RuntimeError("Gitee release attachment listing returned an unexpected payload.")
    existing = {
        str(item.get("name") or ""): item
        for item in existing_payload
        if isinstance(item, dict) and item.get("name")
    }

    uploaded: list[str] = []
    replaced: list[str] = []
    skipped: list[str] = []
    github_names: set[str] = set()
    with tempfile.TemporaryDirectory(prefix="gitee-release-sync-") as temporary:
        temp_root = Path(temporary)
        for asset in assets:
            if not isinstance(asset, dict):
                continue
            name = str(asset.get("name") or "")
            github_names.add(name)
            remote = existing.get(name)
            same_size = remote is not None and int(remote.get("size") or 0) == int(asset.get("size") or 0)
            if remote is not None and same_size and not replace_existing:
                skipped.append(name)
                continue
            if remote is not None:
                client.request_json(
                    "DELETE",
                    f"{attachments_path}/{int(remote['id'])}",
                    expected=(204,),
                )
                replaced.append(name)
            local_path = temp_root / name
            _download_asset(asset, local_path)
            uploaded_asset = client.upload(attachments_path, local_path)
            if str(uploaded_asset.get("name") or "") != name:
                raise RuntimeError(f"Gitee uploaded attachment name mismatch for {name}.")
            if int(uploaded_asset.get("size") or 0) != local_path.stat().st_size:
                raise RuntimeError(f"Gitee uploaded attachment size mismatch for {name}.")
            uploaded.append(name)

    pruned: list[str] = []
    if prune:
        for name, remote in existing.items():
            if name in github_names:
                continue
            client.request_json(
                "DELETE",
                f"{attachments_path}/{int(remote['id'])}",
                expected=(204,),
            )
            pruned.append(name)

    return SyncResult(
        repository=f"{owner}/{repo}",
        tag=str(github_payload.get("tag_name") or ""),
        uploaded=tuple(uploaded),
        replaced=tuple(replaced),
        skipped=tuple(skipped),
        pruned=tuple(pruned),
    )


def verify_public_mirror(owner: str, repo: str) -> dict[str, object]:
    release = _public_json(f"/repos/{owner}/{repo}/releases/latest")
    if not isinstance(release, dict):
        raise RuntimeError("Gitee public latest release returned an unexpected payload.")
    release_id = int(release["id"])
    attachments = _public_json(f"/repos/{owner}/{repo}/releases/{release_id}/attach_files?per_page=100")
    if not isinstance(attachments, list) or not attachments:
        raise RuntimeError("Gitee public latest release contains no downloadable attachments.")
    return {
        "repository": f"https://gitee.com/{owner}/{repo}",
        "tag": str(release.get("tag_name") or ""),
        "assets": [
            {
                "name": str(item.get("name") or ""),
                "size": int(item.get("size") or 0),
                "download_url": str(item.get("browser_download_url") or ""),
            }
            for item in attachments
            if isinstance(item, dict)
        ],
    }


def _public_json(path: str) -> object:
    request = urllib.request.Request(
        f"{GITEE_API_BASE}{path}",
        headers={"Accept": "application/json", "User-Agent": USER_AGENT},
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Could not verify the public Gitee mirror: {exc.reason}") from exc


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--owner", default=DEFAULT_GITEE_OWNER)
    parser.add_argument("--repo", default=DEFAULT_GITEE_REPO)
    parser.add_argument("--github-repo", default=DEFAULT_GITHUB_REPO)
    subparsers = parser.add_subparsers(dest="command", required=True)

    bootstrap = subparsers.add_parser("bootstrap", help="Create the public repository and register this PC's SSH key.")
    bootstrap.add_argument("--ssh-public-key", type=Path, required=True)

    sync = subparsers.add_parser("sync-latest", help="Mirror the latest GitHub Release and all of its assets.")
    sync.add_argument("--replace-existing", action="store_true")
    sync.add_argument("--prune", action="store_true")

    subparsers.add_parser("make-public", help="Make the populated Gitee mirror publicly readable.")
    subparsers.add_parser("verify", help="Verify anonymous public access to the Gitee mirror.")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.command == "verify":
        print(json.dumps(verify_public_mirror(args.owner, args.repo), ensure_ascii=False, indent=2))
        return 0

    client = GiteeClient(_credential_token(args.owner))
    if args.command == "bootstrap":
        repository = ensure_repository(client, args.owner, args.repo)
        ssh_key = ensure_ssh_key(client, args.ssh_public_key)
        print(
            json.dumps(
                {
                    "repository": repository.get("html_url"),
                    "ssh_url": repository.get("ssh_url"),
                    "ssh_key_id": ssh_key.get("id"),
                    "status": "ready",
                },
                ensure_ascii=False,
                indent=2,
            )
        )
        return 0
    if args.command == "sync-latest":
        result = sync_latest_release(
            client,
            args.owner,
            args.repo,
            args.github_repo,
            replace_existing=args.replace_existing,
            prune=args.prune,
        )
        print(json.dumps(result.__dict__, ensure_ascii=False, indent=2))
        return 0
    if args.command == "make-public":
        repository = make_repository_public(client, args.owner, args.repo)
        print(
            json.dumps(
                {"repository": repository.get("html_url"), "public": True, "status": "ready"},
                ensure_ascii=False,
                indent=2,
            )
        )
        return 0
    raise RuntimeError(f"Unsupported command: {args.command}")


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ApiError, OSError, RuntimeError, ValueError) as exc:
        print(f"Gitee synchronization failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
