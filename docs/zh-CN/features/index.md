<!-- section:s001 -->
# Features

这一板块解释 ZKO 字库系统“有什么、如何组合、哪些事情不会自动发生”。它适合选型、培训和排障前建立共同认识。

<!-- section:s002 -->
## 能力地图

- [系统能力总览](system-overview.md)
- [完整硬件使用说明](../user-guide.md#3-硬件结构介绍)
- [AutoClipboard 界面与设置](../software-interface-manual.md)
- [AI Coding Handle Skill](../../../skills/ai-coding-handle/SKILL.md)

<!-- section:s003 -->
## 产品组成

| 组成 | 主要职责 |
| --- | --- |
| V3 手柄 | HID 输入、小屏、灯环、波轮、宏键、BLE 设备状态和 IMU |
| AutoClipboard | 设备连接、Profile、快开、Agent Dashboard、语音、IMU 预览和更新 |
| AI Coding Handle Skill | 帮助 Agent 安装、诊断、检查版本并执行受控维护流程 |
| Release 与 `latest.json` | 提供经过校验的平台安装包、固件、Skill 和更新元数据 |
| ZKO 官网 | 提供产品入口、国内优先下载和文档导航 |

<!-- section:s004 -->
## 设计原则

- 键盘输入优先，状态和界面故障不能拖垮 HID。
- 破坏性或会写入硬件的动作必须比普通设置更明确。
- 平台安装包必须由对应操作系统原生构建和验证。
- 发布资产必须有准确文件名、大小、SHA-256 和公开下载证据。
- 用户设置、蓝牙 bonds、NVS 和图标在正常升级中默认保留。

<!-- section:s005 -->
## 继续阅读

- 想完成具体任务：[Guides and Tutorials](../guides-and-tutorials/index.md)
- 想集成或贡献：[Developer Guide](../developer-guide/index.md)
- 想查精确状态：[Reference](../reference/index.md)
