<!-- section:s001 -->
# 5 分钟快速开始

目标：在不刷写固件、不删除配对记录的情况下，确认手柄的蓝牙键盘输入和 AutoClipboard 安装正常。

<!-- section:s002 -->
## 1. 选择并安装桌面软件

| 系统 | 安装包 | 说明 |
| --- | --- | --- |
| Windows x64 | `AutoClipboardSetup-<版本>.exe` | 从 ZKO 官网优先使用 Gitee 下载，GitHub 作为备用 |
| Ubuntu/Linux amd64 | `auto-clipboard_<版本>_amd64.deb` | 只在对应 Release 已提供该资产时下载 |
| macOS | `AutoClipboard-<版本>-macOS.dmg` | 只把已签名、公证的正式 DMG 视为正式版本；预览包会明确标注 |

安装完成的成功标志是系统应用列表中出现 AutoClipboard。暂时不要进入固件更新页面。

<!-- section:s003 -->
## 2. 唤醒手柄并选择主机槽位

1. 给手柄供电并唤醒屏幕。
2. 如果是全新设备或当前槽位为空，小屏会进入 `PAIR`。
3. 如果槽位已经保存过这台电脑，小屏可能显示 `WAIT`，随后自动连接。
4. 需要主动选择槽位时，进入 `Settings > BLE Hosts`，选择目标 `SAVED` 或 `EMPTY` 槽位。

不要把“开机时长按中键清空全部槽位”当作普通连接步骤。

<!-- section:s004 -->
## 3. 在系统蓝牙中配对

1. 打开系统蓝牙设置。
2. 找到完整名称 `CommunistKB-XXXX`；末尾四位是设备标识的一部分。
3. 添加设备并等待小屏显示 `LINK`。
4. 如果电脑保留了旧密钥而手柄槽位已清除，应先在系统中忽略旧设备，再重新配对。

<!-- section:s005 -->
## 4. 验证基础输入

打开记事本、TextEdit 或其他纯文本编辑器：

1. 按一个配置为 `Enter` 或 `Ctrl+V` 的宏键。
2. 确认编辑器收到对应输入。
3. 如果宏键正常，说明 HID 蓝牙键盘链路已经可用。

宏键正常但 AutoClipboard 显示未连接并不矛盾：HID 输入与应用读取状态使用不同的蓝牙链路。

<!-- section:s006 -->
## 5. 启动 AutoClipboard

启动软件后按需求继续：

- 只使用宏键：软件可以不常驻。
- 使用 Profile 快开、设备设置、IMU 预览、Agent 状态、语音或演讲光圈：保持软件运行。
- Windows 插入数据线后没有 COM 端口：阅读 [CH343 驱动指南](../ch343-driver-installation.md)。

<!-- section:s007 -->
## 失败时先做什么

- 没有设备名：确认手柄处于 `PAIR`，再重新扫描。
- 显示 `WAIT`：选择正确的已保存槽位，并打开对应电脑蓝牙。
- 显示 `LINK` 但不能输入：换纯文本编辑器测试，确认当前 Profile 的宏定义。
- 软件打不开：重新校验安装包来源、文件大小和 SHA-256，不要直接刷固件。
- 仍未解决：进入 [常见任务教程](../guides-and-tutorials/common-workflows.md) 或 [完整故障排查](../user-guide.md#12-故障排查)。
