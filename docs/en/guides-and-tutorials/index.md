<!-- section:s001 -->
# Guides and Tutorials

This area is organized by “what do I want to accomplish?” Each tutorial defines the starting state, steps, success signal, and high-risk actions that should not be performed incidentally.

<!-- section:s002 -->
## Common tutorials

- [Common workflow tutorial collection](common-workflows.md)
- [Complete troubleshooting](../user-guide.md#12-troubleshooting)
- [Agent status synchronization setup](../agent-signal-setup.md)
- [Windows CH343 driver installation](../ch343-driver-installation.md)
- [Safe AutoClipboard operation order](../software-interface-manual.md#11-recommended-safe-operation-order)

<!-- section:s003 -->
## Choose by goal

| Goal | Starting point |
| --- | --- |
| Switch among three computers | Open `Settings > BLE Hosts` and choose `SAVED` or `EMPTY` |
| Macros work but the application is disconnected | Check HID and application GATT paths separately |
| Show Agent work state on the handle | Keep AutoClipboard running and install Agent hooks |
| Upgrade the desktop application without losing settings | Confirm a settings snapshot and formal-installer validation first |
| Update V3 firmware | Confirm device identity, serial port, board type, and package validation first |
| No COM port after Type-C connection | Check the data cable and Device Manager before installing CH343 |

<!-- section:s004 -->
## Troubleshooting principles

1. Record the symptom and current state before changing the system.
2. Perform read-only checks before reversible modifications.
3. Do not use reinstall, delete pairing, reset settings, or flash firmware as the first step.
4. Change one variable at a time and record the success signal.
5. Stop writing when device identity cannot be uniquely confirmed.

<!-- section:s005 -->
## Requesting help

Provide the operating system, AutoClipboard version, final four characters of the full handle name, display state, whether macros work, whether a COM port exists, and an error screenshot. Do not send tokens, activation plaintext, provider keys, or private Agent-session content.
