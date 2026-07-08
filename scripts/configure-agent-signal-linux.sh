#!/usr/bin/env bash
set -euo pipefail

find_autoclipboard() {
  if [[ -n "${AUTOCLIPBOARD_EXE:-}" && -x "${AUTOCLIPBOARD_EXE}" ]]; then
    printf '%s\n' "${AUTOCLIPBOARD_EXE}"
    return 0
  fi

  local candidates=(
    "/opt/auto-clipboard/AutoClipboard"
    "${HOME}/.local/opt/auto-clipboard/AutoClipboard"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  if command -v AutoClipboard >/dev/null 2>&1; then
    command -v AutoClipboard
    return 0
  fi

  return 1
}

exe="$(find_autoclipboard)" || {
  echo "没有找到 AutoClipboard。请先安装最新版 AutoClipboard，或设置 AUTOCLIPBOARD_EXE=/path/to/AutoClipboard。"
  exit 1
}

echo "使用 AutoClipboard: ${exe}"
"${exe}" --install-agent-signal-hooks

echo
echo "配置完成。请保持 AutoClipboard 后台运行，然后重新打开 Codex / Claude Code 会话。"
echo "日志位置: ${XDG_CONFIG_HOME:-${HOME}/.config}/AutoClipboard/agent-signal/hook-events.log"

