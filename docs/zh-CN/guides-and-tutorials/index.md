<!-- section:s001 -->
# Guides and Tutorials

这里按“我要完成什么”组织内容。每个教程都给出起点、步骤、成功标志和不应该顺手执行的高风险动作。

<!-- section:s002 -->
## 常用教程

- [常见工作流教程合集](common-workflows.md)
- [完整故障排查](../user-guide.md#12-故障排查)
- [Agent 状态同步配置](../agent-signal-setup.md)
- [Windows CH343 驱动安装](../ch343-driver-installation.md)
- [AutoClipboard 安全操作顺序](../software-interface-manual.md#11-推荐的安全操作顺序)

<!-- section:s003 -->
## 按目标选择

| 目标 | 起点 |
| --- | --- |
| 在三台电脑之间切换 | `Settings > BLE Hosts`，选择 `SAVED` 或 `EMPTY` |
| 宏键正常但软件未连接 | 分开检查 HID 和应用 GATT 链路 |
| 在手柄上显示 Agent 工作状态 | AutoClipboard 后台运行并安装 Agent Hook |
| 更新桌面软件而不丢设置 | 先确认设置快照和正式安装包校验 |
| 更新 V3 固件 | 先确认设备身份、串口、板型和包校验 |
| Type-C 连接后没有 COM 口 | 先检查数据线和设备管理器，再安装 CH343 驱动 |

<!-- section:s004 -->
## 排障原则

1. 先记录现象和当前状态，再改变系统。
2. 先做只读检查，再做可逆修改。
3. 不把重新安装、删除配对、清空设置或刷固件当作第一步。
4. 每次只改变一个变量，并记录成功标志。
5. 无法唯一确认设备身份时停止写入操作。

<!-- section:s005 -->
## 需要帮助时

提供操作系统、AutoClipboard 版本、手柄完整名称后四位、屏幕状态、是否能发送宏、是否有 COM 端口，以及错误截图。不要发送 Token、激活码明文、供应商密钥或私人 Agent 会话内容。
