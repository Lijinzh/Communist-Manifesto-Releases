<!-- section:s001 -->
# 系统能力总览

ZKO 字库不是单一蓝牙键盘，也不是只有一个桌面程序。它由可独立降级的输入、设备控制、Agent 状态和发布更新链路组成。

<!-- section:s002 -->
## 硬件输入与反馈

- 四枚可编程宏按键发送快捷键。
- 波轮切换 Profile、浏览菜单和调整设置。
- 小屏显示 Profile、电量、蓝牙、Agent 数量和设备状态。
- 灯环表达输入、工作、等待、完成、审批和阻塞状态。
- 三个 BLE 主机槽位支持保存、选择和删除不同电脑。
- V3 IMU 支持姿态预览、手势和演讲光圈等上层能力。

<!-- section:s003 -->
## AutoClipboard 桌面能力

- 管理 Profile、宏键、图标和快开目标。
- 读取设备状态、执行受控命令并展示 IMU 三维预览。
- 聚合 Agent Activity，显示 Dashboard 并同步灯效。
- 管理语音入口、快捷键冲突和平台能力降级。
- 检查经过签名元数据描述的软件和固件更新。
- 在更新前保存设置并在异常安装后恢复用户配置。

<!-- section:s004 -->
## Agent 与 Skill 能力

AI Coding Handle Skill 可以帮助兼容 Agent：

- 识别 Windows、Linux 或 macOS 安装路径。
- 检查 AutoClipboard 和 V3 固件版本。
- 诊断 USB、串口、BLE、驱动和 Linux 蓝牙控制器问题。
- 安装或刷新 Agent Hook。
- 在明确确认和身份验证后执行维护动作。

Skill 不会绕过下载校验、设备身份、板型或用户确认，也不会把 D4 当作仍在维护的平台。

<!-- section:s005 -->
## 安全与隐私边界

- 账户 Token、供应商密钥和生产凭据不得写入仓库或日志。
- 免费系统听写由操作系统拥有音频和文字。
- 高级语音通过可信网关，不向客户端分发共享供应商密钥。
- 正常应用区固件更新只写应用区，不擦除 bootloader、partitions、NVS 或 SPIFFS。
- 首次初始化、恢复、full flash 和擦除不属于普通自动维护。

<!-- section:s006 -->
## 平台与发布能力

- Windows、Linux 和 macOS 安装包由各自原生构建机负责。
- 某个平台未完成时，阶段 Release 可以省略该角色，但必须明确说明。
- GitHub 和 Gitee 的最新正式 Release 必须拥有一致的版本、附件名称和大小。
- Gitee 资产必须能够匿名读取，官网国内下载优先指向准确的版本化 Gitee 附件。
