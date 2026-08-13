<!-- section:s001 -->
# Reference

Reference 用于查精确信息，不按首次使用顺序讲解。需要逐步操作时，请返回 Getting Started 或 Guides and Tutorials。

<!-- section:s002 -->
## 参考入口

- [兼容性与状态参考](compatibility-and-status.md)
- [Agent Bridge 协议](../../../skills/ai-coding-handle/references/zh-CN/agent-bridge-contract.md)
- [Maintenance 协议](../../../skills/ai-coding-handle/references/zh-CN/maintenance-contract.md)
- [平台安装参考](../../../skills/ai-coding-handle/references/zh-CN/platform-installation.md)
- [开发固件刷写](../../../skills/ai-coding-handle/references/zh-CN/development-flashing.md)
- [Skill 故障排查](../../../skills/ai-coding-handle/references/zh-CN/troubleshooting.md)

<!-- section:s003 -->
## 发布与下载参考

- [最新 GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest)
- [Gitee 国内 Release](https://gitee.com/shan-yujun/Communist-Manifesto-Releases/releases)
- [GitHub/Gitee 发布维护](../maintainers/gitee-publishing.md)
- [历史版本说明](../maintainers/releases/v0.3.68.md)

<!-- section:s004 -->
## 快速术语

| 术语 | 含义 |
| --- | --- |
| HID | 操作系统看到的蓝牙键盘输入链路 |
| GATT | AutoClipboard 读取状态、IMU 和发送设备命令的 BLE 服务链路 |
| Profile | 一组宏键、显示、灯效和快开目标配置 |
| Host slot | 手柄保存的一个蓝牙主机槽位，共三个 |
| app-only | 只写固件应用区的更新，不写 bootloader/partitions |
| `latest.json` | 描述更新角色、版本、URL、大小和 SHA-256 的元数据 |

<!-- section:s005 -->
## 参考内容的更新原则

动态版本、下载地址、文件大小和校验值必须从当前正式 Release 或 `latest.json` 核对，不能只依赖旧文档示例。硬件端口、设备身份和连接状态也必须在操作当时重新确认。
