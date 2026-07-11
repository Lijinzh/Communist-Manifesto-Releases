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
