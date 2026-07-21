# Troubleshooting

## Bootstrap rejects metadata or an asset

- Confirm the selected entry exists under `app.windows`, `app.linux`, or `app.macos`.
- Confirm the package extension matches `.exe`, `.deb`, or `.dmg`.
- Confirm the asset URL is HTTPS and belongs to the fixed GitHub Release repository.
- Re-download when size or SHA-256 differs. Never bypass either check.
- Use a local metadata file only with dry-run.

## Existing AutoClipboard is found but doctor fails

Under diagnosis scope, read the result file and report the failed checks without modifying software or Hook configuration.

Under explicit installation or configuration scope, first require the core preflight checks to pass. Stop if `hook_executable_available`, `platform_poll_supported`, or `state_directory_writable` fails. Missing or stale native Hook checks may be repaired with native install; malformed configuration or other failures remain fatal and must be reported.

## Codex reports `hook_trust_granted: false`

If all core and Hook configuration checks pass, `hook_trust_probe_available`, `hook_trust_metadata_complete`, and `hook_runtime_enabled` are true, and this is the only failed check, ask the user to review and approve the AutoClipboard Hooks inside Codex, then rerun doctor. This is `configuration_required`, not `ready` and not a generic bootstrap failure. Probe failures, incomplete metadata, disabled Hooks, and unknown trust statuses are fatal diagnostics rather than approval prompts.

Never write `[hooks.state]` or `trusted_hash` in Codex `config.toml`. Never use `--dangerously-bypass-hook-trust`; Hook trust must remain an explicit user or managed-policy decision.

## Agent integration is unsupported

Codex and Claude Code have native install support. For Hermes, OpenCL, or another generic agent, verify an official lifecycle hook surface, stable session IDs, and event payloads before configuring `emit`. If any part is missing, report `unsupported`; do not infer state from process existence, logs, or timers.

## Doctor passes but the handle does not react

Doctor proves host-side configuration unless `--live-test` was explicitly authorized. Check that AutoClipboard is running, the device is paired and connected, and the selected state is visible. Record that hardware end-to-end validation remains unverified when the physical handle is unavailable.

## Ubuntu or BlueZ shows only an unnamed HID address

Use this fallback only when the graphical Bluetooth settings cannot show `CommunistKB-XXXX`.
It does not replace a firmware update that restores the complete name in the primary
advertisement.

Start read-only. If the Bluetooth adapter is off, ask the user to enable it; do not run
`power on` without authorization. Power off the intended handle, start a current scan, then
power it on, explicitly enter an empty host slot, and require the screen to show `PAIR`. The
candidate must disappear while the handle is off and reappear in the current scan; do not rely
on an address that exists only in BlueZ's cached device list. Keep scanning for at least 10
seconds after the candidate first appears and inspect every candidate. Open one interactive
`bluetoothctl` session:

```text
bluetoothctl
scan on
devices
info AA:BB:CC:DD:1C:96
```

Do not pair an address until exactly one candidate satisfies every check:

- The handle screen currently shows `PAIR`.
- The last two address bytes match an independently known device-name suffix from a previous
  pairing record, device label, or verified USB/serial inventory; for example, `...:1C:96`
  matches `CommunistKB-1C96`. If no independent suffix is available, require the off/on
  disappearance-and-reappearance check above with only one physical handle placed in `PAIR`;
  never treat the candidate address as proof of itself.
- `info` exposes HID `0x1812` (`00001812-0000-1000-8000-00805f9b34fb`).
- `info` exposes Battery `0x180F` (`0000180f-0000-1000-8000-00805f9b34fb`).
- No second candidate matches the same evidence. If candidates remain ambiguous, stop and ask
  the user to power off the other handles or otherwise identify the intended address. Never
  choose one arbitrarily.

Diagnosis remains read-only: finish with `scan off`, report the verified address and evidence,
but do not enable a pairing agent, pair, trust, or connect. Before changing Bluetooth state,
show the exact verified address and obtain authorization for each intended action. Do not infer
permission for `trust` or `connect` from a request that only says to pair. When the user
explicitly authorizes all three actions, continue in the same session:

```text
agent on
default-agent
pair AA:BB:CC:DD:1C:96
trust AA:BB:CC:DD:1C:96
connect AA:BB:CC:DD:1C:96
info AA:BB:CC:DD:1C:96
scan off
quit
```

Require `Paired: yes`, `Connected: yes`, and `LINK` on the handle before reporting success.
If the user authorized only a subset of the actions, stop after that subset and report only the
states actually verified. The `pair` command may itself establish a connection and produce
`Connected: yes`; observing that state does not authorize an extra explicit `connect` command.
Do not reset the Bluetooth adapter, delete existing bonds, clear handle slots, or alter SMP
authentication merely because the GUI omitted the name. If logs contain
`unexpected SMP command 0x0b` but pairing, connection, and `LINK` all succeed, record it as a
separate compatibility clue; it is not evidence that security settings must change. If pairing
fails, preserve the `bluetoothctl` and BlueZ logs and continue diagnosis without broadening the
authorized changes.

## Firmware preflight cannot identify one device

- `device_not_connected`: ask the user to connect one supported handle and check USB/serial access. Do not guess a port.
- `ambiguous_device`: stop and ask the user to leave exactly one intended handle connected. Never select one arbitrarily.
- `board_unknown`: stop and obtain a valid device-reported D4/V3 identity. Never infer the board from an asset name or user preference.

Rerun `firmware-check` after the physical issue is resolved. Do not bypass preflight or call PlatformIO/`esptool` directly.

## Firmware plan or update fails

- `plan_invalid`: the plan, digest, package, or expiry is invalid. Discard it and run a fresh check; never edit the plan.
- `plan_replayed`: the target is already present or the one-time plan was reused. Do not flash it again.
- `device_busy`: another dangerous device operation owns the lock. Stop the competing operation and retry through Maintenance; never bypass the lock.
- `verification_failed`: flashing may have completed but the target version was not verified. Do not report success; reconnect and diagnose.
- `recovery_required`: flashing may have completed but the device did not recover or re-enumerate reliably. Preserve the result/logs, warn the user, and do not automatically retry, erase flash, reset NVS, or perform a full flash.

Any fresh `confirmation_required` plan needs its own current second confirmation. Never reuse a prior software or blanket authorization.
