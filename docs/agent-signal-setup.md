# AutoClipboard Agent 状态监测配置指南

AutoClipboard 可以监听 Codex / Claude Code 的工作状态，并把状态同步到手柄灯环和小屏幕。

典型效果：

- `working`：Agent 正在工作，灯环跑马灯。
- `permission`：等待用户授权或输入，黄色快闪。
- `blocked`：任务阻塞或失败，红色提醒。
- `done`：本轮回答完成，绿色完成提示；开启强提醒后会触发蜂鸣器和通知。

## 最快配置方式

### 方法一：在 AutoClipboard 里配置

1. 启动 AutoClipboard。
2. 打开软件设置里的 Agent 状态灯/工作状态监测区域。
3. 点击“配置状态灯”或“修复 Hook”按钮。
4. 保持 AutoClipboard 在后台运行。

这是推荐方式，适合大多数用户。

### 方法二：Linux 命令行一键配置

在下载本仓库脚本后执行：

```bash
bash scripts/configure-agent-signal-linux.sh
```

如果 AutoClipboard 安装在自定义路径，可以指定：

```bash
AUTOCLIPBOARD_EXE=/path/to/AutoClipboard bash scripts/configure-agent-signal-linux.sh
```

### 方法三：Windows PowerShell 一键配置

在 PowerShell 里执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\configure-agent-signal-windows.ps1
```

如果 AutoClipboard 安装在自定义路径，可以指定：

```powershell
$env:AUTOCLIPBOARD_EXE="C:\Path\To\AutoClipboard.exe"
powershell -ExecutionPolicy Bypass -File .\scripts\configure-agent-signal-windows.ps1
```

## 配置后会发生什么

脚本会调用已安装的 AutoClipboard：

```text
AutoClipboard --install-agent-signal-hooks
```

AutoClipboard 会自动写入或修复：

- Codex Hook 配置：`~/.codex/hooks.json`
- Claude Code Hook 配置：`~/.claude/settings.json`

Hook 只负责把状态写入本机状态目录，不会直接打断 Codex / Claude 的正常工作流程。

## 验证是否成功

### Linux

```bash
ls ~/.config/AutoClipboard/agent-signal
tail -n 20 ~/.config/AutoClipboard/agent-signal/hook-events.log
```

### Windows

```powershell
dir "$env:APPDATA\AutoClipboard\agent-signal"
Get-Content "$env:APPDATA\AutoClipboard\agent-signal\hook-events.log" -Tail 20
```

正常情况下，启动一次 Codex / Claude 对话后，日志里会看到类似：

```text
UserPromptSubmit -> working
PreToolUse -> working
PostToolUse -> working
Stop -> done
```

## 常见问题

### AutoClipboard 显示 Agent 状态不变化

先确认 AutoClipboard 正在后台运行。Hook 只写本地状态，真正同步到手柄需要 AutoClipboard 运行并连接 BLE。

### Codex 可以同步，Claude Code 不能同步

重新运行一键配置脚本，或在 AutoClipboard 里点击“修复 Hook”。然后检查 `~/.claude/settings.json` 是否被写入 Hook。

### 状态在 working / done 之间闪烁

请升级到最新版本 AutoClipboard。新版本会优先使用事件自身时间戳判断 `done`，避免 Codex 会话文件被触碰时把旧的完成事件误判为新的完成事件。

### 手柄没有提醒

1. 确认手柄已经通过 BLE 连接 AutoClipboard。
2. 确认 AutoClipboard 的 Agent 状态灯功能已开启。
3. 如果需要蜂鸣器提醒，打开“强提醒模式”，并设置“强提醒音量”。

## 卸载或关闭

如果只是暂时不想同步，直接在 AutoClipboard 设置里关闭 Agent 状态灯即可。

如果要彻底移除 Hook，可以手动编辑并删除以下文件中的 AutoClipboard Hook 命令：

- `~/.codex/hooks.json`
- `~/.claude/settings.json`

