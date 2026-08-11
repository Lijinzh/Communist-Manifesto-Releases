[简体中文](README.md) | **English**

<!-- section:s001 -->
# ZKO Ziku AI Coding Handle

> Keep your eyes on the code and your hand on the workflow.

The ZKO Ziku AI Coding Handle combines four programmable macro buttons, a color screen, an Agent status light ring, Bluetooth HID, motion sensing, and the AutoClipboard desktop application. It is designed for AI coding, voice input, Codex, Claude Code, presentations, and other workflows where frequent keyboard or window switching breaks concentration.

<p align="center">
  <img src="docs/assets/user-guide/handle-hero.webp" alt="ZKO Ziku AI Coding Handle product overview" width="720">
</p>

> The DJI microphone in the promotional image is shown only as an example accessory and is not included with the handle.

This repository is the public download and documentation channel for AutoClipboard, handle firmware, drivers, and the open-source AI Coding Handle Skill.

<!-- section:s002 -->
## Download sources: GitHub first, Gitee fallback

GitHub remains the primary release source. If GitHub is slow or unavailable on your network, use the Gitee mirror in mainland China. The mirror carries the same release files and integrity metadata.

| Source | When to use it | Download |
| --- | --- | --- |
| GitHub | Default and primary source | [Latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest) |
| Gitee | Fallback when GitHub cannot be reached reliably | [Gitee Releases](https://gitee.com/shan-yujun/Communist-Manifesto-Releases/releases) |

Starting with the next AutoClipboard release, application and firmware update checks try GitHub first and automatically retry through Gitee when GitHub is unavailable. Downloads from either source are still verified against the declared file size and SHA-256 checksum before installation.

### `v0.3.66` Windows phased release

`v0.3.66` formally publishes Windows x64, V3 firmware, and the AI Coding Handle Skill
in this phase. The source baseline is `315d670d97a645d3f7a0ac1115af106c8a538583`. The desktop icon
is now a pixel-art ZKO handle redrawn from physical-product photos. The exact Windows package was
installed locally and verified for version, settings recovery, and matching icon resources. The
final V3 package also completed an app-only flash, serial readback, and BLE/IMU live validation on
Windows `COM7`, device serial `1C9E`. A dedicated Linux builder will add the DEB later, and a partner
will add the formal macOS DMG later, so Linux and macOS are absent from the current `latest.json`.
D4 is no longer maintained and has no new firmware here.

See the [`v0.3.66` release notes](docs/en/maintainers/releases/v0.3.66.md) for changes, checksums,
and the exact publication scope.

<!-- section:s003 -->
## Recommended first step: let Codex configure it

If you use Codex, install the official-structure **ZKO Ziku setup plugin before configuring the handle manually**. It bundles the `ai-coding-handle` Skill, which can locate the appropriate AutoClipboard release, configure supported Agent status hooks, identify D4/V3 hardware, and run read-only USB, serial, Bluetooth, and application diagnostics.

For mainland China, add the ZKO Marketplace from Gitee first:

```bash
codex plugin marketplace add https://gitee.com/shan-yujun/Communist-Manifesto-Releases.git
codex plugin add zko-ai-coding-handle@zko-lab
```

If Gitee Git is unavailable, add the same Marketplace from GitHub:

```bash
codex plugin marketplace add Lijinzh/Communist-Manifesto-Releases
codex plugin add zko-ai-coding-handle@zko-lab
```

Start a new Codex task after installation, then invoke `$ai-coding-handle`. Claude Code, Cursor, OpenCode, and other Agent Skills-compatible clients can use the portable installer:

```bash
npx skills add https://gitee.com/shan-yujun/Communist-Manifesto-Releases.git --skill ai-coding-handle --agent '*' -g -y --copy
```

If Gitee Git is unavailable, replace the source with `Lijinzh/Communist-Manifesto-Releases` to install from GitHub.

You can also send this request directly to your coding agent:

> Install the `zko-ai-coding-handle` Codex plugin from the Gitee mirror `shan-yujun/Communist-Manifesto-Releases`. If this agent does not support Codex plugins, install the `ai-coding-handle` Skill from `Lijinzh/Communist-Manifesto-Releases` on GitHub. Then install or check AutoClipboard, identify my ZKO D4/V3, and configure Agent hooks and buttons. Ask before changing system settings, installing drivers, or writing firmware.

The Skill may diagnose automatically, but it does not silently reset system Bluetooth settings or flash firmware. Any firmware update still requires a separate, explicit confirmation for the exact device and update plan.

No compatible agent client? Continue with the manual steps below or open the [complete English user guide](docs/en/user-guide.md).

<!-- section:s004 -->
## Five-minute first setup

1. **Install with the Skill or download AutoClipboard manually.** Windows is the primary supported platform; use the package matching your operating system from the [latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest), or the [Gitee mirror](https://gitee.com/shan-yujun/Communist-Manifesto-Releases/releases) if GitHub is unavailable.
2. **Charge the handle.** Connect the USB Type-C port with a suitable cable. A data-capable cable is required for serial diagnostics and firmware updates; a charge-only cable cannot provide those functions.
3. **Turn on or wake the handle.** A new or cleared device opens a 120-second Bluetooth pairing window.
4. **Pair the correct Bluetooth device.** In system Bluetooth settings, select the complete name shown as `CommunistKB-XXXX`. The four-character suffix is generated by the handle; do not type or append it yourself.
5. **Start AutoClipboard and leave it running in the background.** Basic Bluetooth keyboard macros work without AutoClipboard, but Agent status, IMU preview, advanced configuration, and quick launch require the application.
6. **Test the controls.** Rotate the wheel to change Profile, press a macro button, and double-click the wheel's middle button to open `Settings`.

For screenshots, multi-host pairing, Profile details, and troubleshooting, follow the [complete user guide](docs/en/user-guide.md).

<!-- section:s005 -->
## Know the hardware

<p align="center">
  <img src="docs/assets/user-guide/usb-type-c-interface.jpg" alt="USB Type-C interface on the ZKO handle" width="760">
</p>

The USB Type-C connector shown on the left side of the photo is used for charging, serial communication, icon transfer, diagnostics, and firmware updates. Use only the Type-C connector for the documented user workflow; components beside it are not required for normal daily operation.

| Part | Purpose |
| --- | --- |
| USB Type-C | Charging; data cable connection for serial diagnostics and firmware updates |
| 1.14-inch color screen | Shows Profile, Bluetooth state, battery, time, Agent state, and device messages |
| Wheel and middle button | Changes Profile, navigates menus, confirms choices, and opens or exits Settings |
| Four side macro buttons | Sends the macro stored in the current Profile |
| Front light ring | Provides Agent state, Profile, input, and warning feedback |
| IMU motion sensor | Supports orientation preview and the presenter Halo |

<p align="center">
  <img src="docs/assets/user-guide/macro-buttons.webp" alt="Four programmable macro buttons" width="620">
</p>

The default Vibe Coding Profile maps the four buttons to `Right Alt`, `Enter`, `Ctrl+V`, and `Ctrl+Alt+0`. All four mappings can be changed in AutoClipboard.

<!-- section:s006 -->
## Bluetooth name and pairing

The current firmware advertises as:

```text
CommunistKB-XXXX
```

`XXXX` is the last two bytes of the ESP32 MAC address rendered as four uppercase hexadecimal characters. For example, one handle may appear as `CommunistKB-A216`. This is already part of the advertised name; the user does not add the suffix.

<!-- section:s007 -->
### First pairing

1. Open the operating system's Bluetooth settings and choose **Add device**.
2. Wake or power on the handle.
3. Wait for the handle screen to show `PAIR`.
4. Select the full `CommunistKB-XXXX` name shown by the operating system.
5. After pairing, the screen changes to `LINK` when the host connection is ready.

<!-- section:s008 -->
### Pair a second or third computer

1. Double-click the wheel middle button to enter `Settings`.
2. Rotate to `BLE Hosts` and single-click to open it.
3. Select an `EMPTY` slot and single-click it.
4. When `PAIR` appears, add `CommunistKB-XXXX` from the new computer.

The handle stores three host slots. In `BLE Hosts`, single-click a saved slot to switch to it, or long-press a saved slot to delete that host record.

<!-- section:s009 -->
## Wheel and screen controls

<!-- section:s010 -->
### On the normal status screen

| Action | Result |
| --- | --- |
| Rotate up or down | Switch to the previous or next Profile |
| Single-click the middle button | Open the application, shortcut, or URL assigned to the current Profile; AutoClipboard must be running |
| Double-click the middle button | Enter `Settings` |
| Long-press the middle button | Enter `Settings` |

<!-- section:s011 -->
### Inside Settings

| Action | Result |
| --- | --- |
| Rotate up or down | Move through items; change a value while editing |
| Single-click the middle button | Enter, edit, confirm, or save the current item |
| Long-press the middle button | Cancel editing, go back, or exit Settings |

Do not attempt to hold the middle button while rotating the wheel. The physical mechanism does not support that gesture, and Bluetooth host switching does not use it.

<!-- section:s012 -->
## Understand the screen and Agent light

<p align="center">
  <img src="docs/assets/user-guide/agent-status.webp" alt="Agent state light and handle screen" width="620">
</p>

The promotional image demonstrates the visual concept. The current firmware uses the following compact Bluetooth labels:

| Label | Meaning |
| --- | --- |
| `LINK` | Connected to the selected host |
| `WAIT` | Waiting for the saved host to reconnect |
| `PAIR` | Temporarily discoverable for a new pairing |

The screen also shows the current Profile, battery, time, device state, and the number of working Agents. The light ring can reflect idle, working, attention, permission, blocked, and completed states. Agent synchronization requires AutoClipboard and a configured Agent Hook/Bridge.

<!-- section:s013 -->
## AutoClipboard

AutoClipboard is the desktop companion application. It can display the active Bluetooth device, configure Profile names and icons, record macros, adjust the screen, light ring and buzzer, preview IMU orientation, configure the presenter Halo, provide account and free/premium voice-input entry points, and perform controlled firmware updates.

<p align="center">
  <img src="docs/assets/user-guide/autoclipboard-main.webp" alt="AutoClipboard main window" width="820">
</p>

<p align="center">
  <img src="docs/assets/user-guide/autoclipboard-voice.webp" alt="AutoClipboard voice configuration" width="520">
</p>

<p align="center">
  <img src="docs/assets/user-guide/autoclipboard-settings.webp" alt="AutoClipboard device settings" width="900">
</p>

These are real renders from the current AutoClipboard `0.3.62` source, not generated UI mockups. They were captured with isolated clean settings and contain no personal account, Agent-session, or physical-handle identifiers, so signed-out and BLE-disconnected states are expected. For numbered region diagrams, control-by-control effects, and a clear distinction between software-only and hardware-changing settings, read the [AutoClipboard software interface manual](docs/en/software-interface-manual.md). Keep AutoClipboard running in the background when using Agent status synchronization, Profile quick launch, IMU preview, voice input, or the presenter Halo.

<!-- section:s014 -->
## Downloads

Open the [latest GitHub Release](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest) and select the file matching your platform or task:

| Purpose | Asset pattern |
| --- | --- |
| Windows application | `AutoClipboardSetup-<version>.exe` |
| Windows CH343 USB serial driver | `CH343SER.EXE` |
| Linux / Ubuntu application | `auto-clipboard_<version>_<arch>.deb` |
| macOS application, when included in that release | `AutoClipboard-<version>-macOS.dmg` |
| Apple Silicon unnotarized preview | `AutoClipboard-<version>-macOS-unnotarized-preview.dmg` |
| Current V3 handle firmware | `CommunistManifestoKB-firmware-v3-<version>.zip` |
| AI Coding Handle Skill ZIP | `ai-coding-handle-skill-<version>.zip` |

V3 is the currently maintained hardware revision. Do not flash firmware for a different board revision. If you are uncertain, ask the Skill to identify the device before downloading or updating firmware.

### Installing the unnotarized macOS preview

The current preview DMG targets Apple Silicon Macs (M1/M2/M3/M4 and other arm64 systems). It uses an ad-hoc signature and has not yet been notarized by Apple. To install it:

1. Download `AutoClipboard-<version>-macOS-unnotarized-preview.dmg` and compare it with the SHA-256 published on the Release page.
2. Open the DMG and drag `AutoClipboard.app` into `Applications`.
3. Open Terminal and run:

   ```bash
   xattr -cr /Applications/AutoClipboard.app
   ```

4. Open AutoClipboard from Applications. Grant Accessibility, Input Monitoring, or Microphone access when macOS requests permissions for the features you use.

This command only removes the download quarantine attribute from the AutoClipboard bundle; it does not disable Gatekeeper globally. Run it only for a SHA-256-verified copy downloaded from this repository's official Release. Intel Macs cannot run the arm64 preview and require a separate x86_64 build. Once Developer ID credentials are available, the normal macOS package will continue to use Developer ID signing, notarization, and stapling and will not require the `xattr` command.

<!-- section:s015 -->
## Quick troubleshooting

- **`CommunistKB-XXXX` is not visible:** wake the handle, double-click the wheel, open `Settings > BLE Hosts`, select `EMPTY`, and wait for `PAIR` before scanning again.
- **Ubuntu shows only an unnamed HID address:** use `bluetoothctl` to verify that the unique current-scan candidate matches an independently known MAC suffix and exposes HID `0x1812` plus Battery `0x180F` before pairing by address. This is a fallback for affected BlueZ systems, not a replacement for firmware that advertises the complete name.
- **Bluetooth is paired but AutoClipboard is not ready:** keep the handle awake, start AutoClipboard, and let the Skill run read-only `inventory` and `doctor` diagnostics.
- **Macro keys work but Agent status does not:** the Bluetooth HID connection is working; configure the Agent Hook/Bridge and keep AutoClipboard running.
- **No COM port over Type-C:** try a data-capable cable, another USB port, and the signed [CH343 Windows driver guide](docs/en/ch343-driver-installation.md).
- **Firmware update is offered:** verify the V3 device identity and review the exact update plan before confirming.

The [complete troubleshooting chapter](docs/en/user-guide.md#12-troubleshooting) includes more symptoms and step-by-step checks.

<!-- section:s016 -->
## Documentation

```text
English project home (this file)
├─ Complete user guide
│  ├─ Hardware, Bluetooth, wheel, Profiles, and firmware updates
│  ├─ Agent status synchronization
│  ├─ Detailed AutoClipboard interface manual
│  └─ Windows CH343 driver installation and troubleshooting
├─ Maintainer documentation
│  └─ GitHub primary releases and the Gitee China mirror
└─ AI Coding Handle Skill
   ├─ English technical references
   └─ 中文技术参考
```

- [Complete English user guide](docs/en/user-guide.md)
- [Agent status setup](docs/en/agent-signal-setup.md)
- [Detailed AutoClipboard interface manual](docs/en/software-interface-manual.md)
- [Windows CH343 driver installation](docs/en/ch343-driver-installation.md)
- [GitHub and Gitee publishing guide](docs/en/maintainers/gitee-publishing.md)
- [简体中文文档树](README.md)
- [Open-source AI Coding Handle Skill](skills/ai-coding-handle)
- [Product introduction website](https://zkolab.com/)

This repository contains public release assets, user documentation, support scripts, and the MIT-licensed AI Coding Handle Skill. AutoClipboard and firmware application source code remain private.
