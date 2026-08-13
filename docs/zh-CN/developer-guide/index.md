<!-- section:s001 -->
# Developer Guide

这一板块面向文档贡献者、Skill 维护者、AutoClipboard/固件开发者和发布协调者。公开发布仓库与受权限控制的主开发仓库职责不同，请先确认你正在修改哪一层。

<!-- section:s002 -->
## 仓库职责

| 仓库 | 内容 | 典型修改 |
| --- | --- | --- |
| `Communist-Manifesto` | AutoClipboard、V3 固件、测试和开发规格 | 功能、修复、构建、实机验证 |
| `Communist-Manifesto-Releases` | 双语文档、Skill、发布脚本、Release 证据 | 文档、Skill、发布聚合和镜像 |
| `zko_page` | ZKO 官网静态页面 | 下载入口、产品说明、文档中心和账户入口 |

<!-- section:s003 -->
## 开发入口

- [贡献与验证流程](contributing.md)
- [Skill 技术参考](../../../skills/ai-coding-handle/references/zh-CN/platform-installation.md)
- [开发固件刷写](../../../skills/ai-coding-handle/references/zh-CN/development-flashing.md)
- [Maintenance 协议](../../../skills/ai-coding-handle/references/zh-CN/maintenance-contract.md)
- [Agent Bridge 协议](../../../skills/ai-coding-handle/references/zh-CN/agent-bridge-contract.md)
- [双平台发布维护](../maintainers/gitee-publishing.md)

<!-- section:s004 -->
## 核心约束

- Python 子项目使用仓库锁定的 `uv` 环境。
- 当前维护固件板型是 V3；D4 只保留历史追溯。
- 不随意改变 BLE UUID、设备名规则或 HID descriptor。
- GATT 回调、串口循环和 HID 回调中不执行耗时工作。
- 代码、文档、测试和发布证据必须区分 automated、fixture、full-download 与 physical-live。
- 文档中英文成对修改，目录路径和章节 ID 完全一致。

<!-- section:s005 -->
## 完成标准

一个开发任务只有在适用的源码测试、构建、打包后 smoke、实机闭环、文档更新和远端一致性检查完成后，才可以声称完成。无法执行的验证必须明确记录阻塞证据。
