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
2. A private `gitee.com` token in Windows Git Credential Manager for repository administration, Release creation, and asset uploads.

Never store the private token in the repository, scripts, `.env`, or Git remote URLs. The synchronization script reads a temporary `GITEE_TOKEN` first and otherwise uses `git credential fill` to read Windows Credential Manager.

<!-- section:s003 -->
## Routine synchronization

After the GitHub Release is complete, run this command from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1
```

The script performs these steps:

1. Checks the paired Chinese and English documentation trees.
2. Pushes `main` to GitHub.
3. Pushes `main` and all tags to Gitee.
4. Reads the latest GitHub Release.
5. Creates or updates the matching Gitee Release and synchronizes the exact asset set.
6. Anonymously verifies branch and tag references, Release tag, asset names, asset sizes, and public asset reads.

Historical Gitee Releases are never deleted. Exact-set cleanup applies only to extra assets on the current latest Gitee Release.

<!-- section:s004 -->
## Standalone verification

```powershell
uv run --no-project python scripts\gitee_release_sync.py verify
```

This command does not need a private token. It verifies that GitHub and Gitee are identical for `main`, tags, the latest Release, and the latest Release asset metadata, and that every Gitee asset can be read anonymously.
