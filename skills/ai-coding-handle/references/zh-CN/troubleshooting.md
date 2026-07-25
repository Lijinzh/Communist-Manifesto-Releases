<!-- section:s001 -->
# 故障排查

<!-- section:s002 -->
## Bootstrap 拒绝元数据或附件

- 确认选定条目存在于 `app.windows`、`app.linux` 或 `app.macos`。
- 确认安装包扩展名对应 `.exe`、`.deb` 或 `.dmg`。
- 确认附件 URL 使用 HTTPS，并属于固定的 GitHub Release 仓库。
- 大小或 SHA-256 不一致时重新下载，绝不能跳过任一检查。
- 本地元数据文件只能与 dry-run 一起使用。

<!-- section:s003 -->
## 已找到 AutoClipboard，但 doctor 失败

在诊断范围内，只读取结果文件并报告失败检查，不修改软件或 Hook 配置。

在明确的安装或配置范围内，首先要求核心预检通过。`hook_executable_available`、`platform_poll_supported` 或 `state_directory_writable` 任一失败时停止。缺失或过期的原生 Hook 检查可以通过原生安装修复；配置格式错误或其他失败保持致命并必须报告。

<!-- section:s004 -->
## Codex 报告 `hook_trust_granted: false`

只有核心和 Hook 配置检查全部通过，`hook_trust_probe_available`、`hook_trust_metadata_complete` 和 `hook_runtime_enabled` 为真，而且这是唯一失败项时，才要求用户在 Codex 内检查并批准 AutoClipboard Hook，然后重新运行 doctor。这是 `configuration_required`，不是 `ready`，也不是通用 bootstrap 失败。探测失败、元数据不完整、Hook 被禁用或信任状态未知都属于致命诊断，不能转成批准提示。

绝不能向 Codex `config.toml` 写入 `[hooks.state]` 或 `trusted_hash`，也绝不能使用 `--dangerously-bypass-hook-trust`；Hook 信任必须保持为明确的用户或托管策略决定。

<!-- section:s005 -->
## Agent 集成不受支持

Codex 和 Claude Code 支持原生安装。对于 Hermes、OpenCL 或其他通用 Agent，配置 `emit` 前必须验证官方生命周期 Hook、稳定会话 ID 和事件载荷。缺少任一条件时报告 `unsupported`；不要根据进程存在、日志或计时器推断状态。

<!-- section:s006 -->
## Doctor 通过，但手柄没有反应

除非明确授权了 `--live-test`，doctor 只证明主机侧配置。检查 AutoClipboard 正在运行、设备已经配对并连接，而且选定状态可见。物理手柄不可用时，必须记录硬件端到端验证仍未完成。

<!-- section:s007 -->
## Ubuntu 或 BlueZ 只显示未命名 HID 地址

仅当图形蓝牙设置无法显示 `CommunistKB-XXXX` 时使用此后备流程。它不能替代用于恢复主广播完整名称的固件更新。

从只读诊断开始。如果蓝牙适配器已关闭，要求用户启用；未经授权不要运行 `power on`。关闭目标手柄，开始当前扫描，然后打开手柄，明确进入空主机槽，并要求屏幕显示 `PAIR`。候选地址必须在手柄关闭时消失，在当前扫描中重新出现；不能依赖只存在于 BlueZ 缓存设备列表中的地址。候选首次出现后继续扫描至少 10 秒并检查所有候选。打开一个交互式 `bluetoothctl` 会话：

```text
bluetoothctl
scan on
devices
info AA:BB:CC:DD:1C:96
```

只有恰好一个候选同时满足以下全部检查时才能配对：

- 手柄屏幕当前显示 `PAIR`。
- 地址最后两个字节与从旧配对记录、设备标签或经过验证的 USB/串口清单独立获得的设备名后缀一致；例如 `...:1C:96` 对应 `CommunistKB-1C96`。如果没有独立后缀，必须在只有一个物理手柄进入 `PAIR` 的情况下完成关机消失、开机重新出现检查；绝不能把候选地址本身当作对自身的证明。
- `info` 显示 HID `0x1812`（`00001812-0000-1000-8000-00805f9b34fb`）。
- `info` 显示 Battery `0x180F`（`0000180f-0000-1000-8000-00805f9b34fb`）。
- 没有第二个候选满足相同证据。候选仍有歧义时停止，并要求用户关闭其他手柄或以其他方式识别目标地址；绝不能任意选择。

诊断阶段保持只读：最后运行 `scan off`，报告验证过的地址和证据，但不要启用配对 Agent、执行 pair、trust 或 connect。改变蓝牙状态前，展示准确的已验证地址，并为每个计划动作取得授权。不能从“只要求配对”推断 trust 或 connect 授权。用户明确授权三个动作时，在同一会话继续：

```text
agent on
default-agent
pair AA:BB:CC:DD:1C:96
trust AA:BB:CC:DD:1C:96
connect AA:BB:CC:DD:1C:96
info AA:BB:CC:DD:1C:96
scan off
quit
```

报告成功前必须验证 `Paired: yes`、`Connected: yes` 和手柄上的 `LINK`。如果用户只授权部分动作，在该部分完成后停止，只报告实际验证的状态。`pair` 命令本身可能建立连接并产生 `Connected: yes`；观察到该状态不代表获得了额外运行显式 `connect` 的授权。

不能因为 GUI 缺少名称就重置蓝牙适配器、删除现有绑定、清除手柄槽位或更改 SMP 身份验证。如果日志包含 `unexpected SMP command 0x0b`，但配对、连接和 `LINK` 全部成功，把它记录为独立兼容性线索；它不能证明安全设置必须更改。配对失败时保留 `bluetoothctl` 和 BlueZ 日志，在不扩大授权修改范围的情况下继续诊断。

<!-- section:s008 -->
## 固件预检无法识别唯一设备

- `device_not_connected`：要求用户连接一个受支持手柄并检查 USB/串口访问，不能猜测端口。
- `ambiguous_device`：停止并要求只保留一个目标手柄连接，绝不能任意选择。
- `board_unknown`：停止并取得设备报告的有效 D4/V3 身份，不能根据附件名或用户偏好推断板型。

物理问题解决后重新运行 `firmware-check`。不能绕过预检，也不能直接调用 PlatformIO/`esptool`。

<!-- section:s009 -->
## 固件计划或更新失败

- `plan_invalid`：计划、摘要、固件包或过期时间无效。丢弃并重新检查，绝不能编辑计划。
- `plan_replayed`：目标已经存在或一次性计划被复用，不能再次刷写。
- `device_busy`：另一个危险设备操作持有锁。停止冲突操作并通过 Maintenance 重试，绝不能绕过锁。
- `verification_failed`：刷写可能已经完成，但目标版本未验证。不能报告成功；重新连接并诊断。
- `recovery_required`：刷写可能已经完成，但设备未可靠恢复或重新枚举。保留结果和日志，警告用户，不自动重试、擦除 Flash、重置 NVS 或完整刷写。

任何新的 `confirmation_required` 计划都需要当前的独立第二次确认，绝不能复用之前的软件授权或笼统授权。
