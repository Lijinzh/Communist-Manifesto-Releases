<!-- section:s001 -->
# 兼容性与状态参考

本页汇总平台、设备状态、资产命名和证据含义。具体版本资产以最新正式 Release 为准。

<!-- section:s002 -->
## 平台支持模型

| 平台 | 正式安装包要求 | 关键验证 |
| --- | --- | --- |
| Windows x64 | 原生构建的 EXE | 安装、启动、运行时 smoke、更新与设备连接 |
| Linux amd64 | 原生 Linux 构建的 DEB | 安装、启动、依赖、桌面插入和平台 smoke |
| macOS | Developer ID 签名、公证并 stapled 的 DMG | `codesign`、`stapler`、Gatekeeper 和真实启动 |

阶段 Release 可以省略未完成平台。未公证 macOS 预览包必须独立命名、醒目标注，且不得进入自动更新元数据。

<!-- section:s003 -->
## 手柄蓝牙状态

| 状态 | 含义 | 用户动作 |
| --- | --- | --- |
| `PAIR` | 当前槽位允许新主机配对 | 在 120 秒内从系统添加完整设备名 |
| `WAIT` | 等待当前已保存主机重连 | 打开目标电脑蓝牙并确认槽位 |
| `LINK` | 已连接当前主机 | 测试宏键或启动软件功能 |
| `SAVED` | 槽位保存了一台主机 | 短按选择，长按只用于确认删除 |
| `EMPTY` | 槽位为空 | 短按开启首次配对窗口 |

<!-- section:s004 -->
## 软件与连接状态

- **HID 已连接**：宏键能向系统输入，不证明 AutoClipboard GATT 已连接。
- **BLE 软件连接**：AutoClipboard 已验证设备命令、状态、IMU 和时间特征。
- **串口已连接**：只说明操作系统存在串口，不证明设备身份或板型正确。
- **Agent 已连接**：Hook 和 Activity 状态能进入 Dashboard，不证明硬件一定在线。
- **Update available**：只有元数据 URL、文件名、大小和 SHA-256 全部通过校验后才可安装。

<!-- section:s005 -->
## 正式资产命名

| 角色 | 典型命名 |
| --- | --- |
| Windows | `AutoClipboardSetup-<版本>.exe` |
| Linux | `auto-clipboard_<版本>_amd64.deb` |
| macOS | `AutoClipboard-<版本>-macOS.dmg` |
| V3 固件 | `CommunistManifestoKB-firmware-v3-<版本>.zip` |
| Skill | `ai-coding-handle-skill-<版本>.zip` |
| 更新元数据 | `latest.json` |

D4 不再生成新固件。资产名必须与 `latest.json` 中的 URL basename 一致。

<!-- section:s006 -->
## 证据等级

| 标签 | 可以证明 | 不能证明 |
| --- | --- | --- |
| `implemented` | 源码存在 | 运行或硬件正常 |
| `fixture` | 受控输入通过 | 完整公开包可用 |
| `full-download` | 公开完整资产可下载并校验 | 真实硬件功能正常 |
| `physical-live` | 指定真实设备/平台通过 | 其他平台或其他设备自动通过 |

<!-- section:s007 -->
## 请求支持时的最小信息

- 操作系统及版本、CPU 架构。
- AutoClipboard 版本和安装包来源。
- 手柄完整设备名后四位、屏幕状态和当前 Profile。
- HID 宏是否可用、AutoClipboard 是否连接、是否出现 COM 端口。
- 复现步骤、期望结果、实际结果和脱敏截图/日志。

不要提供账户 Token、供应商密钥、激活码明文、私人对话或未脱敏串口身份记录。
