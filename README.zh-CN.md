<!-- Generated from docs/README.bilingual.md by scripts/sync_readmes.py. Do not edit directly. -->

[English](README.md) | **简体中文**

# Communist Manifesto 发布仓库

本公开仓库是 **AutoClipboard** 和 **CommunistManifestoKB** 的正式发布渠道。

主开发仓库仍为私有仓库。本仓库只提供编译后的发布文件、面向用户的发布说明、更新指南，以及开源的 AI Coding Handle Skill。

## 下载

打开[最新 GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)，然后下载与你的平台对应的文件：

- Windows：`AutoClipboardSetup-<version>.exe`
- Windows CH343 USB 串口驱动：`CH343SER.EXE`
- Linux / Ubuntu：`auto-clipboard_<version>_<arch>.deb`
- macOS：`AutoClipboard-<version>-macOS.dmg`
- ESP32 固件：`CommunistManifestoKB-firmware-d4-<version>.zip` 或 `CommunistManifestoKB-firmware-v3-<version>.zip`
- AI Agent Skill：`ai-coding-handle-skill-<version>.zip`

请根据手中实体设备的板型选择 D4 或 V3 固件包，不要跨板型刷写。

## AutoClipboard 0.3.49 更新重点

- 手柄状态页右上角现在显示“正在工作的 Agent 数量”气泡；数量为 0 时自动隐藏。
- 蓝牙主机管理已移入小屏 `Settings > BLE Hosts`：可以查看已保存主机数量、切换三个槽位、为空槽配对，或长按已有槽位删除记录。
- 移除了机械结构无法完成的“按住拨轮中键同时滚动”操作，并同步更新了上位机中英文配对指南。
- 改进 Windows BLE 重连和连接所有权：退出 AutoClipboard 不再断开 HID 键盘连接，重新打开软件后也能更快恢复 IMU 预览。
- 包含最新的 V3 IMU 预览、Halo 演讲光圈、设备设置窗口自适应和固件稳定性修复。

请从 [v0.3.49 Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/tag/v0.3.49) 下载对应的软件安装包和固件。

## Windows CH343 串口驱动

手柄通过 USB Type-C 连接 Windows 后，如果系统没有创建 COM 端口，请下载由 WCH 提供并带有效数字签名的 [CH343SER.EXE](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/download/v0.3.48/CH343SER.EXE)。安装与排障步骤见[简体中文指南](docs/ch343-driver-installation.zh-CN.md)或 [English guide](docs/ch343-driver-installation.md)。

本仓库文件的 Authenticode 签名者为 `Nanjing Qinheng Microelectronics Co., Ltd.`，SHA-256 为 `99f16f9c4cf9c315dc9a17b29021d82d522014ecc053d9ee1c7b38c214dea40b`。

## 自动更新

AutoClipboard 会检查本仓库中的最新 Release。

- 软件更新会自动选择与当前操作系统匹配的安装包。
- 固件更新会根据已连接设备选择匹配的 D4 或 V3 固件包，默认把 `firmware.bin` 写入 `0x10000`，并保留 NVS 设置和自定义图标。

## Agent 状态监控

AutoClipboard 可以监控 Codex / Claude Code 的工作状态，并把状态同步到手柄灯环和屏幕通知。

- 配置指南：[`docs/agent-signal-setup.md`](docs/agent-signal-setup.md)
- Linux 一键配置脚本：[`scripts/configure-agent-signal-linux.sh`](scripts/configure-agent-signal-linux.sh)
- Windows 一键配置脚本：[`scripts/configure-agent-signal-windows.ps1`](scripts/configure-agent-signal-windows.ps1)

完成配置后，请让 AutoClipboard 在后台保持运行。Codex / Claude Hook 会写入本地状态文件，AutoClipboard 聚合状态后通过 BLE 转发给已配对的手柄。

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

仓库中的 Skill 与版本化 ZIP 均由同一份规范源生成。Skill 可以通过已安装的 AutoClipboard Maintenance CLI 识别已连接的 D4/V3 手柄、检查正式发布的固件版本、校验匹配的固件包，并且只会在用户针对该更新再次明确确认后执行刷写。本地开发固件刷写仅在 Skill 运行于 Communist-Manifesto 源码仓库内、且用户明确提出测试刷写请求时可用。

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

## 保持中英文同步

`README.md` 和 `README.zh-CN.md` 都由 [`docs/README.bilingual.md`](docs/README.bilingual.md) 生成。请在源文件中同时更新两种语言，然后运行：

```bash
python scripts/sync_readmes.py
```

每次相关改动都会由 GitHub Actions 执行 `python scripts/sync_readmes.py --check`。如果缺少任一语言段落，或生成的 README 没有更新，检查就会失败。

私有开发仓库的发布工作流还会把同一个版本化 Skill ZIP 原样同步到本仓库的 `skills/ai-coding-handle` 目录，因此通过仓库安装和手动安装 ZIP 在每个正式发布版本中会得到相同文件。

## 说明

本仓库只包含采用 MIT License 的 AI Coding Handle Skill 源码和公开发布支持文件。AutoClipboard 与固件应用源码仍为私有内容；如需安装包或固件，请前往 Release 页面下载编译产物。
