# Communist Manifesto Releases

This public repository is the release channel for **AutoClipboard** and **CommunistManifestoKB**.

The main development repository remains private. This repository only hosts compiled release assets, user-facing release notes, and update instructions.

## Download

Open the latest GitHub Release and download the asset for your platform:

- Windows: `AutoClipboardSetup-<version>.exe`
- Linux / Ubuntu: `auto-clipboard_<version>_<arch>.deb`
- macOS: `AutoClipboard-<version>-macOS.dmg`
- ESP32 firmware: `CommunistManifestoKB-firmware-d4-<version>.zip` or `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI agent Skill: `ai-coding-handle-skill-<version>.zip`

## Auto Update

AutoClipboard checks the latest Release in this repository.

- Software update picks the installer matching the current operating system.
- Firmware update picks the `CommunistManifestoKB-firmware-<version>.zip` asset and flashes `firmware.bin` at `0x10000` by default, preserving NVS settings and custom icons.

## Agent Status Monitor

AutoClipboard can watch Codex / Claude Code work states and sync them to the handle light ring and screen notifications.

- Chinese setup guide: [`docs/agent-signal-setup.md`](docs/agent-signal-setup.md)
- Linux one-click helper: [`scripts/configure-agent-signal-linux.sh`](scripts/configure-agent-signal-linux.sh)
- Windows one-click helper: [`scripts/configure-agent-signal-windows.ps1`](scripts/configure-agent-signal-windows.ps1)

After setup, keep AutoClipboard running in the background. Codex / Claude hooks write local state files, and AutoClipboard relays the aggregated state to the paired handle over BLE.

## Install the AI Coding Handle Skill

The open-source Skill is available at [`skills/ai-coding-handle`](skills/ai-coding-handle). It can install the matching AutoClipboard release and configure supported agent status hooks after the user grants permission.

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

## Notes

This repository contains only the MIT-licensed AI Coding Handle Skill source and public release support files. AutoClipboard and firmware application source code remain private; use the Release page for compiled downloads.
