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
## 稳定状态

- `inventory`：主机探测健康但没有设备时为 `device_not_connected`，否则为 `host_unhealthy`。
- `doctor`：`healthy` 或 `unhealthy`。该命令只读，并且不验证 Hook 配置。
- `firmware-check`：`up_to_date`、`confirmation_required`，或 `device_not_connected`、`ambiguous_device`、`board_unknown`、`device_identity_invalid`、`firmware_release_invalid`、`firmware_package_invalid`、`firmware_version_invalid`、`downgrade_blocked`、`plan_file_required` 等封闭失败状态。
- `firmware-update`：`updated`、`up_to_date`，或 `device_not_connected`、`ambiguous_device`、`board_unknown`、`device_identity_invalid`、`plan_invalid`、`plan_replayed`、`device_changed`、`device_busy`、`downgrade_blocked`、`firmware_package_invalid`、`flash_failed`、`verification_failed`、`recovery_required` 等封闭失败状态。
- CLI 或结果写入失败可能返回 `invalid_arguments`、`result_file_write_failed` 或 `<command>_failed`。

<!-- section:s004 -->
## 确认边界

`firmware-check` 可以识别设备、打开串口、获取元数据、下载并验证仅应用固件包，以及创建私有计划，但不会刷写。计划最长在 10 分钟后过期。

只有检查返回 `success: true`、`status: confirmation_required`，并且包含完整的 `data.device`、`data.target`、`data.plan_digest`、`data.expires_at` 和 `data.plan_file` 时，才能询问固件授权。必须展示准确的设备序列号、端口、板型、当前和目标版本、附件名、附件 SHA-256、过期时间以及禁止断电或拔 USB 的警告。原样传递 `data.plan_file` 与 `data.plan_digest`，针对该计划取得新的明确确认后再运行 `firmware-update`。摘要只证明完整性和时效性，不代表用户授权。

<!-- section:s005 -->
## 失败处理

- 遇到 `device_busy` 时停止。不要绕过共享锁；结束或关闭冲突的设备操作，如果计划可能过期则重新运行 `firmware-check`。
- 遇到 `plan_invalid`、`plan_replayed`、`device_changed` 或过期计划时不要复用。重新检查，并在需要时取得新的确认。
- 遇到 `verification_failed` 时不要报告成功；保留结果并诊断设备报告或重新枚举后的版本。
- 遇到 `recovery_required` 时警告用户刷写可能已经发生，但恢复或身份验证失败。保留日志，不自动重试、擦除或执行完整刷写，并引导用户进行明确的恢复诊断。
