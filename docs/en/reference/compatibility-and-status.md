<!-- section:s001 -->
# Compatibility and status reference

This page summarizes platform, device-state, asset-naming, and evidence semantics. Exact version assets come from the latest formal Release.

<!-- section:s002 -->
## Platform support model

| Platform | Formal package requirement | Key validation |
| --- | --- | --- |
| Windows x64 | Natively built EXE | Install, launch, runtime smoke, update, and device connection |
| Linux amd64 | Native Linux-built DEB | Install, launch, dependencies, desktop insertion, and platform smoke |
| macOS | Developer ID signed, notarized, and stapled DMG | `codesign`, `stapler`, Gatekeeper, and real launch |

A phased Release may omit an unfinished platform. An unnotarized macOS preview uses a distinct name and prominent warning and never enters automatic-update metadata.

<!-- section:s003 -->
## Handle Bluetooth states

| State | Meaning | User action |
| --- | --- | --- |
| `PAIR` | Current slot accepts a new host | Add the complete device name from the system within 120 seconds |
| `WAIT` | Waiting for the saved host to reconnect | Enable Bluetooth on the destination and confirm the slot |
| `LINK` | Connected to the current host | Test a macro or start software features |
| `SAVED` | Slot contains a host | Short press to select; long press only for confirmed deletion |
| `EMPTY` | Slot is empty | Short press to open first-pairing window |

<!-- section:s004 -->
## Software and connection states

- **HID connected**: macros can type into the system; this does not prove AutoClipboard GATT connection.
- **BLE application connected**: AutoClipboard validated device command, status, IMU, and time characteristics.
- **Serial connected**: the operating system exposes a serial port; this does not prove device identity or board type.
- **Agent connected**: hooks and Activity state reach the Dashboard; this does not prove hardware is online.
- **Update available**: installation is allowed only after metadata URL, filename, size, and SHA-256 all validate.

<!-- section:s005 -->
## Formal asset naming

| Role | Typical name |
| --- | --- |
| Windows | `AutoClipboardSetup-<version>.exe` |
| Linux | `auto-clipboard_<version>_amd64.deb` |
| macOS | `AutoClipboard-<version>-macOS.dmg` |
| V3 firmware | `CommunistManifestoKB-firmware-v3-<version>.zip` |
| Skill | `ai-coding-handle-skill-<version>.zip` |
| Update metadata | `latest.json` |

No new D4 firmware is produced. Asset names must match the URL basename in `latest.json`.

<!-- section:s006 -->
## Evidence levels

| Label | Proves | Does not prove |
| --- | --- | --- |
| `implemented` | Source implementation exists | Runtime or hardware works |
| `fixture` | Controlled inputs pass | Complete public package works |
| `full-download` | Complete public asset downloads and validates | Real hardware behavior works |
| `physical-live` | A specified real device/platform passes | Other platforms or devices automatically pass |

<!-- section:s007 -->
## Minimum support information

- Operating system, version, and CPU architecture.
- AutoClipboard version and installer source.
- Final four characters of the complete handle name, display state, and current Profile.
- Whether HID macros work, AutoClipboard connects, and a COM port appears.
- Reproduction steps, expected result, actual result, and redacted screenshot/log.

Do not provide account tokens, provider keys, activation plaintext, private conversations, or unredacted serial identity records.
