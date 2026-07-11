---
name: ai-coding-handle
description: Use when AutoClipboard or the AI coding handle is missing, agent status hooks are unconfigured or stale, or Codex, Claude Code, Hermes, OpenCL, and other coding agents need working, permission, blocked, attention, or done states connected to the handle.
---

# AI Coding Handle

## Choose the permitted scope

- For consultation, explain the architecture and options only. Do not run doctor, edit hooks, or install software.
- For diagnosis, locate the packaged AutoClipboard executable and run `--agent-bridge doctor`; report the cause without installing.
- Run a bootstrap script only after the user explicitly asks to install AutoClipboard or configure agent hooks.

## Install and connect

1. On Windows, run `scripts/bootstrap-autoclipboard.ps1`. On Linux or macOS, run `scripts/bootstrap-autoclipboard.sh`.
2. Before changing hooks, require Agent Bridge v1 and healthy core preflight checks: `hook_executable_available`, `platform_poll_supported`, and `state_directory_writable`. Hook configuration checks may still fail before installation repairs them.
3. For Codex and Claude Code, use native install through `--agent-bridge install` and require at least one reported change. The final doctor must succeed unless `hook_trust_probe_available`, `hook_trust_metadata_complete`, and `hook_runtime_enabled` are true and its only failed check is Codex `hook_trust_granted`; in that case report `configuration_required`, ask the user to review and approve the AutoClipboard Hooks inside Codex, then rerun doctor.
4. For a generic agent, require only the core preflight, then configure `emit` when its lifecycle Hook surface is verified and supplies stable session/state data. Otherwise report the integration as unsupported. Do not call native install for `generic`.
5. Read [references/agent-bridge-contract.md](references/agent-bridge-contract.md) for the real CLI and result schema, [references/platform-installation.md](references/platform-installation.md) for platform behavior, and [references/troubleshooting.md](references/troubleshooting.md) when doctor fails.

Codex Hook trust is a user approval boundary. Never edit `[hooks.state]` or `trusted_hash` in `config.toml`, and never use `--dangerously-bypass-hook-trust` to make doctor pass.

Run `--live-test` only with explicit user consent because it changes the visible device state temporarily. A successful doctor is a host-side check, not proof of hardware end-to-end behavior.

Ordinary users do not need the source tree, Python, `uv`, PlatformIO, or `gh`.
