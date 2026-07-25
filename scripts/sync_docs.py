#!/usr/bin/env python3
"""Generate compatibility pages and validate mirrored documentation trees."""

from __future__ import annotations

import argparse
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SECTION_PATTERN = re.compile(r"<!--\s*section:(?P<name>[a-z0-9-]+)\s*-->")
MARKDOWN_LINK_PATTERN = re.compile(r"!?\[[^\]]*\]\((?P<target>[^)]+)\)")
HTML_LINK_PATTERN = re.compile(
    r'<(?:a|img)\b[^>]*(?:href|src)="(?P<target>[^"]+)"',
    re.IGNORECASE,
)


@dataclass(frozen=True)
class Redirect:
    path: str
    language: str
    target: str
    title: str
    secondary_target: str | None = None
    secondary_title: str | None = None


REDIRECTS = (
    Redirect("docs/user-guide.zh-CN.md", "zh-CN", "zh-CN/user-guide.md", "完整中文使用指南"),
    Redirect("docs/user-guide.en.md", "en", "en/user-guide.md", "complete English user guide"),
    Redirect(
        "docs/user-guide.bilingual.md",
        "bilingual",
        "zh-CN/user-guide.md",
        "完整使用指南",
        "en/user-guide.md",
        "complete user guide",
    ),
    Redirect(
        "docs/software-interface-manual/README.md",
        "zh-CN",
        "../zh-CN/software-interface-manual.md",
        "AutoClipboard 软件界面详细说明书",
    ),
    Redirect(
        "docs/software-interface-manual/README.en.md",
        "en",
        "../en/software-interface-manual.md",
        "AutoClipboard software interface manual",
    ),
    Redirect(
        "docs/software-interface-manual/README.bilingual.md",
        "bilingual",
        "../zh-CN/software-interface-manual.md",
        "AutoClipboard 软件界面详细说明书",
        "../en/software-interface-manual.md",
        "AutoClipboard software interface manual",
    ),
    Redirect(
        "docs/agent-signal-setup.md",
        "zh-CN",
        "zh-CN/agent-signal-setup.md",
        "Agent 状态监测配置指南",
    ),
    Redirect(
        "docs/ch343-driver-installation.zh-CN.md",
        "zh-CN",
        "zh-CN/ch343-driver-installation.md",
        "CH343 Windows 串口驱动安装指南",
    ),
    Redirect(
        "docs/ch343-driver-installation.md",
        "en",
        "en/ch343-driver-installation.md",
        "CH343 Windows serial driver installation guide",
    ),
    Redirect(
        "docs/gitee-publishing.md",
        "zh-CN",
        "zh-CN/maintainers/gitee-publishing.md",
        "GitHub 与 Gitee 发布维护指南",
    ),
    Redirect(
        "docs/README.bilingual.md",
        "bilingual",
        "../README.md",
        "中文项目主页",
        "../README.en.md",
        "English project home",
    ),
)


def markdown_paths(root: Path) -> set[Path]:
    if not root.exists():
        return set()
    return {path.relative_to(root) for path in root.rglob("*.md") if path.is_file()}


def section_ids(path: Path) -> tuple[str, ...]:
    return tuple(
        match.group("name")
        for match in SECTION_PATTERN.finditer(path.read_text(encoding="utf-8"))
    )


def render_redirect(language: str, target: str, title: str) -> str:
    notice = "<!-- Generated compatibility page. Do not edit directly. -->"
    if language == "zh-CN":
        return f"{notice}\n\n# 文档已迁移\n\n请阅读[{title}]({target})。\n"
    if language == "en":
        return f"{notice}\n\n# Document moved\n\nRead [{title}]({target}).\n"
    raise ValueError(f"unsupported language: {language}")


def _render_redirect_spec(redirect: Redirect) -> str:
    if redirect.language != "bilingual":
        return render_redirect(redirect.language, redirect.target, redirect.title)
    if redirect.secondary_target is None or redirect.secondary_title is None:
        raise ValueError(f"bilingual redirect is incomplete: {redirect.path}")
    return (
        "<!-- Generated compatibility page. Do not edit directly. -->\n\n"
        "# 文档已迁移 / Document moved\n\n"
        f"- [简体中文：{redirect.title}]({redirect.target})\n"
        f"- [English: {redirect.secondary_title}]({redirect.secondary_target})\n"
    )


def sync_redirects(root: Path, redirects: Iterable[Redirect], *, check: bool) -> list[Path]:
    stale: list[Path] = []
    for redirect in redirects:
        relative = Path(redirect.path)
        destination = root / relative
        expected = _render_redirect_spec(redirect)
        actual = destination.read_text(encoding="utf-8") if destination.exists() else None
        if actual == expected:
            continue
        if check:
            stale.append(relative)
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(expected, encoding="utf-8", newline="\n")
    return stale


def validate_pair_trees(left: Path, right: Path) -> list[str]:
    failures: list[str] = []
    left_paths = markdown_paths(left)
    right_paths = markdown_paths(right)
    for relative in sorted(left_paths - right_paths):
        failures.append(f"missing in {right.name}: {relative.as_posix()}")
    for relative in sorted(right_paths - left_paths):
        failures.append(f"missing in {left.name}: {relative.as_posix()}")
    for relative in sorted(left_paths & right_paths):
        left_ids = section_ids(left / relative)
        right_ids = section_ids(right / relative)
        if left_ids != right_ids:
            failures.append(
                f"section IDs differ for {relative.as_posix()}: "
                f"{left.name}={left_ids}, {right.name}={right_ids}"
            )
    return failures


def _link_targets(content: str) -> list[str]:
    targets = [match.group("target") for match in MARKDOWN_LINK_PATTERN.finditer(content)]
    targets.extend(match.group("target") for match in HTML_LINK_PATTERN.finditer(content))
    return targets


def validate_local_links(paths: Iterable[Path]) -> list[str]:
    failures: list[str] = []
    for path in paths:
        content = path.read_text(encoding="utf-8")
        for raw_target in _link_targets(content):
            target = raw_target.strip()
            if target.startswith("<") and target.endswith(">"):
                target = target[1:-1]
            if (
                not target
                or target.startswith("#")
                or re.match(r"^[a-z][a-z0-9+.-]*://", target, re.IGNORECASE)
            ):
                continue
            local_part = target.split("#", 1)[0].split("?", 1)[0]
            if local_part and not (path.parent / local_part).resolve().exists():
                failures.append(f"{path} -> {target}")
    return failures


def sync(check: bool) -> int:
    failures: list[str] = []
    stale = sync_redirects(ROOT, REDIRECTS, check=check)
    failures.extend(f"stale compatibility page: {path.as_posix()}" for path in stale)
    failures.extend(validate_pair_trees(ROOT / "docs" / "zh-CN", ROOT / "docs" / "en"))
    failures.extend(
        validate_pair_trees(
            ROOT / "skills" / "ai-coding-handle" / "references" / "zh-CN",
            ROOT / "skills" / "ai-coding-handle" / "references" / "en",
        )
    )
    canonical_paths = sorted((ROOT / "docs" / "zh-CN").rglob("*.md"))
    canonical_paths.extend(sorted((ROOT / "docs" / "en").rglob("*.md")))
    canonical_paths.extend(
        ROOT / redirect.path for redirect in REDIRECTS if (ROOT / redirect.path).exists()
    )
    failures.extend(validate_local_links(canonical_paths))
    if failures:
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    if check:
        print("Bilingual documentation trees and compatibility pages are current.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    return sync(args.check)


if __name__ == "__main__":
    raise SystemExit(main())
