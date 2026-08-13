<!-- section:s001 -->
# System capability overview

ZKO Ziku is not only a Bluetooth keyboard and not only a desktop program. It consists of independently degradable input, device-control, Agent-status, and release-update paths.

<!-- section:s002 -->
## Hardware input and feedback

- Four programmable macro buttons send shortcuts.
- The wheel switches Profiles, navigates menus, and adjusts settings.
- The display shows Profile, battery, Bluetooth, Agent count, and device state.
- The light ring expresses input, working, waiting, completion, approval, and blocked states.
- Three BLE host slots store, select, and delete different computers.
- The V3 IMU supports orientation preview, gestures, and higher-level presenter Halo behavior.

<!-- section:s003 -->
## AutoClipboard desktop capabilities

- Manage Profiles, macros, icons, and launch targets.
- Read device state, execute controlled commands, and display a 3D IMU preview.
- Aggregate Agent Activity, present the Dashboard, and synchronize lighting.
- Manage voice entry, shortcut conflicts, and platform capability fallback.
- Check application and firmware updates described by signed metadata.
- Save settings before upgrades and restore user configuration after an abnormal install.

<!-- section:s004 -->
## Agent and Skill capabilities

The AI Coding Handle Skill can help compatible Agents:

- Identify Windows, Linux, or macOS installation paths.
- Check AutoClipboard and V3 firmware versions.
- Diagnose USB, serial, BLE, driver, and Linux Bluetooth-controller issues.
- Install or refresh Agent hooks.
- Run maintenance actions after explicit confirmation and identity validation.

The Skill does not bypass download validation, device identity, board type, or user confirmation, and does not treat D4 as an actively maintained platform.

<!-- section:s005 -->
## Safety and privacy boundaries

- Account tokens, provider keys, and production credentials must not enter repositories or logs.
- Free system dictation leaves audio and text under operating-system ownership.
- Premium voice uses a trusted gateway and does not distribute shared provider keys to clients.
- A normal application-region firmware update writes only the application and preserves bootloader, partitions, NVS, and SPIFFS.
- First initialization, recovery, full flash, and erase are not ordinary automatic maintenance.

<!-- section:s006 -->
## Platform and release capabilities

- Windows, Linux, and macOS packages are owned by native builders for each operating system.
- A phased Release may omit an unfinished platform role, but must state that omission explicitly.
- The latest formal GitHub and Gitee Releases must match in version, asset names, and sizes.
- Gitee assets must be anonymously readable, and mainland website downloads point to exact versioned Gitee assets first.
