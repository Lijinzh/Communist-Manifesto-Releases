---
name: ai-coding-handle
description: Use when AutoClipboard installation or updates, AI coding handle Agent hooks, firmware version checks or updates, D4/V3 device identification, USB/serial/BLE connectivity, or AutoClipboard and handle diagnostics need attention.
---

# AI Coding Handle

Use the bundled bootstrap and the installed AutoClipboard Maintenance/Agent Bridge CLIs for ordinary users. When the user explicitly requests repository development flashing from this source tree, use the separate local workflow below.

## Choose scope and consent

- Consultation performs no commands or changes.
- Diagnosis is read-only. Run Maintenance `inventory`/`doctor` without repairing anything. For Agent or Hook integrity, also run `--agent-bridge doctor` and combine the findings. A `--live-test` still needs separate consent because it changes visible device state.
- Before software installation, upgrade, or Hook configuration, explain the changes and obtain one explicit software confirmation. Software authorization does not authorize firmware flashing.
- `firmware-check` is a non-destructive preflight: it may open the selected serial device and download and verify a firmware package, but it must not flash. Run firmware-check before asking for firmware consent.
- Repository development flashing is for locally built test firmware before release. It does not require a published release; read [references/development-flashing.md](references/development-flashing.md) and keep release updates on the Maintenance contract.

## Dispatch

1. For installation, upgrade, or Hook configuration, run `scripts/bootstrap-autoclipboard.ps1` on Windows or `scripts/bootstrap-autoclipboard.sh` on Linux/macOS after the software confirmation.
2. Read the bootstrap JSON result. After installation, every Maintenance and Agent Bridge command must use the returned absolute `executable`; never assume `auto-clipboard` is on `PATH`.
3. For host diagnosis, run the read-only Maintenance commands. For Hook diagnosis or setup, follow [references/agent-bridge-contract.md](references/agent-bridge-contract.md).
4. For published firmware version or update requests, follow [references/maintenance-contract.md](references/maintenance-contract.md). For an explicit local source build and flash request, follow [references/development-flashing.md](references/development-flashing.md). Never guess D4 or V3, a port, or which device to use.

Only when `firmware-check` returns `success: true` and `status: confirmation_required`, show the user the device serial, port, board, current version, target version, asset name, asset SHA-256, plan expiry, and a warning not to disconnect power or USB. Then obtain a new, explicit, present-tense second confirmation for that exact plan. A previous “approve everything”, software confirmation, or one-time blanket authorization does not count. Run firmware-update only after the second explicit confirmation.

The `plan_digest` binds plan integrity and freshness; it is not evidence of user authorization. After confirmation, pass the exact plan file and digest returned by `firmware-check` to `firmware-update`.

## Repository development flashing

Use this path only inside the Communist-Manifesto repository when the user explicitly asks to flash and test the current working tree before publishing. Use `uv --project AutoClipboard` for the package and wrapper scripts. Build the exact board environment, create a validated app-only package, bind it to the expected board and device serial, verify the package SHA-256, and run `scripts/flash-local-firmware.py`. Require post-flash identity and version verification. An explicit request to directly flash the current local build to the already identified device authorizes one matching local package in the same task; do not force a GitHub Release or a release-plan second confirmation.

## Hard boundaries

- Do not choose among multiple devices, infer a board from a filename, or guess a serial port.
- For published updates, do not call PlatformIO or `esptool` directly and do not bypass the plan file, digest, expiry, device identity, package validation, device lock, or post-flash verification.
- For repository development flashing, PlatformIO may compile the exact environment but must not upload. Flash only through the validated app-only package workflow with the expected board and device serial. Never erase NVS or SPIFFS, write bootloader/partitions, reset pairings, or perform a full flash.
- Treat process exit code and JSON `success` as authoritative. Never report hardware end-to-end success when the physical handle was unavailable.
- Codex Hook trust remains a user boundary. Require the core preflight (`hook_executable_available`, `platform_poll_supported`, `state_directory_writable`) and final doctor. A sole `hook_trust_granted` failure is actionable only when `hook_trust_probe_available`, `hook_trust_metadata_complete`, and `hook_runtime_enabled` are true. Never edit `trusted_hash` or use `--dangerously-bypass-hook-trust`.

Read [references/platform-installation.md](references/platform-installation.md) for bootstrap behavior and [references/troubleshooting.md](references/troubleshooting.md) for failure handling. Native install is only for supported Codex/Claude integrations; a generic agent may use verified lifecycle `emit`, otherwise report `unsupported`.
