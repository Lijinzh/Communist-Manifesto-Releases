<!-- Generated from docs/README.bilingual.md by scripts/sync_readmes.py. Do not edit directly. -->

**English** | [简体中文](README.zh-CN.md)

# Communist Manifesto Releases

This public repository is the release channel for **AutoClipboard** and **CommunistManifestoKB**.

The main development repository remains private. This repository only hosts compiled release assets, user-facing release notes, update instructions, and the open-source AI Coding Handle Skill.

## Download

Open the [latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest) and download the asset for your platform:

- Windows: `AutoClipboardSetup-<version>.exe`
- Linux / Ubuntu: `auto-clipboard_<version>_<arch>.deb`
- macOS: `AutoClipboard-<version>-macOS.dmg`
- ESP32 firmware: `CommunistManifestoKB-firmware-d4-<version>.zip` or `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI agent Skill: `ai-coding-handle-skill-<version>.zip`

Choose the D4 or V3 firmware package that matches your physical board. Do not flash a package intended for another board revision.

## Auto Update

AutoClipboard checks the latest Release in this repository.

- Software update selects the installer matching the current operating system.
- Firmware update selects the D4 or V3 package matching the connected board and flashes `firmware.bin` at `0x10000` by default, preserving NVS settings and custom icons.

## Agent Status Monitor

AutoClipboard can watch Codex / Claude Code work states and sync them to the handle light ring and screen notifications.

- Setup guide: [`docs/agent-signal-setup.md`](docs/agent-signal-setup.md)
- Linux one-click helper: [`scripts/configure-agent-signal-linux.sh`](scripts/configure-agent-signal-linux.sh)
- Windows one-click helper: [`scripts/configure-agent-signal-windows.ps1`](scripts/configure-agent-signal-windows.ps1)

After setup, keep AutoClipboard running in the background. Codex / Claude hooks write local state files, and AutoClipboard relays the aggregated state to the paired handle over BLE.

## Install the AI Coding Handle Skill

The open-source Skill is available at [`skills/ai-coding-handle`](skills/ai-coding-handle). After the user grants permission, it can install the matching AutoClipboard release and configure supported agent status hooks.

Install it for Codex, Claude Code, OpenCode, or another supported Agent Skills client with the cross-agent installer:

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --skill ai-coding-handle -g
```

List the detected Skill before installing:

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --list
```

The same versioned Skill is also attached to every GitHub Release as a ZIP for manual installation.

## Maintainer Upload

The private development repository can publish here automatically when a matching version tag is pushed:

```powershell
git tag v0.3.29
git push origin main
git push origin v0.3.29
```

The GitHub Actions workflow in the private repository builds all release assets and uploads them to this public repository.

If a Windows installer was built manually, upload it from the private repository's `AutoClipboard` directory:

```powershell
gh release upload v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --clobber
```

If the Release does not exist yet:

```powershell
gh release create v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --title "AutoClipboard 0.3.29" --notes "AutoClipboard 0.3.29"
```

Windows machines need GitHub CLI authentication first:

```powershell
winget install --id GitHub.cli
gh auth login
```

## Keeping Both Languages in Sync

`README.md` and `README.zh-CN.md` are generated from [`docs/README.bilingual.md`](docs/README.bilingual.md). Update both language blocks in that source file, then run:

```bash
python scripts/sync_readmes.py
```

GitHub Actions runs `python scripts/sync_readmes.py --check` on every relevant change. The check fails if a translation block is missing or either generated README is stale.

## Notes

This repository contains only the MIT-licensed AI Coding Handle Skill source and public release support files. AutoClipboard and firmware application source code remain private; use the Release page for compiled downloads.
