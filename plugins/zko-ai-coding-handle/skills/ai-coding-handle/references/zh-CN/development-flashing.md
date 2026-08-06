<!-- section:s001 -->
# 仓库开发固件刷写

仅当用户明确要求从 Communist-Manifesto 源码仓库测试本地固件时使用此流程。该流程不要求存在已发布的 Release。

<!-- section:s002 -->
## 前置条件

- 从干净或状态明确的工作区开始，并记录准确的源码提交。
- 只探测一个设备，使用设备报告的端口、板型、设备序列号和严格固件版本。`--device-serial` 必须使用固件以 `sid`/`device_serial` 报告的身份；`/dev/serial/by-id`、udev 或 USB 描述符中的 USB 传输序列号只用于识别端口，除非与固件身份完全一致，否则不得代替前者。
- 遇到 `device_not_connected`、`ambiguous_device`、`board_unknown` 或身份不匹配时停止。
- 只有设备报告 `board=v3` 时才使用 V3 环境；只有设备报告 `board=d4` 时才使用 D4 环境。

<!-- section:s003 -->
## 构建与打包

构建准确的 PlatformIO 环境，但绝不能使用上传目标。把已有构建打包成临时的仅应用 ZIP：

```bash
uv --project AutoClipboard run python AutoClipboard/scripts/package_firmware_release.py \
  --version <reported-version> \
  --env <exact-environment> \
  --board <d4-or-v3> \
  --skip-build \
  --output-dir /tmp/auto-clipboard-local-firmware
```

计算固件包 SHA-256，并把包保存在 `/tmp` 下。不要更新 `firmware/releases/latest.json`，也不要为开发刷写发布 GitHub 附件。

<!-- section:s004 -->
## 刷写

使用准确的固件包 SHA-256、预期板型和设备序列号运行捆绑的低自由度包装器：

```bash
uv --project AutoClipboard run python \
  .agents/skills/ai-coding-handle/scripts/flash-local-firmware.py \
  --package <absolute-package.zip> \
  --package-sha256 <64-hex> \
  --board <d4-or-v3> \
  --device-serial <reported-serial> \
  --result-file /tmp/auto-clipboard-local-flash.json \
  --flash
```

包装器必须验证固件包，只向 `0x10000` 写入应用条目，保留 NVS/SPIFFS，并在刷写后验证身份和版本。进程退出码和结果 JSON 中的 `success` 都是权威依据。

如果身份不匹配在写入前被拒绝，这代表安全拦截成功，不是刷写失败。应改用正确的固件 `device_serial` 重新运行包装器，并明确说明被拒绝的那次尝试没有发生 Flash 写入。

<!-- section:s005 -->
## 验证

写入成功后，实际测试目标行为。对于 Profile 延迟，应在内置 Profile、覆盖图标 Profile 和自定义 Profile 之间反复切换，采集 `/lcd-perf`，并报告测得的渲染时间。不能仅根据 esptool 成功就宣称性能问题已经修复。

遇到 `verification_failed` 或 `recovery_required` 时，保留结果和日志。不要自动重试、擦除 Flash、重置 NVS 或写入 bootloader/分区。
