<!-- section:s001 -->
# Developer Guide

This area is for documentation contributors, Skill maintainers, AutoClipboard/firmware developers, and release coordinators. The public release repository and access-controlled main development repository have different responsibilities; identify the layer before editing.

<!-- section:s002 -->
## Repository responsibilities

| Repository | Content | Typical changes |
| --- | --- | --- |
| `Communist-Manifesto` | AutoClipboard, V3 firmware, tests, and development specifications | Features, fixes, builds, and physical validation |
| `Communist-Manifesto-Releases` | Bilingual documentation, Skill, release scripts, and Release evidence | Documentation, Skill, publication aggregation, and mirrors |
| `zko_page` | Static ZKO website | Downloads, product explanation, documentation center, and account entry |

<!-- section:s003 -->
## Development entry points

- [Contribution and validation workflow](contributing.md)
- [Skill technical reference](../../../skills/ai-coding-handle/references/en/platform-installation.md)
- [Development firmware flashing](../../../skills/ai-coding-handle/references/en/development-flashing.md)
- [Maintenance contract](../../../skills/ai-coding-handle/references/en/maintenance-contract.md)
- [Agent Bridge contract](../../../skills/ai-coding-handle/references/en/agent-bridge-contract.md)
- [Dual-platform publishing](../maintainers/gitee-publishing.md)

<!-- section:s004 -->
## Core constraints

- Python subprojects use the repository-locked `uv` environment.
- V3 is the actively maintained firmware board; D4 remains for historical traceability only.
- Do not casually change BLE UUIDs, device naming, or the HID descriptor.
- Do not perform slow work inside GATT callbacks, serial loops, or HID callbacks.
- Code, documentation, tests, and release evidence distinguish automated, fixture, full-download, and physical-live evidence.
- English and Chinese documentation changes are paired with identical paths and section IDs.

<!-- section:s005 -->
## Definition of done

A development task is complete only after the applicable source tests, build, post-package smoke, physical loop, documentation update, and remote-parity checks are complete. Any unavailable validation must be reported with blocking evidence.
