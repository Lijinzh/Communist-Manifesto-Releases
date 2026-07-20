<!-- Generated from docs/README.bilingual.md by scripts/sync_readmes.py. Do not edit directly. -->

**English** | [简体中文](README.zh-CN.md)

# Communist Manifesto Releases

This public repository is the release channel for **AutoClipboard** and **CommunistManifestoKB**.

The main development repository remains private. This repository only hosts compiled release assets, user-facing release notes, update instructions, and the open-source AI Coding Handle Skill.

## Download

Open the [latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest) and download the asset for your platform:

- Windows: `AutoClipboardSetup-<version>.exe`
- Windows CH343 USB serial driver: `CH343SER.EXE`
- Linux / Ubuntu: `auto-clipboard_<version>_<arch>.deb`
- macOS: `AutoClipboard-<version>-macOS.dmg`
- ESP32 firmware: `CommunistManifestoKB-firmware-d4-<version>.zip` or `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI agent Skill: `ai-coding-handle-skill-<version>.zip`

Choose the D4 or V3 firmware package that matches your physical board. Do not flash a package intended for another board revision.

## AutoClipboard 0.3.49 Highlights

- The handle status screen now shows a notification-style badge for the number of currently working Agents. The badge disappears when the count is zero.
- Bluetooth host management is now available directly under `Settings > BLE Hosts`: view the saved-host count, switch among three slots, pair an empty slot, or long-press a saved slot to delete it.
- Removed the mechanically impossible “hold the wheel button while rotating” host-switch gesture and updated the in-app bilingual pairing guide.
- Improved Windows BLE reconnection and ownership behavior so closing AutoClipboard does not tear down the HID keyboard link, while reopening the app can recover the IMU preview more quickly.
- Includes the latest V3 IMU preview, Halo presenter, adaptive settings-window, and firmware stability fixes.

Download the matching installer and firmware from the [v0.3.49 Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/tag/v0.3.49).

## Windows CH343 Serial Driver

If Windows does not create a COM port after the handle is connected over USB Type-C, download the signed [CH343SER.EXE](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/download/v0.3.48/CH343SER.EXE) driver supplied by WCH. Follow the [English installation and troubleshooting guide](docs/ch343-driver-installation.md) or the [简体中文指南](docs/ch343-driver-installation.zh-CN.md).

The repository file is Authenticode-signed by `Nanjing Qinheng Microelectronics Co., Ltd.` and has SHA-256 `99f16f9c4cf9c315dc9a17b29021d82d522014ecc053d9ee1c7b38c214dea40b`.

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

The repository Skill and the versioned ZIP are generated from the same canonical source. The Skill can use the installed AutoClipboard Maintenance CLI to identify a connected D4/V3 handle, check published firmware versions, validate the matching package, and update the firmware only after a separate explicit confirmation. Local development-firmware flashing is available only when the Skill is running inside the Communist-Manifesto source repository and the user explicitly requests it.

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

The private release workflow also extracts the exact versioned Skill ZIP into this repository's `skills/ai-coding-handle` directory. Repository-based installation and manual ZIP installation therefore receive the same files for each published version.

## Notes

This repository contains only the MIT-licensed AI Coding Handle Skill source and public release support files. AutoClipboard and firmware application source code remain private; use the Release page for compiled downloads.
