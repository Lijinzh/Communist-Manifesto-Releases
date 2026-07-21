<!-- Generated from docs/software-interface-manual/README.bilingual.md by scripts/sync_readmes.py. Do not edit directly. -->

[简体中文](README.md) | **English** | [Back to the complete guide](../user-guide.en.md) | [Back to repository](../../README.en.md)

# AutoClipboard software interface manual

This manual explains the current AutoClipboard main window and the real **Device Settings / IMU Preview** window area by area. Every control is identified as software-only, hardware-changing, temporary, read-only, or firmware-related, so users can tell what will happen before they click it.

The screenshots are real application screenshots. The Device Settings image was supplied from an actual connected-device session; the crops only add numbered outlines or isolate regions and do not redraw the UI.

> AutoClipboard version shown: `0.3.49`. Device values such as battery percentage, Profile name, COM port, Agent count, and Bluetooth suffix vary by computer and handle.

## How to read the “changes” column

| Label | Meaning |
| --- | --- |
| **View only** | Reads or displays state and does not change settings. |
| **Software** | Changes AutoClipboard or the current computer only. It is not written to the handle. |
| **Hardware** | Sends a configuration command to the handle. The effect remains on the handle according to firmware behavior. |
| **Temporary hardware session** | Uses hardware data or temporarily changes the live device session; it normally stops or returns to normal when disconnected. |
| **Software + hardware** | Changes local integration and also produces a visible or audible result on the handle while AutoClipboard is running. |
| **Type-C / firmware** | Uses the USB serial path and can replace handle firmware. Treat this as maintenance, not an ordinary preference. |

Changing a value in Device Settings is not always a harmless preview. Brightness, screen, buzzer, theme, power policy, Profile selection, and macros can be sent to the handle. Quick-launch paths and presenter Halo speed are local software settings.

## 1. Main window overview

<p align="center">
  <img src="assets/main-window-numbered.webp" alt="AutoClipboard main window numbered overview" width="920">
</p>

| Number | Area | Primary role |
| --- | --- | --- |
| 1 | Device and Agent status | Shows Bluetooth, battery, Agent-to-ring synchronization, and the four quick actions. |
| 2 | Clipboard and Typeless workspace | Receives text, automatically copies it, shows capture state, and exposes software settings. |
| 3 | Agent dashboard | Summarizes Codex/Claude tasks and their current states. |

The main window is mainly a software workspace. It does not rewrite handle configuration by itself. Hardware effects occur only when a specific action sends a signal or opens Device Settings.

## 2. Main-window device status and quick actions

<p align="center">
  <img src="assets/main-device-status.webp" alt="AutoClipboard device status and quick actions" width="900">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Title, subtitle, and `Waiting for input` | Identifies the application and current text-capture state. | **View only** | The status changes when Typeless capture starts, succeeds, retries, or fails. |
| `BLE connected: CommunistKB-XXXX` | Shows the handle selected by the AutoClipboard BLE/GATT session. | **View only** | A complete `CommunistKB-` name plus the real four-character suffix confirms which handle the software is using. |
| Device and battery line | Summarizes Bluetooth keyboard readiness and estimated battery percentage. | **View only** | Helps distinguish a working HID keyboard link from the AutoClipboard device-data session. |
| Agent and ring line | Shows the aggregated Agent state and the target ring animation. | **View only / software + hardware output** | For example, working tasks can produce the current-theme marquee effect on the handle. |
| `Connect another host` | Opens the three-host instructions and then Windows Bluetooth settings. | **Software entry + hardware pairing** | The user must first select an `EMPTY` slot under `Settings > BLE Hosts` on the handle; it then opens a 120-second pairing window for the new computer. |
| `Device Settings` | Opens the detailed configuration and IMU window. | **No change by opening it** | Hardware changes occur only after using controls inside that window. |
| `Configure status light` | Installs or repairs the AutoClipboard portions of Codex `hooks.json` and Claude `settings.json`, with backup and confirmation. | **Software + hardware** | Agent lifecycle events can be collected locally and synchronized to the handle ring while AutoClipboard is running. |
| `Test light effect` | Sends one selected Agent state to the handle. | **Temporary hardware session** | Tests idle breathing, working marquee, yellow attention/permission, red blocked, green completed, or off without changing the Agent task itself. |

`Connect another host` does not invent or append the Bluetooth suffix. Pair the exact `CommunistKB-XXXX` name broadcast by the handle.

## 3. Main-window clipboard and Typeless area

<p align="center">
  <img src="assets/main-editor-typeless.webp" alt="AutoClipboard clipboard editor and Typeless capture area" width="900">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Global-mode hint | Explains whether text emitted by Typeless in other Windows input fields will be captured. | **View only** | When global mode is off, only text entered inside AutoClipboard is auto-copied. |
| Large editor | Accepts typed or pasted text and commits it to the system clipboard. | **Software** | The latest committed text becomes available for paste in other applications. |
| `Alt` / Typeless pulse panel | Shows whether the Right Alt trigger is idle, armed, captured, timed out, or unavailable. | **Software** | With global mode enabled on Windows, Right Alt arms one external Typeless capture. |
| Character count | Shows the current editor length. | **View only** | Useful for confirming a long capture was complete. |
| `Software Settings` | Opens local application preferences. | **Software**, except optional Agent completion output | See the detailed list below. |
| `Clear` | Clears the editor content. | **Software** | Removes the visible buffer; it does not reset the handle or Bluetooth pairing. |

### What “Software Settings” controls

| Setting group | Effect |
| --- | --- |
| Close behavior | Chooses minimize-to-tray/background operation or direct exit. Exiting stops live Agent, quick-launch, IMU, and other background services. |
| Autostart and always-on-top | Changes Windows application behavior only. |
| Agent dashboard | Shows or hides the right-side dashboard. |
| Strong completion alert | Lets completed Agent sessions trigger a hardware buzzer and ring flash; volume is configurable. |
| Global hotkey and global mode | Controls Windows-level capture and the Right Alt Typeless workflow. |
| Model usage query | Stores the selected New API/CCSwitch query configuration locally and displays returned usage in the dashboard. Credentials remain on the current computer. |
| Language | Selects Chinese or English UI. |
| Software update | Downloads and installs a newer AutoClipboard application. This updates the desktop software, not handle firmware. |

## 4. Agent dashboard

<p align="center">
  <img src="assets/main-agent-dashboard.webp" alt="AutoClipboard Agent dashboard" width="430">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Source filter | Limits the list to all sources, Codex, Claude, or other supported sources. | **Software** | Only the visible dashboard list changes; the Agent task is not modified. |
| Totals | Shows total, working, waiting, blocked, and completed-today counts. | **View only** | Provides a quick workload summary. |
| Task rows | Shows a shortened task identifier and normalized state. | **View only** | Active rows update as Hook/Bridge events arrive. |
| Completed-row dismissal, when visible | Hides completed history from this dashboard. | **Software** | It does not delete the original Codex or Claude conversation. |

When status-light integration is configured, normalized states can also drive the handle: idle uses slow breathing, working uses a marquee, permission uses yellow flashing, blocked uses red warning, and completed uses green breathing.

## 5. Device Settings / IMU Preview overview

<p align="center">
  <img src="assets/device-settings-numbered.webp" alt="Device Settings numbered overview" width="1180">
</p>

| Number | Area | Primary role |
| --- | --- | --- |
| 1 | Connection and dashboard layout | Identifies the BLE device and controls only the desktop card layout. |
| 2 | IMU 3D preview | Visualizes orientation, records data, calibrates the sensor, and controls temporary performance mode. |
| 3 | Profile, macros, and quick launch | Selects a Profile, configures four hardware macros, and binds a local quick-launch target. |
| 4 | Device basics, appearance, and power | Controls hardware light/screen/sound/power plus local presenter Halo speeds. |
| 5 | Device maintenance | Selects Type-C serial, repairs the software BLE session, clears pairing, and updates firmware. |

The window mixes software-only and hardware-changing controls. Read the tables below before using `Write to device`, pairing deletion, deep sleep, or firmware actions.

## 6. Connection and layout bar

<p align="center">
  <img src="assets/device-top-status.webp" alt="Device Settings connection and layout bar" width="1180">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Bluetooth connection text | Shows the BLE handle currently supplying device state and IMU data. | **View only** | Confirms the real `CommunistKB-XXXX` target. |
| Layout selector, such as `Default layout` | Selects a saved dashboard arrangement. | **Software** | Changes card placement on this computer only. |
| `Unlock layout` | Enables card moving, resizing, adding, and removing. | **Software** | Does not change firmware or the physical handle. |
| Gear button | Opens dashboard/system layout controls. | **Software** | Used for layout management rather than device configuration. |

The BLE status at the top and the Type-C serial selector in the maintenance area are different connections. BLE carries live state/configuration; Type-C is required for serial identity and firmware maintenance.

## 7. IMU 3D preview

<p align="center">
  <img src="assets/device-imu-preview.webp" alt="Device Settings IMU preview controls" width="500">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Quaternion, model, axes, roll/pitch/yaw, and rates | Displays orientation frames received from the handle. | **View only** | The 3D model follows handle rotation and exposes frame/notification health. |
| `Start IMU Preview` | Starts the AutoClipboard BLE IMU subscription. | **Temporary hardware session** | Live orientation data appears until preview is stopped or the session disconnects. |
| `Record IMU CSV` | Writes received frames to a CSV log on the computer. | **Software** | Produces a diagnostic data file; it does not change the sensor. |
| `Sensor calibration` | Sends `imu:gyro-bias-calibrate`; the handle must remain completely still for about five seconds. | **Hardware** | Recalculates gyro bias so stationary drift is reduced. Movement during calibration can make the result worse. |
| `Reset preview heading` | Rotates only the desktop preview reference. | **Software** | Makes the model face the preferred screen direction without changing sensor axes or firmware calibration. |
| `IMU game/performance mode` | Uses the V3 high-rate sensor/orientation/BLE profile when supported. | **Temporary hardware session** | Raises update rates for smoother preview; the device returns to normal mode after BLE disconnect. |
| Bottom diagnostics | Shows Euler angles, quaternion, BLE target, IMU state, and notify rate. | **View only** | Helps determine whether the connection is alive and frames are arriving. |

Calibration and preview-heading reset are not the same operation: calibration changes sensor bias on the handle; heading reset only changes how the current computer draws the model.

## 8. Profile, four external macros, and quick launch

<p align="center">
  <img src="assets/device-profile-and-quick-launch.webp" alt="Device Settings Profile macros and quick launch" width="1120">
</p>

### Profile and macros

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Profile selector | Chooses the Profile being viewed and configured. Selecting another mode can also send the active `ai_mode` and read that Profile's macros. | **Hardware + view** | The handle screen, icon/theme behavior, and four macro slots follow the selected Profile. |
| Display name | Changes the desktop display-name override. | **Software** unless later included in an explicit device/icon workflow | The local label changes; editing the name alone does not automatically rename hardware. |
| `New Profile` | Allocates an available custom Profile slot and prepares local defaults. | **Software draft** | The user must finish the icon/macros and write or upload the relevant data before the handle is fully configured. |
| `Restore current Profile` | Loads built-in defaults and, when connected, sends screen mode, Profile mode, theme mode, and default macros. | **Hardware** | The selected Profile is returned to the software-defined default configuration. |
| EXT1–EXT4 capture buttons and dropdowns | Define the four shortcut macros. Editing controls prepares values; it does not guarantee the handle has them yet. | **Software draft** | The visible fields change until written. |
| `Read device` | Requests `macro:get`. | **View only** | Replaces the visible fields with the macros currently stored for the active hardware Profile. |
| `Write to device` | Sends four `macro:set` commands and reads back the result. | **Hardware** | The four physical side buttons use the new shortcuts for this Profile. |
| `Restore default` | Sends `macro:reset` for the active Profile. | **Hardware** | Restores that Profile's default four macros immediately. |

### Quick-launch application

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Path/URL field | Holds an installed application, shortcut, portable file, or HTTP/HTTPS URL for the current Profile. | **Software** | The value is stored in AutoClipboard settings on this computer, not in ESP32 firmware. |
| `Choose installed app` | Opens the local application picker. | **Software** | Fills the target and can update the local Profile icon association. |
| `Save binding` | Saves the current target for this Profile. | **Software** | A single click of the wheel middle button on the normal handle screen opens the target while AutoClipboard is running. |
| `Clear binding` | Removes the local target. | **Software** | Single-click quick launch does nothing for that Profile on this computer. |

Quick launch and hardware macros are independent: a quick-launch target stays on the computer, while EXT1–EXT4 mappings are written to the handle.

## 9. Device basics, appearance, and power

<p align="center">
  <img src="assets/device-appearance-and-power.webp" alt="Device Settings appearance and power controls" width="900">
</p>

| Item | What it does | Changes | Result |
| --- | --- | --- | --- |
| Ring brightness | Sends `cfg:ring_brightness`. | **Hardware** | Changes front ring LED brightness. |
| Screen brightness | Sends `cfg:lcd_brightness`. | **Hardware** | Changes the handle color-screen backlight. |
| Buzzer volume | Sends `cfg:buzzer_volume`. | **Hardware** | Changes ordinary handle feedback volume. |
| Strong-alert volume | Sends `cfg:agent_alert_buzzer_volume`. | **Hardware** | Changes the buzzer level used by Agent strong-completion alerts. |
| Halo X/Y speed | Saves presenter-axis sensitivity in AutoClipboard. | **Software** | Changes how fast the on-screen presenter Halo moves horizontally and vertically; it does not change the IMU sensor. |
| Low-battery sound and prominent popup | Sends the low-battery alert setting. | **Hardware** | Enables or disables the handle's stronger low-battery feedback. |
| Screen mode | Sends status, minimal, or backlight-off mode. | **Hardware** | Changes how much the handle screen shows or turns its backlight off. |
| Ring theme | Sends follow-screen, preset, or custom color theme values. | **Hardware** | Changes the base color/theme used by ring effects. Agent warning colors may override the base theme for clarity. |
| Battery and voltage | Displays live device power information. | **View only** | Used to judge charge state and whether the reported voltage is plausible. |
| Auto screen-off | Sends the standby timeout. | **Hardware** | Turns the display off after the configured idle period while keeping the device otherwise available. |
| Super power saving / deep sleep | Sends deep-sleep enable and timeout. | **Hardware** | Disconnects Bluetooth after long inactivity. Touching or moving the handle wakes it, but Agent alerts cannot arrive while asleep. |
| Screen mode selector near the bottom | Same hardware screen-mode setting presented in the card layout. | **Hardware** | Status, minimal, or backlight-off behavior. |

Power-policy rules require a non-zero screen-off timeout to occur before deep sleep. Older firmware may leave these controls disabled until a supported V3 firmware is installed.

## 10. Device maintenance, Bluetooth recovery, and firmware

<p align="center">
  <img src="assets/device-maintenance.webp" alt="Device Settings maintenance controls" width="520">
</p>

| Item | What it does | Changes | Result / caution |
| --- | --- | --- | --- |
| Serial-port selector | Selects the CH343/WCH Type-C data port. | **View/selection** | A charge-only cable will not provide a usable COM port. |
| `Refresh ports` | Re-enumerates local serial ports. | **Software** | Newly connected ports can appear in the list. |
| `Connect selected port` | Opens the selected serial device and validates identity/status. | **Type-C session** | Enables serial diagnostics and the guarded firmware workflow; opening the session alone does not flash firmware. |
| `Clear Bluetooth pairing` | Sends the confirmed pairing-clear command to the handle. | **Hardware, destructive to pairing records** | Saved Bluetooth keys are removed and the computers must pair again. Do not use it as the first response to a normal reconnect delay. |
| Bluetooth recovery summary | Shows reconnect phase and recent device activity. | **View only** | Helps distinguish a stalled app session from a dead device. |
| `Repair Bluetooth connection` | Restarts the AutoClipboard BLE/GATT connection first and requests broader system recovery only after failure. | **Software / connection session** | Attempts to restore status and IMU communication without erasing pairing. |
| `Check for updates` | Checks the release source and compares firmware versions after device identity is known. | **View only / network** | Reports whether a newer compatible package exists. |
| `One-click update` | Downloads, validates, flashes, and verifies the compatible firmware package through Type-C. | **Type-C / firmware** | Replaces handle firmware. Use the correct physical device, a data cable, and uninterrupted power. |
| `Local firmware package` | Selects a local package for the guarded flash workflow. | **Type-C / firmware** | Intended for recovery or controlled testing; an incorrect board package can make the device unavailable. |

Firmware update is different from the `Software Update` in AutoClipboard settings. Software Update replaces the Windows application; this maintenance area replaces the handle firmware.

## 11. Recommended safe workflow

1. Confirm the full Bluetooth name and read-only status first.
2. For a Profile change, select the Profile, use `Read device`, edit the four fields, then use `Write to device` and verify by pressing each physical button in a safe text editor.
3. Save quick-launch targets separately; remember they exist only on this computer and require AutoClipboard in the background.
4. Adjust brightness, sound, theme, and screen values one group at a time so the physical effect is easy to verify.
5. Keep the handle still during sensor calibration. Use preview-heading reset when only the displayed direction is inconvenient.
6. Use `Repair Bluetooth connection` before clearing pairing.
7. Use firmware controls only after selecting and validating the correct Type-C serial device.

Return to the [complete user guide](../user-guide.en.md) for Bluetooth pairing, wheel gestures, hardware ports, Skill installation, and troubleshooting.
