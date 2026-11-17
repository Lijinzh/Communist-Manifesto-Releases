<!-- section:s001 -->
# Maintenance 协议

使用 bootstrap 返回的非空绝对 `executable` 路径。绝不能替换成源码树命令或猜测的 `PATH` 项。

<!-- section:s002 -->
## 命令

```text
<absolute-executable> --maintenance inventory --result-file <result.json> --quiet
<absolute-executable> --maintenance doctor --result-file <result.json> --quiet
<absolute-executable> --maintenance firmware-check --plan-file <plan.json> --result-file <result.json> --quiet
<absolute-executable> --maintenance firmware-update --plan-file <plan.json> --plan-digest sha256:<64-lowercase-hex> --result-file <result.json> --quiet
```

进程退出码和 JSON `success` 必须同时作为权威依据。不要根据状态字符串、已存在的计划文件或安静输出推断成功。

<!-- section:s003 -->
## 当前已验证的 V3 基线

本次发布目标是 V3 固件 `0.3.71`（2026-11-17），发布包为
`CommunistManifestoKB-firmware-v3-0.3.71.zip`，唯一维护的构建环境为
`esp32dev_pico_v3_screen_114_st7789`，三种桌面平台使用同一固件。

本版加入充电会话单次提示、4 秒大电池动画和持久化的“Agent 工作时允许深度睡眠”开关
（默认开启）。Agent 心跳、只读状态查询和 IMU 推流不再刷新物理活动计时。
对应功能源码已在 Linux V3 `1C9E` 上通过 validated app-only 烧录验证，开发版本标识为
`0.3.70`：关闭开关后静置 34.382 秒仍保持唤醒，开启后在临时 30 秒超时下 30.490 秒进入深睡；
两个设置值均通过重启回读，最后已恢复 1800 秒超时并开启开关。发布版本独立重新构建；
这些结果不代表已回读 `0.3.71` 版本，也不代表底座循环、满电补充电、实屏动画或电流测量已验证。

最终大小与 SHA-256 必须取自一致的 `latest.json` 和 GitHub/Gitee 公开附件。
提供更新前必须成功执行 `firmware-check`；不得复用开发包哈希，公开元数据不符时不得强制更新。

<!-- section:s004 -->
## 稳定状态

- `inventory`：主机探测健康但没有设备时为 `device_not_connected`，否则为 `host_unhealthy`。
- `doctor`：`healthy` 或 `unhealthy`。该命令只读，并且不验证 Hook 配置。
- `firmware-check`：`up_to_date`、`confirmation_required`，或 `device_not_connected`、`ambiguous_device`、`board_unknown`、`device_identity_invalid`、`firmware_release_invalid`、`firmware_package_invalid`、`firmware_version_invalid`、`downgrade_blocked`、`plan_file_required` 等封闭失败状态。
- `firmware-update`：`updated`、`up_to_date`，或 `device_not_connected`、`ambiguous_device`、`board_unknown`、`device_identity_invalid`、`plan_invalid`、`plan_replayed`、`device_changed`、`device_busy`、`downgrade_blocked`、`firmware_package_invalid`、`flash_failed`、`verification_failed`、`recovery_required` 等封闭失败状态。
- CLI 或结果写入失败可能返回 `invalid_arguments`、`result_file_write_failed` 或 `<command>_failed`。

<!-- section:s005 -->
## 确认边界

`firmware-check` 可以识别设备、打开串口、获取元数据、下载并验证仅应用固件包，以及创建私有计划，但不会刷写。计划最长在 10 分钟后过期。

只有检查返回 `success: true`、`status: confirmation_required`，并且包含完整的 `data.device`、`data.target`、`data.plan_digest`、`data.expires_at` 和 `data.plan_file` 时，才能询问固件授权。必须展示准确的设备序列号、端口、板型、当前和目标版本、附件名、附件 SHA-256、过期时间以及禁止断电或拔 USB 的警告。原样传递 `data.plan_file` 与 `data.plan_digest`，针对该计划取得新的明确确认后再运行 `firmware-update`。摘要只证明完整性和时效性，不代表用户授权。

<!-- section:s006 -->
## 失败处理

- 遇到 `device_busy` 时停止。不要绕过共享锁；结束或关闭冲突的设备操作，如果计划可能过期则重新运行 `firmware-check`。
- 遇到 `plan_invalid`、`plan_replayed`、`device_changed` 或过期计划时不要复用。重新检查，并在需要时取得新的确认。
- 遇到 `verification_failed` 时不要报告成功；保留结果并诊断设备报告或重新枚举后的版本。
- 遇到 `recovery_required` 时警告用户刷写可能已经发生，但恢复或身份验证失败。保留日志，不自动重试、擦除或执行完整刷写，并引导用户进行明确的恢复诊断。
