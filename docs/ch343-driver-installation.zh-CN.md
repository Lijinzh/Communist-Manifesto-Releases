[English](ch343-driver-installation.md) | **简体中文**

# CH343 Windows 串口驱动安装指南

CH343SER 是南京沁恒微电子（WCH）提供的 Windows USB 转串口驱动。苍虬手柄通过 Type-C 连接 Windows 后，如果设备管理器没有出现可用的 COM 端口、显示未知设备，或者 AutoClipboard 无法发现串口，可以安装此驱动。

Windows 已经自动识别出手柄 COM 端口时，不需要重复安装。

## 下载

- 本仓库稳定下载：[CH343SER.EXE](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/download/v0.3.48/CH343SER.EXE)
- WCH 官方页面：[CH343SER Windows 驱动](https://www.wch.cn/downloads/CH343SER_EXE.html)

本仓库文件校验信息：

| 项目 | 值 |
| --- | --- |
| 文件名 | `CH343SER.EXE` |
| 文件大小 | `696288` 字节 |
| SHA-256 | `99f16f9c4cf9c315dc9a17b29021d82d522014ecc053d9ee1c7b38c214dea40b` |
| 数字签名 | 有效 |
| 签名者 | `Nanjing Qinheng Microelectronics Co., Ltd.` |

不要从不明网盘、聊天附件或第三方驱动站下载同名程序。运行前可右键文件，打开“属性 → 数字签名”，确认签名有效且签名者为南京沁恒微电子。

## 安装步骤

1. 退出正在使用手柄串口的 AutoClipboard、串口调试器和烧录工具。
2. 下载 `CH343SER.EXE`。
3. 双击运行；如果 Windows 显示用户账户控制提示，确认发布者为南京沁恒微电子后选择“是”。
4. 在驱动安装窗口中选择安装，等待成功提示。不要在安装过程中强制关闭程序。
5. 拔下并重新连接手柄 Type-C 数据线。如果安装程序要求重启 Windows，请先重启。
6. 打开设备管理器，展开“端口（COM 和 LPT）”，确认出现带 `CH343`、`USB-SERIAL` 或 WCH 标识的 COM 端口。
7. 启动 AutoClipboard，重新打开设备设置或固件更新页面。

## 使用 PowerShell 检查串口

打开 PowerShell，运行：

```powershell
Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Name, PNPDeviceID
```

正常情况下会看到类似 `COM10` 的 `DeviceID`，名称中通常包含 `CH343`、`USB-SERIAL` 或 WCH 设备标识。实际 COM 编号由 Windows 分配，不要照抄示例端口。

## 常见问题

### 安装后仍然没有 COM 端口

- 确认使用的是支持数据传输的 Type-C 线，而不是只能充电的线。
- 更换电脑上的 USB 端口，优先直接连接电脑，不要先经过无供电 Hub。
- 在设备管理器中执行“扫描检测硬件改动”。
- 拔插手柄后重新检查“端口（COM 和 LPT）”和“其他设备”。
- 如果安装程序要求重启，完成重启后再连接手柄。
- 仍然失败时，记录设备管理器中的硬件 ID 和错误代码，再进行诊断。

### AutoClipboard 仍然找不到设备

- 关闭可能占用同一 COM 端口的串口助手、PlatformIO Monitor、Arduino Serial Monitor 等程序。
- 关闭并重新启动 AutoClipboard。
- 固件更新时只连接一台目标手柄，Skill 和 AutoClipboard 不会在多个设备之间擅自选择。

### 如何卸载

在设备管理器中找到对应的 CH343/WCH 串口设备，右键选择“卸载设备”。如果 Windows 提供“删除此设备的驱动程序”选项，只有在确实希望移除驱动包时才勾选。重新插入设备后，Windows 可能再次自动安装驱动。

## 作用范围

此驱动只负责 Windows USB 串口识别。它不会完成 BLE 配对，不会安装 AutoClipboard，也不会自动刷写手柄固件。固件更新仍需由 AutoClipboard 或 AI Coding Handle Skill 识别正确的 D4/V3 设备，并在用户明确确认后执行。
