<!-- section:s001 -->
# AutoClipboard Agent Status Monitoring Setup

AutoClipboard can monitor Codex and Claude Code work states and synchronize them to the handle light ring and screen.

Typical effects:

- `working`: the agent is working and the light ring runs an animation.
- `permission`: the agent is waiting for authorization or input and flashes yellow.
- `blocked`: the task is blocked or failed and shows a red alert.
- `done`: the current response is complete and shows a green completion signal; strong alerts can also trigger the buzzer and a notification.

<!-- section:s002 -->
## Fastest setup methods

<!-- section:s003 -->
### Method 1: Configure in AutoClipboard

1. Start AutoClipboard.
2. Open the Agent status light or work-state monitoring area in application settings.
3. Select **Configure status light** or **Repair Hook**.
4. Keep AutoClipboard running in the background.

This is the recommended method for most users.

<!-- section:s004 -->
### Method 2: One-command Linux setup

After downloading this repository, run:

```bash
bash ../../scripts/configure-agent-signal-linux.sh
```

For a custom AutoClipboard location, set:

```bash
AUTOCLIPBOARD_EXE=/path/to/AutoClipboard bash ../../scripts/configure-agent-signal-linux.sh
```

<!-- section:s005 -->
### Method 3: One-command Windows PowerShell setup

Run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File ..\..\scripts\configure-agent-signal-windows.ps1
```

For a custom AutoClipboard location, set:

```powershell
$env:AUTOCLIPBOARD_EXE="C:\Path\To\AutoClipboard.exe"
powershell -ExecutionPolicy Bypass -File ..\..\scripts\configure-agent-signal-windows.ps1
```

<!-- section:s006 -->
## What configuration changes

The script calls the installed AutoClipboard executable:

```text
AutoClipboard --install-agent-signal-hooks
```

AutoClipboard creates or repairs:

- Codex Hook configuration: `~/.codex/hooks.json`
- Claude Code Hook configuration: `~/.claude/settings.json`

The Hook only writes state to a local status directory. It does not interrupt normal Codex or Claude Code operation.

<!-- section:s007 -->
## Verify the setup

<!-- section:s008 -->
### Linux

```bash
ls ~/.config/AutoClipboard/agent-signal
tail -n 20 ~/.config/AutoClipboard/agent-signal/hook-events.log
```

<!-- section:s009 -->
### Windows

```powershell
dir "$env:APPDATA\AutoClipboard\agent-signal"
Get-Content "$env:APPDATA\AutoClipboard\agent-signal\hook-events.log" -Tail 20
```

After starting a Codex or Claude Code conversation, the log should contain events such as:

```text
UserPromptSubmit -> working
PreToolUse -> working
PostToolUse -> working
Stop -> done
```

<!-- section:s010 -->
## Troubleshooting

<!-- section:s011 -->
### Agent state does not change in AutoClipboard

Confirm that AutoClipboard is running in the background. The Hook writes local state, but AutoClipboard must be running and connected over BLE to synchronize it to the handle.

<!-- section:s012 -->
### Codex works but Claude Code does not

Run the setup script again or select **Repair Hook** in AutoClipboard. Then verify that a Hook was written to `~/.claude/settings.json`.

<!-- section:s013 -->
### State flashes between working and done

Upgrade to the latest AutoClipboard version. Current versions prefer the event timestamp when evaluating `done`, preventing a touched Codex session file from making an old completion event appear new.

<!-- section:s014 -->
### Linux reports `inotify_add_watch ... No space left on device`

This usually means another application exhausted the Linux inotify watch allowance, not that the disk is full. Temporarily raise the limits with:

```bash
sudo sysctl fs.inotify.max_user_watches=1048576
sudo sysctl fs.inotify.max_user_instances=1024
```

If that resolves the issue, make it persistent:

```bash
printf "fs.inotify.max_user_watches=1048576\nfs.inotify.max_user_instances=1024\n" | sudo tee /etc/sysctl.d/99-autoclipboard-inotify.conf
sudo sysctl --system
```

<!-- section:s015 -->
### The handle does not alert

1. Confirm that the handle is connected to AutoClipboard over BLE.
2. Confirm that the AutoClipboard Agent status light is enabled.
3. To use buzzer alerts, enable strong alert mode and configure the strong-alert volume.

<!-- section:s016 -->
## Disable or uninstall

To pause synchronization, disable the Agent status light in AutoClipboard settings.

To remove the Hooks completely, manually remove the AutoClipboard Hook commands from:

- `~/.codex/hooks.json`
- `~/.claude/settings.json`
