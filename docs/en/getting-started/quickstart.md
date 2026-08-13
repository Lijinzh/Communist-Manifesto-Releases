<!-- section:s001 -->
# Five-minute quickstart

Goal: verify Bluetooth keyboard input and the AutoClipboard installation without flashing firmware or deleting pairing records.

<!-- section:s002 -->
## 1. Choose and install the desktop application

| System | Package | Notes |
| --- | --- | --- |
| Windows x64 | `AutoClipboardSetup-<version>.exe` | Use the Gitee link on the ZKO website first, with GitHub as fallback |
| Ubuntu/Linux amd64 | `auto-clipboard_<version>_amd64.deb` | Download only when the corresponding Release contains this asset |
| macOS | `AutoClipboard-<version>-macOS.dmg` | Treat only a signed and notarized formal DMG as a formal release; previews are explicitly labeled |

Installation is successful when AutoClipboard appears in the system application list. Do not open firmware update yet.

<!-- section:s003 -->
## 2. Wake the handle and select a host slot

1. Power the handle and wake the display.
2. A new device or empty current slot enters `PAIR`.
3. A slot already saved for this computer may show `WAIT` and reconnect automatically.
4. To select manually, open `Settings > BLE Hosts` and choose the target `SAVED` or `EMPTY` slot.

Do not use “hold the middle button while booting to clear all slots” as a normal connection step.

<!-- section:s004 -->
## 3. Pair in system Bluetooth settings

1. Open system Bluetooth settings.
2. Find the complete `CommunistKB-XXXX` name; the final four characters are part of the device identity.
3. Add the device and wait for the display to show `LINK`.
4. If the computer retains an old key after the handle slot was cleared, forget the old system record before pairing again.

<!-- section:s005 -->
## 4. Verify basic input

Open Notepad, TextEdit, or another plain-text editor:

1. Press a macro configured as `Enter` or `Ctrl+V`.
2. Confirm that the editor receives the expected input.
3. Working macros prove that the HID Bluetooth keyboard path is available.

Working macros and a disconnected AutoClipboard status are not contradictory: HID input and application status use separate Bluetooth paths.

<!-- section:s006 -->
## 5. Start AutoClipboard

Continue according to your needs:

- Macros only: the application does not have to remain open.
- Profile launch, device settings, IMU preview, Agent status, voice, or presenter Halo: keep the application running.
- No COM port after connecting a data cable on Windows: read the [CH343 driver guide](../ch343-driver-installation.md).

<!-- section:s007 -->
## What to do first when something fails

- No device name: confirm `PAIR`, then scan again.
- Display shows `WAIT`: select the correct saved slot and enable Bluetooth on that computer.
- Display shows `LINK` but input fails: test in a plain-text editor and verify the current Profile macros.
- Application does not open: re-check installer source, size, and SHA-256; do not flash firmware as the first response.
- Still blocked: open [common workflow tutorials](../guides-and-tutorials/common-workflows.md) or [complete troubleshooting](../user-guide.md#12-troubleshooting).
