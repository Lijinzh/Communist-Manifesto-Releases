$ErrorActionPreference = "Stop"

function Find-AutoClipboard {
    if ($env:AUTOCLIPBOARD_EXE -and (Test-Path $env:AUTOCLIPBOARD_EXE)) {
        return $env:AUTOCLIPBOARD_EXE
    }

    $candidates = @(
        "$env:LOCALAPPDATA\Programs\AutoClipboard\AutoClipboard.exe",
        "$env:ProgramFiles\AutoClipboard\AutoClipboard.exe",
        "${env:ProgramFiles(x86)}\AutoClipboard\AutoClipboard.exe"
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    $command = Get-Command AutoClipboard.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

$exe = Find-AutoClipboard
if (-not $exe) {
    Write-Error "没有找到 AutoClipboard。请先安装最新版 AutoClipboard，或设置 AUTOCLIPBOARD_EXE=C:\Path\To\AutoClipboard.exe。"
    exit 1
}

Write-Host "使用 AutoClipboard: $exe"
& $exe --install-agent-signal-hooks

Write-Host ""
Write-Host "配置完成。请保持 AutoClipboard 后台运行，然后重新打开 Codex / Claude Code 会话。"
Write-Host "日志位置: $env:APPDATA\AutoClipboard\agent-signal\hook-events.log"
