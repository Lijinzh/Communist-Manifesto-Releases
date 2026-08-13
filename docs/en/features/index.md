<!-- section:s001 -->
# Features

This area explains what the ZKO Ziku system contains, how its parts compose, and what does not happen automatically. It establishes shared concepts for evaluation, training, and troubleshooting.

<!-- section:s002 -->
## Capability map

- [System capability overview](system-overview.md)
- [Complete hardware manual](../user-guide.md#3-hardware-overview)
- [AutoClipboard interface and settings](../software-interface-manual.md)
- [AI Coding Handle Skill](../../../skills/ai-coding-handle/SKILL.md)

<!-- section:s003 -->
## Product components

| Component | Primary responsibility |
| --- | --- |
| V3 handle | HID input, display, light ring, wheel, macros, BLE device status, and IMU |
| AutoClipboard | Device connection, Profiles, launch targets, Agent Dashboard, voice, IMU preview, and updates |
| AI Coding Handle Skill | Helps Agents install, diagnose, inspect versions, and run controlled maintenance workflows |
| Releases and `latest.json` | Provide verified platform installers, firmware, Skill, and update metadata |
| ZKO website | Provides product entry points, mainland-first downloads, and documentation navigation |

<!-- section:s004 -->
## Design principles

- Keyboard input has priority; status and UI failures must not take down HID.
- Destructive or hardware-writing actions require clearer intent than normal settings.
- Each platform installer must be built and validated natively on that operating system.
- Release assets require exact names, sizes, SHA-256 values, and public-download evidence.
- Normal upgrades preserve user settings, Bluetooth bonds, NVS, and icons by default.

<!-- section:s005 -->
## Continue reading

- Complete a specific task: [Guides and Tutorials](../guides-and-tutorials/index.md)
- Integrate or contribute: [Developer Guide](../developer-guide/index.md)
- Look up exact state: [Reference](../reference/index.md)
