<!--
This is the source of truth for docs/user-guide.zh-CN.md and docs/user-guide.en.md.
Keep both language blocks in every section, then run:

    python scripts/sync_readmes.py

Do not edit the generated user-guide files directly.
-->

<!-- section:title -->
<!-- lang:en -->
# ZKO AI Coding Handle User Guide

This guide is written for users who have never used the handle, AutoClipboard, Agent Skills, or the screen controls before. Follow the chapters in order for the first setup; use the troubleshooting chapter later when a specific symptom appears.

<p align="center">
  <img src="assets/user-guide/workflow.webp" alt="ZKO handle workflow and supported capabilities" width="720">
</p>

## Recommended reading order

1. Install the AI Coding Handle Skill.
2. Identify the hardware and USB Type-C port.
3. Pair `CommunistKB-XXXX` over Bluetooth.
4. Learn the wheel, middle button, Profiles, and macro buttons.
5. Start AutoClipboard and configure Agent status synchronization.
6. Use troubleshooting only when a step does not work as described.

> The product and application continue to evolve. Promotional images and screenshots help identify the hardware and workflow, while the written commands and state labels in this guide are the authoritative instructions for the current release.
<!-- lang:zh-CN -->
# 苍虬 AI 编程手柄使用说明书

这份说明书面向完全没有接触过苍虬手柄、AutoClipboard、Agent Skills 和小屏操作的新用户。第一次使用时建议按章节顺序完成；以后遇到具体问题，再直接查看故障排查章节。

<p align="center">
  <img src="assets/user-guide/workflow.webp" alt="苍虬手柄工作流和功能概览" width="720">
</p>

## 推荐阅读顺序

1. 先安装 AI Coding Handle Skill。
2. 认识手柄硬件和 USB Type-C 接口。
3. 在电脑上连接 `CommunistKB-XXXX` 蓝牙设备。
4. 学会波轮、中键、Profile 和四枚宏按键的操作。
5. 启动 AutoClipboard，并配置 Agent 状态同步。
6. 某一步没有按预期工作时，再进入故障排查章节。

> 产品和软件会继续更新。宣传图片和软件截图主要用于帮助识别硬件与使用流程；涉及具体手势、蓝牙名称和状态文字时，请以本说明书中的文字为准。
<!-- endsection -->

<!-- section:installation-path -->
<!-- lang:en -->
## 1. Choose an installation path

There are two supported ways to start.

### Recommended: let a coding agent use the Skill

Choose this path when Codex, Claude Code, OpenCode, or another Agent Skills-compatible client is available. The Skill can select the correct application release, inspect the installed application, identify the connected board, configure supported Agent hooks, and collect structured diagnostic evidence.

### Manual setup

Choose this path when no compatible agent client is available:

1. Open the [latest Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest).
2. Download the installer for the current operating system.
3. Install AutoClipboard.
4. Pair the handle in the operating system's Bluetooth settings.
5. Start AutoClipboard and follow the remaining chapters.

Windows is the primary supported platform. Linux support is experimental. Use a macOS package only when the selected release explicitly contains one.
<!-- lang:zh-CN -->
## 1. 选择安装方式

第一次使用时有两种方式。

### 推荐方式：让大模型使用 Skill

如果电脑上有 Codex、Claude Code、OpenCode 或其他支持 Agent Skills 的客户端，优先使用这种方式。Skill 可以选择正确的软件版本、检查已经安装的 AutoClipboard、识别连接的硬件板型、配置受支持的 Agent Hook，并收集结构化的诊断结果。

### 手动安装方式

没有可用的大模型客户端时，按照以下步骤操作：

1. 打开[最新 Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)。
2. 下载当前操作系统对应的安装包。
3. 安装 AutoClipboard。
4. 在操作系统蓝牙设置中配对手柄。
5. 启动 AutoClipboard，然后继续阅读后面的章节。

Windows 是当前主要支持平台，Linux 处于实验支持阶段。只有目标 Release 明确提供 macOS 安装包时，才使用该版本的 macOS 文件。
<!-- endsection -->

<!-- section:skill -->
<!-- lang:en -->
## 2. Install and use the AI Coding Handle Skill

Install the repository Skill with the cross-agent installer:

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --skill ai-coding-handle -g
```

To see the Skill detected by the installer before installing:

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --list
```

After installation, a useful first request is:

> Use the `ai-coding-handle` Skill. Install or verify AutoClipboard, identify my connected ZKO handle, and run read-only USB, serial, Bluetooth, application, and Agent Hook diagnostics. Do not reset Bluetooth or update firmware without asking me first.

### What the Skill can help with

- Select and install the appropriate published AutoClipboard package.
- Check the application version and supported Agent Bridge capabilities.
- Identify a D4 or V3 device from structured device information.
- Inspect USB serial, Bluetooth, AutoClipboard runtime, and Agent Hook status.
- Explain why a device is paired but not available to AutoClipboard.
- Check whether a matching published firmware update exists.

### Actions that still require confirmation

- Installing or replacing software when it changes the computer.
- Running a live device-state test that changes visible lights or screen state.
- Resetting the operating system's Bluetooth adapter or pairing records.
- Flashing firmware. The exact device, version, package, plan, and digest must be shown before a separate confirmation.

The Skill is a guided diagnostic and maintenance tool, not permission to perform destructive recovery automatically.
<!-- lang:zh-CN -->
## 2. 安装并使用 AI Coding Handle Skill

使用跨 Agent 安装器安装仓库中的 Skill：

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --skill ai-coding-handle -g
```

如果希望在安装前先查看安装器检测到的 Skill，可以运行：

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --list
```

安装完成后，可以先把下面这段话发给大模型：

> 请使用 `ai-coding-handle` Skill，安装或检查 AutoClipboard，识别我连接的苍虬手柄，并以只读方式检查 USB、串口、蓝牙、软件运行状态和 Agent Hook。未经我确认，不要重置蓝牙，也不要更新固件。

### Skill 可以帮助完成什么

- 选择并安装合适的正式版 AutoClipboard。
- 检查软件版本和 Agent Bridge 能力。
- 根据结构化设备信息识别 D4 或 V3 硬件。
- 检查 USB 串口、蓝牙、AutoClipboard runtime 和 Agent Hook 状态。
- 分析“系统已经配对，但 AutoClipboard 无法使用”的原因。
- 检查是否存在与设备匹配的正式固件更新。

### 哪些操作仍然必须确认

- 安装或替换会改变电脑状态的软件。
- 运行会改变灯环或小屏状态的实机测试。
- 重置操作系统蓝牙适配器或删除配对记录。
- 刷写固件。必须先展示准确的设备、版本、固件包、更新方案和摘要，再单独确认。

Skill 是受控的诊断和维护工具，不代表大模型可以自动执行破坏性恢复操作。
<!-- endsection -->

<!-- section:hardware -->
<!-- lang:en -->
## 3. Hardware overview

<p align="center">
  <img src="assets/user-guide/handle-hero.webp" alt="ZKO AI Coding Handle front view" width="680">
</p>

> The DJI microphone in the image is an example accessory and is not included. The handle can be used without that microphone.

### Main parts

| Part | What the user sees | What it does |
| --- | --- | --- |
| Color screen | Small display near the top | Shows Profile, Bluetooth, battery, time, Agent state, and device messages |
| Wheel | Black wheel on the upper side | Switches Profile or moves through menu items |
| Wheel middle button | Pressable center of the wheel | Quick launch, enter Settings, confirm, go back, or exit depending on the screen |
| Four macro buttons | Four side buttons under the user's fingers | Sends the four macros stored in the current Profile |
| Front light ring | Illuminated front elements | Shows Agent, Profile, input, completion, and warning feedback |
| IMU | Motion sensor inside the handle | Supplies orientation data for preview and the presenter Halo |
| USB Type-C | Connector shown in the next photo | Charges the handle and provides serial diagnostics and firmware update transport |

<p align="center">
  <img src="assets/user-guide/usb-type-c-interface.jpg" alt="USB Type-C connector on the handle" width="800">
</p>

The USB Type-C connector is the leftmost connector visible in the photograph. It is the documented user connection for charging and computer data. The exposed components beside it are not required for the normal setup steps in this guide.
<!-- lang:zh-CN -->
## 3. 硬件结构介绍

<p align="center">
  <img src="assets/user-guide/handle-hero.webp" alt="苍虬 AI 编程手柄正面实物图" width="680">
</p>

> 图片中的 DJI 麦克风是可替换配件和使用场景示意，不包含在手柄包装内。没有这个麦克风也不影响手柄本体使用。

### 主要部件

| 部件 | 用户看到的位置 | 作用 |
| --- | --- | --- |
| 彩色小屏 | 手柄顶部附近的小屏幕 | 显示 Profile、蓝牙、电量、时间、Agent 状态和设备提示 |
| 波轮 | 手柄上部侧面的黑色波轮 | 切换 Profile，或在菜单中上下移动 |
| 波轮中键 | 波轮可以向内按下的中间位置 | 根据当前界面执行快开、进入设置、确认、返回或退出 |
| 四枚宏按键 | 握持时手指对应的 4 个侧面按键 | 执行当前 Profile 中保存的四个宏 |
| 正面灯环 | 正面可发光的灯组 | 显示 Agent、Profile、输入、完成和警告等反馈 |
| 内置 IMU | 位于手柄内部的姿态传感器 | 为三维预览和演讲光圈提供姿态数据 |
| USB Type-C | 见下方接口照片 | 为手柄充电，并提供串口诊断和固件更新通道 |

<p align="center">
  <img src="assets/user-guide/usb-type-c-interface.jpg" alt="苍虬手柄 USB Type-C 接口实物图" width="800">
</p>

照片中最左侧的接口是 USB Type-C，也是本说明书中用于充电和连接电脑数据线的正式用户接口。旁边可见的板上部件不属于本说明书要求普通用户操作的日常接口。
<!-- endsection -->

<!-- section:type-c -->
<!-- lang:en -->
## 4. Charging and USB Type-C connection

### Charging

1. Connect a suitable USB Type-C cable to the handle.
2. Connect the other end to a stable USB power source or computer.
3. Check the handle screen or AutoClipboard battery status when available.

### Data connection

Use a cable that supports data when you need any of the following:

- A Windows COM port and serial diagnostics.
- Device identity or board information over Type-C.
- Large icon transfer.
- Firmware update.

A charge-only cable can provide power but will not create a COM port. If Windows does not recognize the serial device even with a known data cable, install the signed [CH343 driver](ch343-driver-installation.md).

Bluetooth and Type-C are independent. Normal Bluetooth keyboard macros do not require a Type-C cable, and connecting or disconnecting Type-C should not be treated as proof that Bluetooth is connected.
<!-- lang:zh-CN -->
## 4. 充电与 USB Type-C 连接

### 给手柄充电

1. 把合适的 USB Type-C 线插入手柄接口。
2. 另一端连接稳定的 USB 电源或电脑。
3. 在小屏或 AutoClipboard 中查看可用的电量与充电状态。

### 连接电脑进行数据通信

需要以下功能时，必须使用支持数据传输的线缆：

- 在 Windows 中创建 COM 串口并进行诊断。
- 通过 Type-C 读取设备身份或板型信息。
- 传输较大的自定义图标。
- 更新手柄固件。

只有充电功能的线可以供电，但不会创建 COM 端口。如果确认使用的是数据线，Windows 仍然无法识别串口设备，请安装带数字签名的 [CH343 驱动](ch343-driver-installation.zh-CN.md)。

蓝牙与 Type-C 是相互独立的连接。日常蓝牙键盘宏不需要插 Type-C；插入或拔出 Type-C 也不能用来判断蓝牙是否已经连接。
<!-- endsection -->

<!-- section:bluetooth -->
<!-- lang:en -->
## 5. Bluetooth name, first pairing, and three host slots

### Find the correct device name

The handle advertises this pattern:

```text
CommunistKB-XXXX
```

- `CommunistKB-` is the fixed prefix.
- `XXXX` is a four-character uppercase hexadecimal short ID generated from the last two bytes of the ESP32 MAC address.
- A real device may therefore appear as `CommunistKB-A216` or another four-character value.
- The full name is already broadcast by the handle. Do not type or append a suffix manually.

### Screen Bluetooth states

| State | Meaning | What to do |
| --- | --- | --- |
| `PAIR` | The handle is temporarily discoverable | Add `CommunistKB-XXXX` in system Bluetooth settings |
| `WAIT` | The handle is waiting for the selected saved host | Wake or enable Bluetooth on that computer |
| `LINK` | The selected host is connected | Test a macro button or start AutoClipboard |

### First pairing

1. A new device, or a device after all pairing records are cleared, opens one 120-second pairing window.
2. Open the computer's Bluetooth settings.
3. Choose **Add Bluetooth device**.
4. Wait until the handle screen shows `PAIR`.
5. Select the complete `CommunistKB-XXXX` entry.
6. After pairing, wait for the screen to show `LINK`.
7. Press the `Enter` or `Ctrl+V` macro in a safe text field to confirm Bluetooth HID input.

If the 120-second window expires, open another pairing window from `Settings > BLE Hosts` as described below.

### Pair a second or third computer

1. On the handle status screen, double-click the wheel middle button.
2. Rotate to `BLE Hosts` and single-click.
3. The page shows three slots. `*` marks the currently selected slot.
4. Select an `EMPTY` slot and single-click it.
5. Wait for `PAIR` and the blue breathing feedback.
6. Add `CommunistKB-XXXX` on the new computer within 120 seconds.

### Switch or delete a saved host

- Single-click a saved slot: select that host and allow it to reconnect.
- Long-press a saved slot: delete the Bluetooth bond and stored record for that slot.
- Select `Back` and single-click: return to the previous menu.
- Holding the wheel middle button for about five seconds during startup clears all three slots and restarts the handle. This is a recovery action, not the normal way to switch computers.

Do not hold the middle button while rotating the wheel. The handle's physical mechanism does not support that gesture.
<!-- lang:zh-CN -->
## 5. 蓝牙名称、首次配对与三主机槽位

### 找到正确的蓝牙名称

手柄广播的名称格式为：

```text
CommunistKB-XXXX
```

- `CommunistKB-` 是固定前缀。
- `XXXX` 是根据 ESP32 MAC 地址最后 2 个字节生成的 4 位大写十六进制短编号。
- 因此真实设备可能显示为 `CommunistKB-A216`，也可能是其他 4 位编号。
- 完整名称已经由手柄自动广播，用户不要手动输入或追加后缀。

### 小屏蓝牙状态

| 状态 | 含义 | 用户应该做什么 |
| --- | --- | --- |
| `PAIR` | 手柄正在临时开放配对 | 在系统蓝牙设置中添加 `CommunistKB-XXXX` |
| `WAIT` | 手柄正在等待当前槽位保存的电脑 | 唤醒对应电脑，并确认电脑蓝牙已打开 |
| `LINK` | 当前槽位的电脑已经连接 | 测试宏按键，或启动 AutoClipboard |

### 第一次配对

1. 全新设备，或已经清除全部配对记录的设备，会自动开放一次 120 秒配对窗口。
2. 打开电脑的蓝牙设置。
3. 选择“添加蓝牙设备”。
4. 等待手柄小屏显示 `PAIR`。
5. 在电脑上选择完整的 `CommunistKB-XXXX`。
6. 配对完成后，等待小屏显示 `LINK`。
7. 在安全的文本输入框中测试 `Enter` 或 `Ctrl+V` 宏，确认蓝牙键盘输入正常。

如果 120 秒配对窗口已经结束，按照下面的步骤从 `Settings > BLE Hosts` 重新开放配对。

### 配对第二台或第三台电脑

1. 在手柄正常状态页双击波轮中键。
2. 拨动到 `BLE Hosts`，然后单击进入。
3. 页面会显示 3 个槽位，`*` 表示当前选中的槽位。
4. 选择一个 `EMPTY` 空槽位并单击。
5. 等待小屏出现 `PAIR` 和蓝色呼吸反馈。
6. 在 120 秒内到新电脑上添加 `CommunistKB-XXXX`。

### 切换或删除已经保存的电脑

- 单击已有槽位：选择该电脑，并允许它重新连接。
- 长按已有槽位：删除该槽位保存的蓝牙 bond 和设备记录。
- 选择 `Back` 后单击：返回上一级菜单。
- 开机时按住波轮中键约 5 秒：清除全部 3 个槽位并重启。这是恢复操作，不是日常切换电脑的方法。

不要按住中键同时拨动波轮。手柄的机械结构不支持这种组合操作。
<!-- endsection -->

<!-- section:wheel -->
<!-- lang:en -->
## 6. Wheel, middle button, and Settings

The same control has different meanings on the normal status screen and inside Settings.

### Normal status screen

| Gesture | Result |
| --- | --- |
| Rotate upward | Previous Profile |
| Rotate downward | Next Profile |
| Single-click | Publish the quick-launch event for the current Profile |
| Double-click | Enter `Settings` |
| Long-press | Enter `Settings` |

Single-click quick launch works only when AutoClipboard is running and the current Profile has an application, shortcut, or HTTP/HTTPS URL assigned.

### Settings and sub-pages

| Gesture | Result |
| --- | --- |
| Rotate upward or downward | Move the selection; adjust the current value while editing |
| Single-click | Open an item, start editing, confirm, or save |
| Long-press | Cancel the current edit, return to the previous page, or exit Settings |

### Main Settings items

| Item | Purpose |
| --- | --- |
| `LCD Bright` | Screen backlight brightness |
| `Ring Bright` | Front light ring brightness |
| `Buzzer Vol` | Buzzer volume |
| `Screen Mode` | Status, compact, or backlight-off mode |
| `IMU Stream` | Enable or disable BLE IMU notifications |
| `BLE Hosts` | View, pair, switch, or delete one of three host slots |
| `Diagnostics` | View connection, IMU, battery, and button summaries |
| `Reset Settings` | Restore device settings; it does not clear Bluetooth pairing records |
<!-- lang:zh-CN -->
## 6. 波轮、中键与 Settings 设置界面

同一个波轮在“正常状态页”和“Settings 设置界面”中的作用不同。

### 正常状态页

| 手势 | 结果 |
| --- | --- |
| 向上拨动 | 切换到上一个 Profile |
| 向下拨动 | 切换到下一个 Profile |
| 单击中键 | 触发当前 Profile 的快开事件 |
| 双击中键 | 进入 `Settings` |
| 长按中键 | 也可以进入 `Settings` |

单击快开只有在 AutoClipboard 正在运行，并且当前 Profile 已经绑定应用、快捷方式或 HTTP/HTTPS 网页时才会真正打开目标。

### Settings 及其子页面

| 手势 | 结果 |
| --- | --- |
| 向上或向下拨动 | 移动当前选项；编辑状态下调整数值 |
| 单击中键 | 打开项目、开始编辑、确认或保存 |
| 长按中键 | 取消当前编辑、返回上一页或退出 Settings |

### Settings 主要项目

| 项目 | 作用 |
| --- | --- |
| `LCD Bright` | 调整小屏背光亮度 |
| `Ring Bright` | 调整正面灯环亮度 |
| `Buzzer Vol` | 调整蜂鸣器音量 |
| `Screen Mode` | 切换状态、精简或关闭背光模式 |
| `IMU Stream` | 打开或关闭 BLE IMU 推送 |
| `BLE Hosts` | 查看、配对、切换或删除 3 个主机槽位 |
| `Diagnostics` | 查看连接、IMU、电池和按键诊断摘要 |
| `Reset Settings` | 恢复设备设置；不会清除蓝牙配对记录 |
<!-- endsection -->

<!-- section:profiles -->
<!-- lang:en -->
## 7. Profiles and four macro buttons

<p align="center">
  <img src="assets/user-guide/macro-buttons.webp" alt="Four programmable macro buttons and default actions" width="660">
</p>

Each Profile stores its own four macro slots, display name, icon, and visual theme. AutoClipboard can also associate a desktop quick-launch target and fixed-click coordinates with each Profile.

### Default Vibe Coding macros

| Button | Default macro | Typical use |
| --- | --- | --- |
| EXT1 | `Right Alt` | Trigger Typeless or voice-input capture |
| EXT2 | `Enter` | Confirm, send, or insert a newline |
| EXT3 | `Ctrl+V` | Paste the current clipboard |
| EXT4 | `Ctrl+Alt+0` | User-defined application action |

### Available Profiles

The current firmware provides eight built-in Profiles—`Codex`, `GPT`, `Claude`, `DeepSeek`, `Einstein`, `Compute`, `Gauss`, and `Halo`—plus `Custom 1` through `Custom 4`.

Rotate the wheel on the normal screen to change Profile. A sound and light animation confirm the change. Names, icons, and macros can be written to the handle; computer-specific paths, URLs, and fixed screen coordinates remain in AutoClipboard on that computer.

### Halo presenter Profile

- Hold EXT1 to show the presenter Halo; release EXT1 to hide it.
- EXT2 and EXT3 are used for previous and next page by default.
- Move the handle to control the Halo while the IMU stream and AutoClipboard presenter monitor are active.
<!-- lang:zh-CN -->
## 7. Profile 与四枚宏按键

<p align="center">
  <img src="assets/user-guide/macro-buttons.webp" alt="苍虬手柄四枚可编程宏按键及默认动作" width="660">
</p>

每个 Profile 都保存自己独立的四个宏槽、显示名称、图标和视觉主题。AutoClipboard 还可以为每个 Profile 绑定电脑上的快开目标和固定点击坐标。

### 默认 Vibe Coding 宏

| 按键 | 默认宏 | 典型用途 |
| --- | --- | --- |
| EXT1 | `Right Alt` | 触发 Typeless 或语音输入捕获 |
| EXT2 | `Enter` | 确认、发送或换行 |
| EXT3 | `Ctrl+V` | 粘贴当前剪贴板内容 |
| EXT4 | `Ctrl+Alt+0` | 用户自定义的软件动作 |

### 当前 Profile

当前固件提供 8 个内置 Profile：`Codex`、`GPT`、`Claude`、`DeepSeek`、`Einstein`、`Compute`、`Gauss`、`Halo`，另有 `Custom 1`～`Custom 4` 四个自定义槽位。

在正常状态页拨动波轮即可切换 Profile，手柄会用声音和灯效动画确认切换。名称、图标和宏可以写入手柄；电脑路径、网页地址和固定屏幕坐标只保存在当前电脑的 AutoClipboard 中。

### Halo 演讲光圈 Profile

- 按住 EXT1 显示演讲光圈，松开 EXT1 隐藏。
- EXT2 和 EXT3 默认用于上一页和下一页。
- IMU 推送和 AutoClipboard 演讲监控正常运行时，移动手柄即可控制光圈。
<!-- endsection -->

<!-- section:screen-agent -->
<!-- lang:en -->
## 8. Screen, light ring, and Agent state

<p align="center">
  <img src="assets/user-guide/agent-status.webp" alt="Handle screen and Agent light status" width="650">
</p>

The screen can show:

- Current Profile name and icon.
- Bluetooth state: `LINK`, `WAIT`, or `PAIR`.
- Battery percentage, charging or power information, and time.
- Input, recording, device, and diagnostic messages.
- A top-right badge containing the number of currently working Agents. The badge disappears when the count is zero or the status expires.

The top-right number is an Agent count, not a Bluetooth host-slot number. Host slots are shown only in `Settings > BLE Hosts`.

Agent state examples include idle, working, attention, permission, blocked, done, and closed. AutoClipboard aggregates supported Agent lifecycle events and relays the state over BLE to the handle. Without AutoClipboard and a configured Hook/Bridge, the normal Bluetooth keyboard macros can still work, but Agent state will not update.
<!-- lang:zh-CN -->
## 8. 小屏、灯环与 Agent 状态

<p align="center">
  <img src="assets/user-guide/agent-status.webp" alt="苍虬手柄小屏与 Agent 状态灯" width="650">
</p>

小屏可以显示：

- 当前 Profile 名称和图标。
- 蓝牙状态：`LINK`、`WAIT` 或 `PAIR`。
- 电池百分比、充电或电源信息和时间。
- 输入、录制、设备与诊断提示。
- 右上角正在工作的 Agent 数量气泡。数量为 0 或状态超时后会自动隐藏。

右上角数字是 Agent 数量，不是蓝牙主机槽位编号。主机槽位只在 `Settings > BLE Hosts` 页面显示。

Agent 状态包括空闲、工作中、需要注意、等待授权、阻塞、完成和关闭等。AutoClipboard 会聚合受支持 Agent 的生命周期事件，再通过 BLE 把状态发送给手柄。即使没有配置 AutoClipboard 和 Hook/Bridge，普通蓝牙键盘宏仍然可能正常工作，但 Agent 状态不会更新。
<!-- endsection -->

<!-- section:autoclipboard -->
<!-- lang:en -->
## 9. Use AutoClipboard

### Main window

<p align="center">
  <img src="assets/user-guide/autoclipboard-main.webp" alt="AutoClipboard main window" width="900">
</p>

The main window shows the Bluetooth device name, connection summary, battery information, Agent state, Typeless capture status, and shortcuts to device settings or light tests.

### Device settings

<p align="center">
  <img src="assets/user-guide/autoclipboard-settings.webp" alt="AutoClipboard device settings and IMU preview" width="980">
</p>

The device settings window can provide:

- Profile selection, creation, renaming, icon configuration, and macro recording.
- Screen brightness and mode, light-ring brightness and theme, and buzzer volume.
- Battery, power, BLE, and device status.
- IMU three-dimensional preview, calibration, recording, and presenter Halo controls.
- Type-C device selection, serial diagnostics, Bluetooth repair entry points, and firmware maintenance.

Screenshots are illustrative; labels and layout may move as releases improve.

### Understand the two Bluetooth layers

1. **Bluetooth HID keyboard:** the operating system receives macro-key keyboard input. This can remain connected when AutoClipboard is closed.
2. **AutoClipboard BLE/GATT session:** the application receives status and IMU data and sends configuration. This requires AutoClipboard to be running and attached to the same physical handle.

It is therefore possible for macro buttons to type correctly while AutoClipboard is not yet ready. That symptom does not mean the Bluetooth keyboard pairing failed.
<!-- lang:zh-CN -->
## 9. 使用 AutoClipboard

### 主界面

<p align="center">
  <img src="assets/user-guide/autoclipboard-main.webp" alt="AutoClipboard 主界面" width="900">
</p>

主界面会显示蓝牙设备名称、连接摘要、电量信息、Agent 状态、Typeless 捕获状态，以及设备设置和灯效测试入口。

### 设备设置

<p align="center">
  <img src="assets/user-guide/autoclipboard-settings.webp" alt="AutoClipboard 设备设置与 IMU 预览" width="980">
</p>

设备设置窗口可以提供：

- 选择、新建、重命名 Profile，配置图标和录制宏。
- 调整小屏亮度与模式、灯环亮度与主题、蜂鸣器音量。
- 查看电池、电源、BLE 和设备状态。
- 使用 IMU 三维预览、校准、记录和演讲光圈。
- 选择 Type-C 设备，进行串口诊断、蓝牙修复和固件维护。

截图用于帮助识别功能区域；软件更新后，文字和布局可能有所调整。

### 理解两条不同的蓝牙链路

1. **蓝牙 HID 键盘：** 操作系统接收宏按键产生的键盘输入。关闭 AutoClipboard 后，这条连接仍可能保持。
2. **AutoClipboard BLE/GATT 会话：** 软件接收设备状态和 IMU 数据，并发送配置。它需要 AutoClipboard 正在运行，并连接到同一台实体手柄。

因此可能出现“宏按键能够正常打字，但 AutoClipboard 还没有就绪”的情况。这不等于系统蓝牙键盘配对失败。
<!-- endsection -->

<!-- section:agent-setup -->
<!-- lang:en -->
## 10. Configure Agent status synchronization

Basic macros require only the operating system Bluetooth keyboard connection. Agent status requires all of the following:

1. AutoClipboard is installed and running.
2. The correct `CommunistKB-XXXX` handle is paired and available to AutoClipboard.
3. The Agent has a supported lifecycle Hook or Bridge configuration.
4. The Hook writes valid local state events.
5. AutoClipboard aggregates those events and relays the current state to the handle.

The Skill is the recommended way to configure and verify this chain. Manual helpers are also available:

- [Agent status setup guide](agent-signal-setup.md)
- [`configure-agent-signal-windows.ps1`](../scripts/configure-agent-signal-windows.ps1)
- [`configure-agent-signal-linux.sh`](../scripts/configure-agent-signal-linux.sh)

After configuration, keep AutoClipboard running in the background. A working macro key alone does not prove that the Agent Hook is configured.
<!-- lang:zh-CN -->
## 10. 配置 Agent 状态同步

普通宏按键只需要操作系统的蓝牙键盘连接；Agent 状态同步则必须同时满足以下条件：

1. AutoClipboard 已经安装并保持运行。
2. 正确的 `CommunistKB-XXXX` 手柄已经配对，并能被 AutoClipboard 使用。
3. Agent 已经配置受支持的生命周期 Hook 或 Bridge。
4. Hook 能够写入有效的本地状态事件。
5. AutoClipboard 聚合这些事件，再把当前状态发送到手柄。

推荐通过 Skill 配置并验证整条链路。需要手动配置时，也可以使用：

- [Agent 状态配置指南](agent-signal-setup.md)
- [`configure-agent-signal-windows.ps1`](../scripts/configure-agent-signal-windows.ps1)
- [`configure-agent-signal-linux.sh`](../scripts/configure-agent-signal-linux.sh)

配置完成后，请让 AutoClipboard 在后台保持运行。宏按键能够使用，只能证明蓝牙键盘链路正常，不能证明 Agent Hook 已经配置完成。
<!-- endsection -->

<!-- section:firmware -->
<!-- lang:en -->
## 11. Firmware updates

V3 is the currently maintained hardware revision. Firmware packages are board-specific; never flash a package intended for another revision.

### Recommended update flow

1. Connect the handle with a data-capable USB Type-C cable.
2. Ensure Windows exposes the correct COM port; install the CH343 driver if necessary.
3. Use AutoClipboard or the Skill to identify the live board and device serial number.
4. Run a firmware check before any write.
5. Review the proposed version, package, device identity, update plan, and validation result.
6. Give a fresh explicit confirmation only when all information matches the physical device.

Normal application-only firmware updates preserve NVS settings and custom icons when performed through the validated workflow. Do not use an unrelated board package, erase the entire device, or bypass identity validation as a routine fix.
<!-- lang:zh-CN -->
## 11. 固件更新

V3 是当前持续维护的硬件版本。固件包与板型严格对应，不要刷入其他硬件版本的固件包。

### 推荐更新流程

1. 使用支持数据传输的 USB Type-C 线连接手柄。
2. 确认 Windows 已经创建正确的 COM 端口；必要时安装 CH343 驱动。
3. 通过 AutoClipboard 或 Skill 识别实时板型和设备序列号。
4. 在任何写入之前先执行固件检查。
5. 阅读将要更新的版本、固件包、设备身份、更新方案和校验结果。
6. 只有全部信息都与手中的实体设备一致时，才进行一次新的明确确认。

通过经过验证的流程执行普通 app-only 固件更新时，会保留 NVS 设置和自定义图标。不要把其他板型的固件、整片擦除或绕过身份校验当作日常修复方式。
<!-- endsection -->

<!-- section:troubleshooting -->
<!-- lang:en -->
## 12. Troubleshooting

### The Bluetooth device is not visible

1. Wake or power on the handle.
2. Check whether the screen shows `WAIT` instead of `PAIR`.
3. Double-click the wheel, open `Settings > BLE Hosts`, choose `EMPTY`, and single-click.
4. Wait for `PAIR` before scanning again.
5. Keep the computer close to the handle and temporarily stop scanning from other nearby computers.
6. If all three slots are occupied, delete one saved slot only after confirming which host record is no longer needed.

### The device is paired, but macro buttons do not type

1. Confirm the screen shows `LINK`.
2. Test inside a safe plain-text editor.
3. Switch to a Profile whose macros are known, such as the default Vibe Coding Profile.
4. Verify the target application accepts `Enter`, `Ctrl+V`, or the configured shortcut.
5. Ask the Skill to inspect the real device identity and Bluetooth state before deleting pairings.

### Macro buttons work, but AutoClipboard says disconnected

The HID keyboard layer and the AutoClipboard GATT session are separate.

1. Start or restart AutoClipboard.
2. Keep the handle awake and close to the computer.
3. Confirm AutoClipboard is targeting the same `CommunistKB-XXXX` name.
4. Run the Skill's read-only inventory and doctor checks.
5. Do not repeatedly remove the Windows Bluetooth device merely because the application session is not ready.

### Type-C is connected, but there is no COM port

1. Replace the cable with a known data-capable cable.
2. Try another direct USB port instead of a hub.
3. Open Windows Device Manager and check for an unknown or CH343/WCH serial device.
4. Follow the [CH343 driver installation and troubleshooting guide](ch343-driver-installation.md).
5. Reconnect the handle and reopen AutoClipboard device settings.

### Agent status does not appear

1. Confirm AutoClipboard is running.
2. Confirm the handle is available to the application, not only paired as a keyboard.
3. Run Agent Bridge doctor through the Skill.
4. Review and approve supported Hook configuration when the agent client requires user trust.
5. Generate a real Agent lifecycle event and check whether the screen or light ring changes.

### Profile single-click does not open anything

1. Confirm this is a single-click on the normal status screen, not inside Settings.
2. Confirm AutoClipboard is running.
3. Assign an application, shortcut, or HTTP/HTTPS URL to the current Profile.
4. Single-click again and verify the target still exists on the current computer.

### The handle sleeps or disconnects after inactivity

The device may use screen timeout or Deep Sleep. Move or pick up the handle to wake it. Deep Sleep temporarily disconnects Bluetooth and then reconnects to the selected saved host after wake. It does not delete pairing records.

### Recommended request to an agent

> Use the `ai-coding-handle` Skill to diagnose my handle. First identify the real device, Bluetooth name, board revision, AutoClipboard version, serial availability, and Agent Hook status. Keep the diagnosis read-only. Explain the failing layer before asking me to reset pairing, reset Bluetooth, or update firmware.
<!-- lang:zh-CN -->
## 12. 故障排查

### 系统蓝牙列表里找不到设备

1. 打开或唤醒手柄。
2. 查看小屏当前是 `WAIT` 还是 `PAIR`。
3. 双击波轮进入 `Settings > BLE Hosts`，选择 `EMPTY` 后单击。
4. 等小屏显示 `PAIR` 后再重新扫描。
5. 让电脑靠近手柄，并暂时停止附近其他电脑的扫描。
6. 如果 3 个槽位都已经保存主机，先确认哪台电脑不再需要，再删除对应槽位。

### 已经配对，但宏按键无法输入

1. 确认小屏显示 `LINK`。
2. 在安全的纯文本编辑器里测试。
3. 切换到宏配置明确的 Profile，例如默认 Vibe Coding Profile。
4. 确认目标软件能够接收 `Enter`、`Ctrl+V` 或当前配置的快捷键。
5. 删除配对之前，先让 Skill 核对真实设备身份和蓝牙状态。

### 宏按键正常，但 AutoClipboard 显示未连接

蓝牙 HID 键盘层和 AutoClipboard 使用的 GATT 会话是两条不同链路。

1. 启动或重新启动 AutoClipboard。
2. 保持手柄唤醒，并让它靠近电脑。
3. 确认 AutoClipboard 正在查找同一个 `CommunistKB-XXXX`。
4. 让 Skill 执行只读的 inventory 和 doctor 检查。
5. 不要仅仅因为软件会话没有就绪，就反复删除 Windows 蓝牙设备。

### 已经插入 Type-C，但没有 COM 端口

1. 更换确认支持数据传输的线缆。
2. 尝试电脑上的其他直连 USB 接口，不要先经过扩展坞。
3. 打开 Windows 设备管理器，查找未知设备或 CH343/WCH 串口设备。
4. 按照[CH343 驱动安装与排障指南](ch343-driver-installation.zh-CN.md)操作。
5. 重新插拔手柄，再重新打开 AutoClipboard 设备设置。

### 手柄没有显示 Agent 状态

1. 确认 AutoClipboard 正在运行。
2. 确认软件能够使用手柄，而不只是系统把它配对成了蓝牙键盘。
3. 通过 Skill 运行 Agent Bridge doctor。
4. 如果 Agent 客户端要求用户信任 Hook，请检查并批准受支持的 Hook 配置。
5. 触发一次真实的 Agent 生命周期事件，再观察小屏和灯环是否变化。

### 单击波轮不能打开应用

1. 确认是在正常状态页单击，而不是在 Settings 中单击。
2. 确认 AutoClipboard 正在运行。
3. 为当前 Profile 绑定一个应用、快捷方式或 HTTP/HTTPS 网页。
4. 再次单击，并确认这个目标在当前电脑上仍然存在。

### 手柄空闲后休眠或断开

设备可能启用了自动熄屏或 Deep Sleep。移动或拿起手柄可以唤醒。Deep Sleep 会暂时断开蓝牙，唤醒后再连接当前选中的已保存主机，但不会删除配对记录。

### 推荐发给大模型的排障请求

> 请使用 `ai-coding-handle` Skill 排查我的手柄。先核对真实设备、蓝牙名称、板型、AutoClipboard 版本、串口状态和 Agent Hook，以只读方式诊断。请先解释是哪一层失败，再询问我是否需要删除配对、重置蓝牙或更新固件。
<!-- endsection -->

<!-- section:support -->
<!-- lang:en -->
## 13. Information to include when requesting help

Providing precise information avoids destructive guesswork. Include:

- Operating system and version.
- Complete Bluetooth name, such as `CommunistKB-A216`.
- What the handle screen shows: `LINK`, `WAIT`, or `PAIR`.
- Whether macro buttons type in a plain-text editor.
- Whether AutoClipboard shows the same device name.
- AutoClipboard version.
- Board revision and firmware version, when available.
- Whether a Type-C COM port is present.
- The exact step that failed and any screenshot of that step.

Do not publish private logs, credentials, account tokens, or unrelated personal information.

## Related documents

- [Repository home and quick start](../README.en.md)
- [Agent status setup](agent-signal-setup.md)
- [Windows CH343 driver guide](ch343-driver-installation.md)
- [AI Coding Handle Skill](../skills/ai-coding-handle)
- [Product introduction website](https://shenqiqishi.github.io/zko_page/)
<!-- lang:zh-CN -->
## 13. 请求帮助时应该提供什么信息

信息越准确，越不容易因为猜测而执行不必要的删除或重置。建议提供：

- 操作系统及版本。
- 完整蓝牙名称，例如 `CommunistKB-A216`。
- 手柄小屏显示的是 `LINK`、`WAIT` 还是 `PAIR`。
- 宏按键能否在纯文本编辑器中正常输入。
- AutoClipboard 是否显示同一个设备名称。
- AutoClipboard 版本。
- 能够读取时，提供板型和固件版本。
- Type-C 连接后是否出现 COM 端口。
- 具体失败的步骤，以及该步骤的截图。

不要公开私人日志、账号凭证、访问令牌或与问题无关的个人信息。

## 相关文档

- [仓库首页与快速开始](../README.md)
- [Agent 状态配置指南](agent-signal-setup.md)
- [Windows CH343 驱动指南](ch343-driver-installation.zh-CN.md)
- [AI Coding Handle Skill](../skills/ai-coding-handle)
- [苍虬产品介绍网页](https://shenqiqishi.github.io/zko_page/)
<!-- endsection -->
