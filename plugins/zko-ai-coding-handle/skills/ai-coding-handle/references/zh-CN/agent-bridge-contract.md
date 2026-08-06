<!-- section:s001 -->
# Agent Bridge 协议

使用打包后的 AutoClipboard 可执行文件，不要调用源码树中的命令。

<!-- section:s002 -->
## 命令

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

Codex 和 Claude 的原生 Hook 使用 `emit --source codex|claude --native-event EVENT --payload-stdin --hook-safe --quiet`。让原生安装流程生成这些命令，不要手工编写。

通用 Agent 只能从已经验证的生命周期 Hook 接口调用 `emit`。该 Hook 必须提供稳定的会话标识，并把真实生命周期事件映射到受支持的状态。如果不能满足这些条件，应报告该 Agent 不受支持，不要通过轮询进程或猜测状态来替代。

<!-- section:s003 -->
## 结果结构 v1

每条命令都可以通过 `--result-file` 原子写入 JSON 结果：

```json
{
  "schema_version": 1,
  "command": "doctor",
  "success": true,
  "app_version": "0.3.48",
  "agent_bridge_version": 1,
  "platform": "linux",
  "checks": [],
  "changes": [],
  "errors": []
}
```

进程退出码和 `success` 共同构成权威结果。不带 `--live-test` 的 `doctor` 只验证主机配置。实时测试需要用户明确同意，而且仍不能替代完整的硬件端到端验收。
