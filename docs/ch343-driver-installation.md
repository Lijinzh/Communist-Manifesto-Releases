**English** | [简体中文](ch343-driver-installation.zh-CN.md)

# CH343 Windows Serial Driver Installation

CH343SER is the Windows USB-to-serial driver provided by Nanjing Qinheng Microelectronics (WCH). Install it when a handle connected over USB Type-C does not expose a usable COM port, appears as an unknown device in Device Manager, or cannot be discovered by AutoClipboard over serial.

If Windows already shows a working COM port for the handle, you do not need to reinstall the driver.

## Download

- Stable repository download: [CH343SER.EXE](https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/download/v0.3.48/CH343SER.EXE)
- Official WCH page: [CH343SER Windows driver](https://www.wch-ic.com/downloads/CH343SER_EXE.html)

Repository file verification:

| Field | Value |
| --- | --- |
| File | `CH343SER.EXE` |
| Size | `696288` bytes |
| SHA-256 | `99f16f9c4cf9c315dc9a17b29021d82d522014ecc053d9ee1c7b38c214dea40b` |
| Digital signature | Valid |
| Signer | `Nanjing Qinheng Microelectronics Co., Ltd.` |

Do not download similarly named installers from unknown file-sharing sites, chat attachments, or third-party driver portals. Before running the file, open Properties → Digital Signatures and confirm that the signature is valid and belongs to Nanjing Qinheng Microelectronics.

## Installation

1. Close AutoClipboard, serial terminals, and flashing tools that may be using the handle's COM port.
2. Download `CH343SER.EXE`.
3. Run the installer. If User Account Control appears, confirm that the verified publisher is Nanjing Qinheng Microelectronics before selecting Yes.
4. Select the install action in the driver window and wait for the success message. Do not forcibly close the installer while it is working.
5. Disconnect and reconnect the handle's USB Type-C data cable. Restart Windows first if the installer requests it.
6. Open Device Manager and expand Ports (COM & LPT). Confirm that a COM port with a `CH343`, `USB-SERIAL`, or WCH-related name appears.
7. Start AutoClipboard and reopen Device Settings or Firmware Update.

## Check the port with PowerShell

Run this command in PowerShell:

```powershell
Get-CimInstance Win32_SerialPort | Select-Object DeviceID, Name, PNPDeviceID
```

A working device normally reports a `DeviceID` such as `COM10` and a name containing `CH343`, `USB-SERIAL`, or another WCH identifier. Windows assigns the COM number dynamically; do not assume the example port is correct for your computer.

## Troubleshooting

### No COM port appears after installation

- Use a USB Type-C cable that supports data, not a charge-only cable.
- Try another USB port and connect directly to the computer before using an unpowered hub.
- In Device Manager, select Scan for hardware changes.
- Reconnect the handle and check both Ports (COM & LPT) and Other devices.
- Restart Windows if requested by the installer.
- If the problem remains, record the hardware ID and error code shown by Device Manager before requesting diagnostics.

### AutoClipboard still cannot find the handle

- Close serial terminals, PlatformIO Monitor, Arduino Serial Monitor, and any other application that may own the same COM port.
- Restart AutoClipboard.
- Connect only one target handle during firmware maintenance. The Skill and AutoClipboard do not choose arbitrarily between multiple devices.

### Uninstallation

Find the corresponding CH343/WCH serial device in Device Manager and select Uninstall device. Select the option to remove the driver package only when you intentionally want to remove it. Windows may install the driver again when the device is reconnected.

## Scope

This driver only enables Windows USB serial access. It does not pair BLE, install AutoClipboard, or flash handle firmware by itself. Firmware updates still require AutoClipboard or the AI Coding Handle Skill to identify the correct D4/V3 device and obtain explicit user confirmation before flashing.
