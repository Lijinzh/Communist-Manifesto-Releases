<!-- section:s001 -->
# 日常使用工作流

下面是一套适合日常编程、文字输入和演示的稳定顺序。它把“连接、选择场景、开始工作、结束工作”拆开，便于定位异常。

<!-- section:s002 -->
## 开始工作

1. 唤醒手柄，确认电量和当前 Profile。
2. 小屏显示 `LINK` 后，在纯文本框快速测试一个宏。
3. 需要设备设置、Agent 状态、语音、IMU 或演讲光圈时，再启动 AutoClipboard。
4. 确认 AutoClipboard 连接的是同一个 `CommunistKB-XXXX`。

<!-- section:s003 -->
## 选择 Profile 和宏

- 用波轮切换 Profile。
- 四枚宏键发送当前 Profile 保存的快捷键。
- 单击波轮中键可启动 Profile 绑定的应用、快捷方式或网页。
- 修改宏、名称、图标或快开目标后，确认设置已保存，再切换 Profile 复测。

涉及删除 Profile、覆盖宏或改变外部程序路径时，先记录旧值。

<!-- section:s004 -->
## 使用 Agent 状态

1. 保持 AutoClipboard 后台运行。
2. 按 [Agent 状态配置指南](../agent-signal-setup.md) 安装或刷新 Hook。
3. 在 Agent 中开始、等待审批、完成或阻塞一个任务。
4. 观察 AutoClipboard Dashboard、手柄小屏和灯环是否同步。

Agent 状态失败不应阻断 HID 输入或设备控制。若宏键正常但状态不更新，只排查 Hook、Activity Store 和状态同步链路。

<!-- section:s005 -->
## 使用语音与演讲功能

- 免费语音档由 Windows/macOS 系统听写拥有音频和文字；AutoClipboard 不读取系统听写文本。
- 高级语音档必须通过可信云端网关；客户端不保存供应商共享密钥。
- Ubuntu 不提供统一的免费系统听写路径。
- 演讲光圈和 IMU 预览依赖软件连接；退出 AutoClipboard 后这些能力停止。
- 关闭 `voice_input_enabled` 后，AutoClipboard 不得采集麦克风或发起语音请求。

<!-- section:s006 -->
## 切换电脑

1. 进入 `Settings > BLE Hosts`。
2. 已配对电脑选择对应 `SAVED` 槽位，等待 `WAIT → LINK`。
3. 新电脑选择 `EMPTY` 槽位，在 `PAIR` 的 120 秒窗口内完成系统配对。
4. 三个槽位满时，只删除确认不再使用的槽位。

切换失败时不要连续清空全部槽位；先确认手柄槽位和系统蓝牙记录是否对应。

<!-- section:s007 -->
## 结束工作与升级

- 正常退出 AutoClipboard 会停止应用层状态/IMU 订阅，但不应主动拆除 Windows HID 键盘链路。
- 升级软件前保存当前设置；安装程序启动前应生成可校验的恢复快照。
- 固件更新只在明确需要时执行，并遵循身份、板型、串口和包校验。
- 日常应用区更新不应擦除 NVS、蓝牙 bonds 或 SPIFFS 图标。
