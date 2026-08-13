<!-- section:s001 -->
# Daily-use workflow

This is a stable order for everyday coding, text input, and presentation work. Separating connection, context selection, work, and shutdown makes failures easier to locate.

<!-- section:s002 -->
## Start work

1. Wake the handle and check battery plus the current Profile.
2. After the display shows `LINK`, test one macro in a plain-text field.
3. Start AutoClipboard when you need device settings, Agent status, voice, IMU, or presenter Halo.
4. Confirm that AutoClipboard targets the same `CommunistKB-XXXX` device.

<!-- section:s003 -->
## Choose Profiles and macros

- Use the wheel to switch Profiles.
- The four macro buttons send the shortcuts stored in the current Profile.
- A middle-button click can launch the application, shortcut, or web page bound to the Profile.
- After changing a macro, name, icon, or launch target, confirm that it is saved and retest after switching Profiles.

Record the old value before deleting a Profile, replacing a macro, or changing an external program path.

<!-- section:s004 -->
## Use Agent status

1. Keep AutoClipboard running in the background.
2. Install or refresh hooks through the [Agent status setup guide](../agent-signal-setup.md).
3. Start, await approval, complete, or block a task in the Agent.
4. Observe synchronization across the AutoClipboard Dashboard, handle display, and light ring.

Agent-status failure must not block HID input or device control. If macros work but status does not update, isolate hooks, Activity Store, and the status synchronization path.

<!-- section:s005 -->
## Use voice and presentation features

- The free voice tier on Windows/macOS delegates audio and text to system dictation; AutoClipboard does not read the system transcript.
- The premium tier must use a trusted cloud gateway; the client does not store shared provider secrets.
- Ubuntu has no unified free system-dictation path.
- Presenter Halo and IMU preview depend on the application connection and stop when AutoClipboard exits.
- When `voice_input_enabled` is off, AutoClipboard must not capture microphone audio or make voice requests.

<!-- section:s006 -->
## Switch computers

1. Open `Settings > BLE Hosts`.
2. For a paired computer, choose its `SAVED` slot and wait for `WAIT → LINK`.
3. For a new computer, choose `EMPTY` and pair during the 120-second `PAIR` window.
4. If all three slots are full, delete only a slot you have confirmed is no longer needed.

Do not repeatedly clear every slot when switching fails. First compare the selected handle slot with the system Bluetooth record.

<!-- section:s007 -->
## End work and upgrade

- Normal AutoClipboard exit stops application status/IMU subscriptions but must not intentionally tear down the Windows HID keyboard path.
- Save current settings before an application upgrade; the installer launch path should create a verifiable recovery snapshot.
- Update firmware only when explicitly required, with identity, board, serial-port, and package validation.
- A normal application-region update must preserve NVS, Bluetooth bonds, and SPIFFS icons.
