# Repository development flashing

Use this workflow only when the user explicitly requests local firmware testing from the Communist-Manifesto source repository. It does not require a published release.

## Preconditions

- Start from a clean or understood worktree and identify the exact source commit.
- Probe exactly one device and use its reported port, board, device serial, and strict firmware version.
- Stop on `device_not_connected`, `ambiguous_device`, `board_unknown`, or identity mismatch.
- Use the V3 environment only for a device reporting `board=v3`; use the D4 environment only for `board=d4`.

## Build and package

Build the exact PlatformIO environment, but never use its upload target. Package the existing build into a temporary app-only ZIP:

```bash
uv --project AutoClipboard run python AutoClipboard/scripts/package_firmware_release.py \
  --version <reported-version> \
  --env <exact-environment> \
  --board <d4-or-v3> \
  --skip-build \
  --output-dir /tmp/auto-clipboard-local-firmware
```

Calculate the package SHA-256 and keep the package under `/tmp`. Do not update `firmware/releases/latest.json` or publish GitHub assets for a development flash.

## Flash

Run the bundled low-freedom wrapper with the exact package SHA-256, expected board, and device serial:

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

The wrapper must validate the package, write only the app entry at `0x10000`, preserve NVS/SPIFFS, and perform post-flash identity and version verification. Treat both exit code and result JSON `success` as authoritative.

## Verification

After a successful write, exercise the behavior under test. For Profile latency, switch repeatedly between built-in, override-icon, and custom Profiles, capture `/lcd-perf`, and report measured render times. Do not claim the performance issue is fixed from an esptool success alone.

On `verification_failed` or `recovery_required`, preserve the result and logs. Do not retry automatically, erase flash, reset NVS, or write bootloader/partitions.
