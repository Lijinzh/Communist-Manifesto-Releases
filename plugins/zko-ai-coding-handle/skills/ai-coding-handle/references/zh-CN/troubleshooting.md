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

<!-- section:s006-linux-bluetooth -->
## Linux 手柄在观测时稳定，但空闲后卡顿

当 Linux 输入偶发暂停、手柄仍显示 `LINK`，空闲后变成 `WAIT`，闪蓝灯重新连接，或
AutoClipboard、Agent 持续观测时明显更稳定，使用本流程。持续 BLE 流量会让 USB 蓝牙
控制器保持唤醒，因此这种现象可能暴露的是 `btusb` USB 自动挂起，而不是固件按键扫描
延迟。

先运行随 Skill 提供的只读检查：

```bash
/absolute/path/to/ai-coding-handle/scripts/configure-linux-bluetooth-autosuspend.sh --check
```

脚本必须把 `hciN` 控制器经过 `btusb` 接口解析到唯一的 USB 父设备，而且该父设备同时
具有 `idVendor`、`idProduct` 和 `power/control`。返回 `device_not_found` 或
`ambiguous_device` 时停止，不能按枚举顺序选择适配器。如果存在多个控制器，必须根据
独立的主机证据识别目标，再用 `--hci hciN` 重新运行。

只有结果返回 `recommended: true` 时，才把该适配器专用的 `power/control=on` 作为这种
故障模式下的 Linux 推荐默认值。常见匹配证据是 `btusb_autosuspend: "Y"` 且
`power_control: "auto"`，或者当前临时值已经是 `"on"`，但
`persistent_rule_state` 仍为 `missing`。`persistent_rule_state: "legacy_managed"` 表示旧版
规则只在 USB 设备加入时写入，可能在 `btusb` 绑定时被覆盖；取得授权后的 `--apply` 会把
它升级为当前的加入与绑定双阶段规则。结果为 `configured` 表示准确 VID/PID 的规则已经
生效，不要重复改写。证据不匹配时继续检查 BLE、HID、无线干扰和固件，不要应用本修复。

只读内核证据可能反复包含：

```text
Bluetooth: hci0: ACL packet for unknown connection handle ...
```

这条消息可以支持主机控制器传输故障的判断，但不能单独证明手柄固件发生了重启。
只有另有串口复位输出、复位原因或 USB 重新枚举证据时，才能报告固件重启。

应用修复前，向用户展示检查返回的全部相关字段：`hci`、`vendor_id`、`product_id`、
`usb_device`、`power_control`、`btusb_autosuspend`、`persistent_rule` 和 `udev_rule`。
说明该命令会立即向这个准确 USB 设备写入 `on`，并安装准确 VID/PID 的 udev 规则，
使设置在重启和重新插拔后继续有效。取得明确的系统配置授权后，使用脚本绝对路径和
已经验证的准确 HCI：

```bash
pkexec /absolute/path/to/ai-coding-handle/scripts/configure-linux-bluetooth-autosuspend.sh --apply --hci hci0
```

只有 JSON 结果同时满足 `success: true`、`status: "configured"`、
`power_control: "on"` 和 `persistent_rule_state: "managed"` 时才能报告成功。重启后必须
重新运行 `--check`；如果实时值又变成 `auto`，就不能认为持久化已经验证。不能重启 BlueZ、
开关适配器电源、清除配对、全局关闭自动挂起或修改其他 USB 设备。必须经过一段空闲时间
验证真实症状，不能把 sysfs 写入成功当作所有 BLE 问题均已解决的证明。

回滚同样属于系统修改，需要明确授权。它只删除所选 VID/PID 对应的受管规则，并把当前
适配器恢复为 `power/control=auto`：

```bash
pkexec /absolute/path/to/ai-coding-handle/scripts/configure-linux-bluetooth-autosuspend.sh --remove --hci hci0
```

<!-- section:s006-linux-mediatek-firmware -->
## Linux MediaTek 固件已更新但仍然断连

必须把“固件文件已经替换”和“控制器实际加载了该固件”视为两个独立结论。MediaTek 组合
网卡的蓝牙部分通过 USB 暴露，因此不能用 `lspci` 看到的 PCIe Wi-Fi 型号选择蓝牙固件。

先执行只读诊断，并把每条证据绑定到同一个 HCI 控制器：

```bash
readlink -f /sys/class/bluetooth/hci0/device
lsusb
journalctl -k -b --no-pager | rg 'Bluetooth: hci0: (HW/SW Version|Device setup)|unknown connection handle|USB disconnect'
```

解析 USB 父设备、VID/PID、`btusb` 驱动和控制器厂商，再根据 Linux 证据确定实际使用的
`btmtk` 固件家族。当前上游 Linux 对应路径为：

- MT7922：`mediatek/BT_RAM_CODE_MT7922_1_1_hdr.bin`
- MT7925：`mediatek/mt7925/BT_RAM_CODE_MT7925_1_1_hdr.bin`

对于已知的 `13d3:3602` 适配器，上游 `btusb.c` 把该 USB ID 列在附加 MT7925 设备下。
仍需用 `strings -a` 读取已安装候选文件的构建标签，并与内核报告的运行中 `Build Time`
匹配；不能只相信 USB 产品字符串或记忆中的型号。如果刚复制的 MT7922 文件标签更新，
但运行中构建时间仍与 MT7925 文件一致，那么该控制器没有使用这次 MT7922 更新。

只把选中的准确文件与官方
[`kernel-firmware/linux-firmware`](https://gitlab.com/kernel-firmware/linux-firmware) `main`
分支及该路径的提交历史比较。先下载到 `/tmp`，分别计算本地和上游文件的 SHA-256，并
提取两个构建标签后才能提出修改。官方源可访问时不得改用非官方镜像。

替换前必须展示准确 HCI、USB VID/PID、选中的本地路径、运行中构建版本、本地构建版本和
SHA-256、上游构建版本和 SHA-256、来源 URL 以及备份路径，并取得明确的软件修改授权。
先备份实际使用的文件，只安装选中的上游文件，保持 root 所有权和 `0644` 权限，随后
重新校验 SHA-256。不能为了保险同时替换 MT7922 和 MT7925。

控制器重新初始化前，新文件并未生效。重启、USB 解绑/重新绑定或模块重载都会断开其他
蓝牙设备，必须另行取得授权。完成获准的重启后，只有内核的新 `Build Time` 与已安装
构建标签一致时，才能报告控制器更新完成。

如果最新构建已经实际加载但仍然断连，继续执行上面的适配器专用 autosuspend 检查，
并检查 BlueZ/HCI、无线干扰以及手柄串口复位证据。反复出现
`ACL packet for unknown connection handle`，随后 HID 被重新创建，但控制器 USB 设备
没有消失，更符合主机/控制器连接状态不同步；它不能单独证明 ESP32 重启，也不能证明
问题已经修复。

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
