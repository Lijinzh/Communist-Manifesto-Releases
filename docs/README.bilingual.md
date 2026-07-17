<!--
This is the source of truth for README.md and README.zh-CN.md.
Keep both language blocks in every section, then run:

    python scripts/sync_readmes.py

Do not edit the generated README files directly.
-->

<!-- section:intro -->
<!-- lang:en -->
# Communist Manifesto Releases

This public repository is the release channel for **AutoClipboard** and **CommunistManifestoKB**.

The main development repository remains private. This repository only hosts compiled release assets, user-facing release notes, update instructions, and the open-source AI Coding Handle Skill.
<!-- lang:zh-CN -->
# Communist Manifesto 发布仓库

本公开仓库是 **AutoClipboard** 和 **CommunistManifestoKB** 的正式发布渠道。

主开发仓库仍为私有仓库。本仓库只提供编译后的发布文件、面向用户的发布说明、更新指南，以及开源的 AI Coding Handle Skill。
<!-- endsection -->

<!-- section:download -->
<!-- lang:en -->
## Download

Open the [latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest) and download the asset for your platform:

- Windows: `AutoClipboardSetup-<version>.exe`
- Linux / Ubuntu: `auto-clipboard_<version>_<arch>.deb`
- macOS: `AutoClipboard-<version>-macOS.dmg`
- ESP32 firmware: `CommunistManifestoKB-firmware-d4-<version>.zip` or `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI agent Skill: `ai-coding-handle-skill-<version>.zip`

Choose the D4 or V3 firmware package that matches your physical board. Do not flash a package intended for another board revision.
<!-- lang:zh-CN -->
## 下载

打开[最新 GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)，然后下载与你的平台对应的文件：

- Windows：`AutoClipboardSetup-<version>.exe`
- Linux / Ubuntu：`auto-clipboard_<version>_<arch>.deb`
- macOS：`AutoClipboard-<version>-macOS.dmg`
- ESP32 固件：`CommunistManifestoKB-firmware-d4-<version>.zip` 或 `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI Agent Skill：`ai-coding-handle-skill-<version>.zip`

请根据手中实体设备的板型选择 D4 或 V3 固件包，不要跨板型刷写。
<!-- endsection -->

<!-- section:auto-update -->
<!-- lang:en -->
## Auto Update

AutoClipboard checks the latest Release in this repository.

- Software update selects the installer matching the current operating system.
- Firmware update selects the D4 or V3 package matching the connected board and flashes `firmware.bin` at `0x10000` by default, preserving NVS settings and custom icons.
<!-- lang:zh-CN -->
## 自动更新

AutoClipboard 会检查本仓库中的最新 Release。

- 软件更新会自动选择与当前操作系统匹配的安装包。
- 固件更新会根据已连接设备选择匹配的 D4 或 V3 固件包，默认把 `firmware.bin` 写入 `0x10000`，并保留 NVS 设置和自定义图标。
<!-- endsection -->

<!-- section:agent-status-monitor -->
<!-- lang:en -->
## Agent Status Monitor

AutoClipboard can watch Codex / Claude Code work states and sync them to the handle light ring and screen notifications.

- Setup guide: [`docs/agent-signal-setup.md`](docs/agent-signal-setup.md)
- Linux one-click helper: [`scripts/configure-agent-signal-linux.sh`](scripts/configure-agent-signal-linux.sh)
- Windows one-click helper: [`scripts/configure-agent-signal-windows.ps1`](scripts/configure-agent-signal-windows.ps1)

After setup, keep AutoClipboard running in the background. Codex / Claude hooks write local state files, and AutoClipboard relays the aggregated state to the paired handle over BLE.
<!-- lang:zh-CN -->
## Agent 状态监控

AutoClipboard 可以监控 Codex / Claude Code 的工作状态，并把状态同步到手柄灯环和屏幕通知。

- 配置指南：[`docs/agent-signal-setup.md`](docs/agent-signal-setup.md)
- Linux 一键配置脚本：[`scripts/configure-agent-signal-linux.sh`](scripts/configure-agent-signal-linux.sh)
- Windows 一键配置脚本：[`scripts/configure-agent-signal-windows.ps1`](scripts/configure-agent-signal-windows.ps1)

完成配置后，请让 AutoClipboard 在后台保持运行。Codex / Claude Hook 会写入本地状态文件，AutoClipboard 聚合状态后通过 BLE 转发给已配对的手柄。
<!-- endsection -->

<!-- section:install-skill -->
<!-- lang:en -->
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
<!-- lang:zh-CN -->
## 安装 AI Coding Handle Skill

开源 Skill 位于 [`skills/ai-coding-handle`](skills/ai-coding-handle)。获得用户授权后，它可以安装匹配版本的 AutoClipboard，并为受支持的 Agent 配置状态 Hook。

可使用跨 Agent 安装器，把它安装到 Codex、Claude Code、OpenCode 或其他支持 Agent Skills 的客户端：

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --skill ai-coding-handle -g
```

安装前查看检测到的 Skill：

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --list
```

每个 GitHub Release 也会附带相同版本的 Skill ZIP，便于手动安装。
<!-- endsection -->

<!-- section:maintainer-upload -->
<!-- lang:en -->
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
<!-- lang:zh-CN -->
## 维护者上传说明

在私有开发仓库推送匹配的版本标签后，可以自动发布到本仓库：

```powershell
git tag v0.3.29
git push origin main
git push origin v0.3.29
```

私有仓库中的 GitHub Actions 工作流会构建全部发布文件，并上传到这个公开仓库。

如果 Windows 安装包是手动构建的，请在私有仓库的 `AutoClipboard` 目录中上传：

```powershell
gh release upload v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --clobber
```

如果对应的 Release 尚不存在：

```powershell
gh release create v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --title "AutoClipboard 0.3.29" --notes "AutoClipboard 0.3.29"
```

Windows 电脑需要先安装 GitHub CLI 并完成登录：

```powershell
winget install --id GitHub.cli
gh auth login
```
<!-- endsection -->

<!-- section:readme-maintenance -->
<!-- lang:en -->
## Keeping Both Languages in Sync

`README.md` and `README.zh-CN.md` are generated from [`docs/README.bilingual.md`](docs/README.bilingual.md). Update both language blocks in that source file, then run:

```bash
python scripts/sync_readmes.py
```

GitHub Actions runs `python scripts/sync_readmes.py --check` on every relevant change. The check fails if a translation block is missing or either generated README is stale.
<!-- lang:zh-CN -->
## 保持中英文同步

`README.md` 和 `README.zh-CN.md` 都由 [`docs/README.bilingual.md`](docs/README.bilingual.md) 生成。请在源文件中同时更新两种语言，然后运行：

```bash
python scripts/sync_readmes.py
```

每次相关改动都会由 GitHub Actions 执行 `python scripts/sync_readmes.py --check`。如果缺少任一语言段落，或生成的 README 没有更新，检查就会失败。
<!-- endsection -->

<!-- section:notes -->
<!-- lang:en -->
## Notes

This repository contains only the MIT-licensed AI Coding Handle Skill source and public release support files. AutoClipboard and firmware application source code remain private; use the Release page for compiled downloads.
<!-- lang:zh-CN -->
## 说明

本仓库只包含采用 MIT License 的 AI Coding Handle Skill 源码和公开发布支持文件。AutoClipboard 与固件应用源码仍为私有内容；如需安装包或固件，请前往 Release 页面下载编译产物。
<!-- endsection -->
