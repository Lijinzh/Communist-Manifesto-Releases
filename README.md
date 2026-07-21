<!-- Generated from docs/README.bilingual.md by scripts/sync_readmes.py. Do not edit directly. -->

**简体中文** | [English](README.en.md)

# 苍虬 · AI 编程手柄

> 写代码，不用再低头找快捷键。

苍虬 AI 编程手柄把 4 枚可编程宏按键、彩色小屏、Agent 状态灯环、蓝牙键盘、姿态感应和 AutoClipboard 桌面软件结合在一起，适合 AI 编程、语音输入、Codex、Claude Code、演讲展示等需要保持专注的工作流。

<p align="center">
  <img src="docs/assets/user-guide/handle-hero.webp" alt="苍虬 AI 编程手柄产品概览" width="720">
</p>

> 图片中的 DJI 麦克风仅作为使用场景和可替换配件展示，不包含在手柄包装内。

本仓库是 AutoClipboard、手柄固件、驱动程序、公开文档和开源 AI Coding Handle Skill 的正式下载入口。

## 首先推荐：让大模型安装 Skill

如果你正在使用 Codex、Claude Code、OpenCode 或其他支持 Agent Skills 的客户端，建议在手动配置之前，先安装 **AI Coding Handle Skill**。它可以帮助选择并安装合适的 AutoClipboard、配置受支持的 Agent 状态 Hook、识别 D4/V3 硬件，并以只读方式检查 USB、串口、蓝牙和软件状态。

```bash
npx skills add Lijinzh/Communist-Manifesto-Releases --skill ai-coding-handle -g
```

也可以直接把下面这段话发给大模型：

> 请安装并使用 `Lijinzh/Communist-Manifesto-Releases` 中的 `ai-coding-handle` Skill，帮我安装或检查 AutoClipboard，并以只读方式排查苍虬手柄为什么无法连接蓝牙。

Skill 可以自动完成检查，但不会静默重置系统蓝牙或擅自刷写固件。任何固件更新仍然需要针对当前设备和更新方案进行单独、明确的确认。

没有可用的大模型客户端也没有关系，可以继续按照下面的手动步骤操作，或直接阅读[完整中文使用说明书](docs/user-guide.zh-CN.md)。

## 5 分钟完成首次使用

1. **使用 Skill 安装，或手动下载 AutoClipboard。** Windows 是当前主要支持平台；请从[最新 Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)下载与你的系统相符的安装包。
2. **先给手柄充电。** 使用合适的线缆连接 USB Type-C 接口。串口诊断和固件更新必须使用支持数据传输的线，只有充电功能的线无法完成这些操作。
3. **打开或唤醒手柄。** 全新设备或已经清除配对的设备会开放 120 秒蓝牙配对窗口。
4. **连接正确的蓝牙设备。** 在系统蓝牙设置中选择完整名称 `CommunistKB-XXXX`。末尾 4 位编号由手柄自动生成，用户不需要自己输入或追加后缀。
5. **启动 AutoClipboard，并让它在后台运行。** 基础蓝牙键盘宏可以脱离软件使用；Agent 状态、小屏时间、IMU 预览、深度配置和 Profile 快开需要 AutoClipboard。
6. **测试操作。** 上下拨动波轮切换 Profile，按一下宏按键，再双击波轮中键进入 `Settings`。

需要查看图片、连接多台电脑、了解 Profile 或排查问题时，请继续阅读[完整中文使用说明书](docs/user-guide.zh-CN.md)。

## 认识手柄硬件

<p align="center">
  <img src="docs/assets/user-guide/usb-type-c-interface.jpg" alt="苍虬手柄 USB Type-C 接口" width="760">
</p>

照片左侧的 USB Type-C 接口用于充电、串口通信、图标传输、设备诊断和固件更新。日常使用只需要按照说明连接 Type-C 接口；旁边可见的板上部件不属于普通用户需要操作的日常接口。

| 部件 | 作用 |
| --- | --- |
| USB Type-C 接口 | 充电；使用数据线进行串口诊断和固件更新 |
| 1.14 英寸彩色小屏 | 显示 Profile、蓝牙状态、电量、时间、Agent 状态和设备提示 |
| 波轮和中键 | 切换 Profile、移动菜单、确认选项，以及进入或退出设置 |
| 侧面 4 枚宏按键 | 执行当前 Profile 中保存的快捷键宏 |
| 正面灯环 | 显示 Agent 状态、Profile、输入反馈和警告提示 |
| 内置 IMU 姿态传感器 | 用于三维姿态预览和演讲光圈 |

<p align="center">
  <img src="docs/assets/user-guide/macro-buttons.webp" alt="苍虬手柄四枚可编程宏按键" width="620">
</p>

默认的 Vibe Coding Profile 将四枚按键设置为 `Right Alt`、`Enter`、`Ctrl+V` 和 `Ctrl+Alt+0`。这四个按键都可以在 AutoClipboard 中重新配置。

## 蓝牙名称与配对

当前固件的蓝牙广播名称固定为：

```text
CommunistKB-XXXX
```

`XXXX` 是 ESP32 MAC 地址最后 2 个字节生成的 4 位大写十六进制编号。例如某台手柄可能显示为 `CommunistKB-A216`。这个编号已经包含在系统扫描到的完整名称中，用户不需要自己添加后缀。

### 第一次配对

1. 打开 Windows、Linux 或 macOS 的蓝牙设置，选择“添加设备”。
2. 打开或唤醒手柄。
3. 等待小屏显示 `PAIR`。
4. 在电脑上选择完整的 `CommunistKB-XXXX` 名称。
5. 配对完成并建立连接后，小屏会显示 `LINK`。

### 连接第二台或第三台电脑

1. 双击波轮中键进入 `Settings`。
2. 拨动到 `BLE Hosts`，单击进入。
3. 选择一个 `EMPTY` 空槽位并单击。
4. 看到 `PAIR` 后，在新电脑的蓝牙设置中添加 `CommunistKB-XXXX`。

手柄可以保存 3 个主机槽位。在 `BLE Hosts` 页面中，单击已有槽位可以切换到该电脑，长按已有槽位可以删除该主机记录。

## 波轮与小屏操作

### 在正常状态页

| 操作 | 结果 |
| --- | --- |
| 向上或向下拨动 | 切换上一个或下一个 Profile |
| 单击中键 | 打开当前 Profile 绑定的应用、快捷方式或网页；需要 AutoClipboard 在后台运行 |
| 双击中键 | 进入 `Settings` |
| 长按中键 | 也可以进入 `Settings` |

### 在 Settings 设置界面

| 操作 | 结果 |
| --- | --- |
| 向上或向下拨动 | 移动选项；编辑时调整数值 |
| 单击中键 | 进入、开始编辑、确认或保存当前项目 |
| 长按中键 | 取消编辑、返回上一级或退出设置 |

不要尝试“按住中键同时拨动波轮”。机械结构不支持这种组合动作，蓝牙主机切换也不使用这种操作。

## 看懂小屏与 Agent 状态灯

<p align="center">
  <img src="docs/assets/user-guide/agent-status.webp" alt="苍虬手柄 Agent 状态灯和小屏" width="620">
</p>

上图用于展示整体视觉效果；当前固件的小屏蓝牙状态以以下短文字为准：

| 小屏文字 | 含义 |
| --- | --- |
| `LINK` | 已经连接当前选中的电脑 |
| `WAIT` | 正在等待已保存的电脑重新连接 |
| `PAIR` | 已临时开放，可以添加新的蓝牙主机 |

小屏还会显示当前 Profile、电量、时间、设备状态和正在工作的 Agent 数量。灯环可以反馈空闲、工作中、需要注意、等待授权、阻塞和完成等状态。Agent 状态同步需要 AutoClipboard 和已经配置好的 Agent Hook/Bridge。

## AutoClipboard 桌面软件

AutoClipboard 是手柄的配套桌面软件，可以显示当前连接的蓝牙设备，配置 Profile 名称和图标，录制宏按键，调整小屏、灯环和蜂鸣器，查看 IMU 三维姿态，配置演讲光圈，并在受控流程中更新固件。

<p align="center">
  <img src="docs/assets/user-guide/autoclipboard-main.webp" alt="AutoClipboard 主界面" width="820">
</p>

<p align="center">
  <img src="docs/assets/user-guide/autoclipboard-settings.webp" alt="AutoClipboard 设备设置界面" width="900">
</p>

这里展示的是当前真实界面。需要查看编号分区图、逐个控件的作用，以及“只改软件”和“会写入硬件”的明确区别，请阅读 [AutoClipboard 软件界面详细说明书](docs/software-interface-manual/README.md)。使用 Agent 状态同步、Profile 快开、IMU 预览或演讲光圈时，请让 AutoClipboard 保持后台运行。

## 下载文件

打开[最新 GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)，根据系统或用途选择文件：

| 用途 | 文件名格式 |
| --- | --- |
| Windows 软件 | `AutoClipboardSetup-<version>.exe` |
| Windows CH343 USB 串口驱动 | `CH343SER.EXE` |
| Linux / Ubuntu 软件 | `auto-clipboard_<version>_<arch>.deb` |
| 该版本提供 macOS 包时 | `AutoClipboard-<version>-macOS.dmg` |
| 当前 V3 手柄固件 | `CommunistManifestoKB-firmware-v3-<version>.zip` |
| AI Coding Handle Skill 压缩包 | `ai-coding-handle-skill-<version>.zip` |

V3 是当前持续维护的硬件版本。不要给设备刷入其他板型的固件。如果不能确定板型，请先让 Skill 识别设备，再下载或更新固件。

## 快速排障

- **系统里找不到 `CommunistKB-XXXX`：** 唤醒手柄，双击波轮进入 `Settings > BLE Hosts`，选择 `EMPTY`，等小屏出现 `PAIR` 后重新扫描。
- **系统已经配对，但 AutoClipboard 没有就绪：** 保持手柄唤醒，启动 AutoClipboard，再让 Skill 执行只读的 `inventory` 和 `doctor` 检查。
- **宏按键能用，但没有 Agent 状态：** 说明蓝牙键盘连接已经正常；还需要配置 Agent Hook/Bridge，并保持 AutoClipboard 运行。
- **Type-C 连接后没有 COM 端口：** 更换支持数据的线缆和 USB 接口，并查看[CH343 Windows 驱动安装指南](docs/ch343-driver-installation.zh-CN.md)。
- **软件提示更新固件：** 确认当前设备是 V3，并阅读准确的更新方案后再确认。

更多现象和逐步检查方法见[完整说明书的故障排查章节](docs/user-guide.zh-CN.md#12-故障排查)。

## 使用文档

- [完整中文使用说明书](docs/user-guide.zh-CN.md)
- [English user guide](docs/user-guide.en.md)
- [Agent 状态同步配置](docs/agent-signal-setup.md)
- [Windows CH343 驱动安装与排障](docs/ch343-driver-installation.zh-CN.md)
- [开源 AI Coding Handle Skill](skills/ai-coding-handle)
- [苍虬产品介绍网页](https://shenqiqishi.github.io/zko_page/)

本仓库包含公开发布文件、面向用户的文档、支持脚本以及采用 MIT License 的 AI Coding Handle Skill。AutoClipboard 和手柄固件的应用源码仍为私有内容。
