<!-- section:s001 -->
# Maintenance contract

Use the non-empty absolute `executable` returned by bootstrap. Never substitute a source-tree command or a guessed `PATH` entry.

<!-- section:s002 -->
## Commands

```text
<absolute-executable> --maintenance inventory --result-file <result.json> --quiet
<absolute-executable> --maintenance doctor --result-file <result.json> --quiet
<absolute-executable> --maintenance firmware-check --plan-file <plan.json> --result-file <result.json> --quiet
<absolute-executable> --maintenance firmware-update --plan-file <plan.json> --plan-digest sha256:<64-lowercase-hex> --result-file <result.json> --quiet
```

The process exit code and JSON `success` are authoritative together. Do not infer success from a status string, an existing plan file, or quiet output.

<!-- section:s003 -->
## Current tested V3 baseline

The current tested V3 release baseline is firmware `0.3.64` as of 2026-08-06. Windows and Linux use the same ESP32 firmware binary; differences belong to the host Bluetooth stack and AutoClipboard backend, not separate platform firmware variants.

This baseline adds controlled recovery for sustained HID notification stalls: transient failures remain quiet, while at least three failures lasting more than one second cause a deliberate BLE disconnect so the existing reconnect path can recover instead of leaving the screen at `LINK` with unresponsive input.

The V3 candidate was built with the maintained V3 environment, flashed through the validated app-only workflow, and verified after writing only `0x10000`. HID validation received 20 press and 20 release reports without loss. USB-powered Halo validation ran for 30 seconds with no sequence gaps; after one brief USB-removal transition, battery-powered Halo ran for 455.6 seconds and 20,847 frames with no sequence gaps, loss, duplicates, disconnects, or reconnects, with P95 inter-frame time of 35.0 ms. Radio quality still depends on host antenna placement and orientation.

This section records a known tested baseline; it does not replace release discovery. Before reporting that `0.3.64` is publicly available or offering an update, require signed `latest.json` metadata and a successful `firmware-check`. If published metadata differs, report the mismatch instead of forcing or inventing an asset.

<!-- section:s004 -->
## Stable statuses

- `inventory`: `device_not_connected` when host probes are healthy; `host_unhealthy` otherwise.
- `doctor`: `healthy` or `unhealthy`. It is read-only and does not validate Hook configuration.
- `firmware-check`: `up_to_date`, `confirmation_required`, or a closed failure such as `device_not_connected`, `ambiguous_device`, `board_unknown`, `device_identity_invalid`, `firmware_release_invalid`, `firmware_package_invalid`, `firmware_version_invalid`, `downgrade_blocked`, or `plan_file_required`.
- `firmware-update`: `updated`, `up_to_date`, or a closed failure such as `device_not_connected`, `ambiguous_device`, `board_unknown`, `device_identity_invalid`, `plan_invalid`, `plan_replayed`, `device_changed`, `device_busy`, `downgrade_blocked`, `firmware_package_invalid`, `flash_failed`, `verification_failed`, or `recovery_required`.
- CLI/result failures may return `invalid_arguments`, `result_file_write_failed`, or `<command>_failed`.

<!-- section:s005 -->
## Confirmation boundary

`firmware-check` may identify the device, open serial, fetch metadata, download and validate the app-only package, and create a private plan. It does not flash. A plan expires after at most 10 minutes.

Ask for firmware consent only when the check returns `success: true`, `status: confirmation_required`, and complete `data.device`, `data.target`, `data.plan_digest`, `data.expires_at`, and `data.plan_file` fields. Display the exact device serial, port, board, current/target versions, asset name, asset SHA-256, expiry, and disconnect/power warning. Pass the original `data.plan_file` and `data.plan_digest` values unchanged. Obtain a new explicit confirmation for that plan, then run `firmware-update`. The digest proves integrity and freshness, not authorization.

<!-- section:s006 -->
## Failure handling

- On `device_busy`, stop. Do not bypass the shared lock; finish or close the competing device operation, then rerun `firmware-check` if the plan may have expired.
- On `plan_invalid`, `plan_replayed`, `device_changed`, or an expired plan, do not reuse it. Run a fresh check and seek a fresh confirmation if required.
- On `verification_failed`, do not claim success; preserve the result and diagnose the reported/re-enumerated version.
- On `recovery_required`, warn that flashing may have occurred but recovery or identity verification failed. Preserve logs, do not automatically retry, erase, or full-flash, and guide explicit recovery diagnostics.
