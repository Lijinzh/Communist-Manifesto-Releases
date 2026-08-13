<!-- section:s001 -->
# Using

这一板块面向已经完成首次连接的用户，解释如何把手柄、AutoClipboard 和 AI Agent 组合成稳定的日常工作流。

<!-- section:s002 -->
## 日常任务

- [日常使用工作流](daily-workflow.md)
- [完整硬件与软件说明](../user-guide.md)
- [AutoClipboard 界面逐区说明](../software-interface-manual.md)
- [Agent 状态同步配置](../agent-signal-setup.md)

<!-- section:s003 -->
## 使用时要区分的三层

1. **HID 输入层**：宏键向系统发送键盘快捷键；连接成功后不依赖 AutoClipboard 常驻。
2. **设备控制层**：AutoClipboard 通过设备状态、命令和 IMU 特征读取状态、修改设置。
3. **Agent 工作流层**：Codex、Claude Code 等客户端通过 Hook 把工作状态送到 AutoClipboard，再同步到手柄。

一层正常不代表其他层一定正常。排障时先确认失败发生在哪一层。

<!-- section:s004 -->
## 推荐习惯

- 为不同场景建立独立 Profile，不要让一个 Profile 承担所有快捷键。
- 修改宏后先在纯文本编辑器中验证，再用于 IDE、终端或演示软件。
- 多主机切换时先在手柄上选择槽位，再操作目标电脑。
- 升级前保留设置快照；应用更新不应擦除 Profile、快开和个人设置。
- 只有明确需要时才进入 Maintenance、蓝牙修复或固件更新。

<!-- section:s005 -->
## 下一步

- 学习端到端场景：[Guides and Tutorials](../guides-and-tutorials/index.md)
- 理解功能设计：[Features](../features/index.md)
- 查找状态和兼容性：[Reference](../reference/index.md)
