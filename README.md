# Communist Manifesto Releases

This public repository is the release channel for **AutoClipboard** and **CommunistManifestoKB**.

The main development repository remains private. This repository only hosts compiled release assets, user-facing release notes, and update instructions.

## Download

Open the latest GitHub Release and download the asset for your platform:

- Windows: `AutoClipboardSetup-<version>.exe`
- Linux / Ubuntu: `auto-clipboard_<version>_<arch>.deb`
- macOS: `AutoClipboard-<version>-macOS.dmg`
- ESP32 firmware: `CommunistManifestoKB-firmware-<version>.zip`

## Auto Update

AutoClipboard checks the latest Release in this repository.

- Software update picks the installer matching the current operating system.
- Firmware update picks the `CommunistManifestoKB-firmware-<version>.zip` asset and flashes `firmware.bin` at `0x10000` by default, preserving NVS settings and custom icons.

## Notes

This repository does not contain source code. Please use the Release page for downloads.
