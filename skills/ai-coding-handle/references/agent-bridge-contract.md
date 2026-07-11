# Agent Bridge contract

Use the packaged AutoClipboard executable. Do not invoke the source tree.

## Commands

```text
auto-clipboard --agent-bridge doctor \
  [--agent auto|codex|claude] [--live-test] \
  [--live-test-state idle|working|attention|permission|blocked|done|off] \
  [--result-file PATH] [--quiet]

auto-clipboard --agent-bridge install|uninstall \
  [--agent auto|codex|claude] [--dry-run] [--result-file PATH] [--quiet]

auto-clipboard --agent-bridge emit \
  --source SOURCE --session SESSION \
  --state idle|working|attention|permission|blocked|done|off \
  [--dry-run] [--result-file PATH] [--quiet]
```

Native Codex and Claude hooks use `emit --source codex|claude --native-event EVENT --payload-stdin --hook-safe --quiet`. Let native install generate those commands; do not hand-author them.

Generic agents may call `emit` only from a verified lifecycle hook surface. The hook must provide a stable session identifier and map real lifecycle events to the supported states. If those guarantees are absent, report the agent as unsupported instead of polling processes or guessing state.

## Result schema v1

Every command can write an atomic JSON result with `--result-file`:

```json
{
  "schema_version": 1,
  "command": "doctor",
  "success": true,
  "app_version": "0.3.47",
  "agent_bridge_version": 1,
  "platform": "linux",
  "checks": [],
  "changes": [],
  "errors": []
}
```

Treat the process exit code and `success` as authoritative. `doctor` without `--live-test` validates host configuration only. A live test requires explicit user consent and still does not replace a complete hardware end-to-end acceptance test.
