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

## Maintainer Upload

The private development repository can publish here automatically when a matching version tag is pushed:

```powershell
git tag v0.3.29
git push origin main
git push origin v0.3.29
```

The GitHub Actions workflow in the private repository builds all release assets and uploads them to this public repository.

If a Windows installer was built manually, upload it from the private repository's `AutoClipboard` directory:

```powershell
gh release upload v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --clobber
```

If the Release does not exist yet:

```powershell
gh release create v0.3.29 .\installer\output\AutoClipboardSetup-0.3.29.exe --repo Lijinzh/Communist-Manifesto-Releases --title "AutoClipboard 0.3.29" --notes "AutoClipboard 0.3.29"
```

Windows machines need GitHub CLI authentication first:

```powershell
winget install --id GitHub.cli
gh auth login
```

## Notes

This repository does not contain source code. Please use the Release page for downloads.
