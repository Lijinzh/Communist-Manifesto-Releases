<!-- section:s001 -->
# GitHub Primary Releases and the Gitee China Mirror

This repository uses the following release relationship:

- GitHub is the official primary release source.
- Gitee mirrors `main`, Git tags, and every asset in the latest Release as a China-accessible fallback.
- Release assets from before the Gitee mirror was enabled are not backfilled in bulk. Every release synchronized after mirror activation remains available.
- AutoClipboard should try GitHub first and fall back to Gitee only when GitHub metadata or asset downloads fail.

Public Gitee repository: <https://gitee.com/shan-yujun/Communist-Manifesto-Releases>

<!-- section:s002 -->
## Local credentials

The Windows release machine uses two independent credentials:

1. `C:\Users\admin\.ssh\id_ed25519_gitee_release` for Git code and tag pushes only.
2. A private `gitee.com` token in Windows Git Credential Manager for repository administration, Release creation, and asset uploads. Routine Release synchronization enables only Gitee's mandatory `user_info` scope and the `projects` scope required for repository operations, preferably with a 30-day expiry.

Never store the private token in the repository, scripts, `.env`, or Git remote URLs. The synchronization script reads a temporary `GITEE_TOKEN` first and otherwise uses `git credential fill` to read Windows Credential Manager.

<!-- section:s003 -->
## Routine synchronization

After the GitHub Release is complete, run this command from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1
```

Use the system's direct connection first. Only after a direct timeout or failure, temporarily set `HTTP_PROXY` and `HTTPS_PROXY` to `http://127.0.0.1:7897`, retry, and clear the variables afterward. If `main` and all tags are already synchronized, add `-SkipCodePush` to synchronize only Release assets and run anonymous verification.

The script performs these steps:

1. Checks the paired Chinese and English documentation trees.
2. Pushes `main` to GitHub.
3. Pushes `main` and all tags to Gitee.
4. Reads the latest GitHub Release.
5. Creates or updates the matching Gitee Release and synchronizes the exact asset set.
6. Anonymously verifies branch and tag references, Release tag, asset names, asset sizes, and public asset reads.

The routine synchronizer never deletes historical Gitee Releases or attachments. Exact-set cleanup applies only to extra assets on the current latest Gitee Release. Existing same-name, same-size assets are skipped safely, so an interrupted quota or network run can be resumed.

If a same-name, same-size GitHub asset was deliberately replaced and must be uploaded again, run the command with `-ReplaceExistingAssets`.

<!-- section:s004 -->
## Standalone verification

```powershell
uv run --no-project python scripts\gitee_release_sync.py verify
```

This command does not need a private token. It verifies that GitHub and Gitee are identical for `main`, tags, the latest Release, and the latest Release asset metadata, and that every Gitee asset can be read anonymously.

<!-- section:s005 -->
## Attachment storage preflight and quota failures

Run the anonymous storage report before and after formal synchronization:

```powershell
uv run --no-project python scripts\gitee_release_sync.py storage
```

This command does not read a private token. It lists Gitee Release IDs, tags, attachment names, per-release byte totals, and total repository usage. Before uploading, the release coordinator should add the current usage to the total size of the six GitHub assets so that a 1 GiB quota failure is detected before a partial upload.

Historical Gitee Releases remain preserved by default. If the quota still blocks the formal latest version, stop synchronization and report the exact proposed targets and bytes that would be freed. Historical cleanup is allowed only as an exception after the repository owner explicitly confirms the current targets. The matching GitHub Releases and Git tags on both remotes must remain intact, and the Release IDs, tags, freed bytes, recovery source, and confirmation must be recorded in the version verification record. The synchronization script never performs this historical cleanup automatically.
