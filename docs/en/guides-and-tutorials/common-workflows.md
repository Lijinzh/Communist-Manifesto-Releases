<!-- section:s001 -->
# Common workflow tutorials

These tutorials cover the most common end-to-end tasks. After each task, verify the stated success signal rather than relying on one command exit code.

<!-- section:s002 -->
## Tutorial 1: switch to another paired computer

**Starting state:** two computers were paired into different slots.

1. Open `Settings > BLE Hosts` on the handle.
2. Choose the `SAVED` slot for the destination computer.
3. Enable Bluetooth on that computer and wait for `WAIT → LINK`.
4. Test a macro in a plain-text field.

**Success signal:** the display shows `LINK` and the destination receives macro input. Clicking “disconnect” only on the computer does not switch the handle slot.

<!-- section:s003 -->
## Tutorial 2: add a new computer

1. Choose an `EMPTY` slot.
2. Confirm that the display shows `PAIR`.
3. Within 120 seconds, add the complete `CommunistKB-XXXX` from system Bluetooth settings.
4. Wait for `LINK` and test input.

**Success signal:** the slot becomes saved and reconnects after a reboot. If all three slots are full, delete only one you have confirmed is no longer needed.

<!-- section:s004 -->
## Tutorial 3: show Agent status on the handle

1. Start AutoClipboard and confirm the device connection.
2. Install the current client hook through the [Agent status setup guide](../agent-signal-setup.md).
3. Run a short task that triggers working, approval, done, or blocked state.
4. Compare the Dashboard, display, and light ring.

**Success signal:** all three surfaces express the same state semantics. If Agent status fails while macros work, do not repair Bluetooth pairing.

<!-- section:s005 -->
## Tutorial 4: safely upgrade AutoClipboard

1. Download the installer through the exact versioned website link.
2. Verify Release filename, size, and SHA-256.
3. Record Profiles, launch targets, and important settings.
4. Exit the application normally and run the installer.
5. On first launch, verify settings preservation, then test macros, device connection, and Agent hooks.

**Success signal:** the version changes, user configuration remains, and hooks target the new installation path. If installation is abnormal, restore the pre-upgrade settings snapshot.

<!-- section:s006 -->
## Tutorial 5: distinguish HID, application connection, and serial

| Symptom | Most likely path | First check |
| --- | --- | --- |
| Macros cannot type | HID Bluetooth | Check `LINK`, current Profile, and a plain-text test |
| Macros work, application says disconnected | Application GATT | Keep the handle awake and restart application connection |
| Firmware maintenance cannot find a port | USB serial | Check data cable, Device Manager, and CH343 |
| Agent state does not change | Hook/Activity | Refresh hooks and inspect the Dashboard |

**Success signal:** only the failing path is repaired; already-working paths remain intact.

<!-- section:s007 -->
## Tutorial 6: prepare a V3 firmware update

1. Confirm that the task really requires firmware rather than software or pairing repair.
2. Use a serial port explicitly opened by the user; do not guess a port automatically.
3. Read board type, device serial, and current version.
4. Validate the V3 package version, size, SHA-256, and internal layout.
5. A normal update uses validated app-only writing to the application region.
6. Read identity and version again, then complete serial and BLE/IMU smoke tests.

**Success signal:** the target is the unique V3 device, version readback is correct, and NVS, bonds, and SPIFFS remain. First initialization, recovery, and full flash are separate workflows and must not inherit this tutorial automatically.
