#!/usr/bin/env python3
"""Safely flash one locally built app-only firmware package to one identified handle."""
from __future__ import annotations

import argparse
from dataclasses import asdict
import json
from pathlib import Path
import re
import sys


REPO_ROOT = Path(__file__).resolve().parents[4]
AUTOCLIPBOARD_SRC = REPO_ROOT / "AutoClipboard" / "src"
if str(AUTOCLIPBOARD_SRC) not in sys.path:
    sys.path.insert(0, str(AUTOCLIPBOARD_SRC))

from auto_clipboard.device.firmware_package import load_manifest, sha256  # noqa: E402
from auto_clipboard.device.firmware_updater import (  # noqa: E402
    flash_firmware_package,
    probe_connected_firmware_device,
)


SHA256_PATTERN = re.compile(r"[0-9a-f]{64}")


def _write_result(path: Path, payload: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", required=True)
    parser.add_argument("--package-sha256", required=True)
    parser.add_argument("--board", required=True, choices=("d4", "v3"))
    parser.add_argument("--device-serial", required=True)
    parser.add_argument("--result-file", required=True)
    parser.add_argument("--flash", action="store_true")
    args = parser.parse_args()

    package = Path(args.package).resolve()
    result_file = Path(args.result_file).resolve()
    expected_sha = args.package_sha256.strip().lower()
    payload: dict[str, object] = {
        "success": False,
        "status": "invalid_arguments",
        "package": str(package),
        "package_sha256": expected_sha,
        "board": args.board,
        "device_serial": args.device_serial.strip(),
    }

    try:
        if SHA256_PATTERN.fullmatch(expected_sha) is None:
            raise RuntimeError("package SHA-256 must be exactly 64 lowercase hexadecimal characters")
        actual_sha = sha256(package)
        if actual_sha != expected_sha:
            raise RuntimeError(f"package SHA-256 mismatch: expected {expected_sha}, got {actual_sha}")

        manifest = load_manifest(package)
        version = str(manifest.get("version") or "").strip()
        probe = probe_connected_firmware_device()
        if probe.status != "connected" or probe.device is None:
            raise RuntimeError(f"device probe failed: {probe.status}: {probe.detail}")
        device = probe.device
        payload["device"] = asdict(device)
        if device.board != args.board or device.device_serial != args.device_serial.strip():
            raise RuntimeError(
                "connected device identity mismatch: "
                f"expected {args.board}/{args.device_serial.strip()}, "
                f"got {device.board}/{device.device_serial}"
            )

        if not args.flash:
            payload.update(success=True, status="confirmation_required", version=version)
            _write_result(result_file, payload)
            return 0

        result = flash_firmware_package(
            package,
            mode="app",
            port=device.port,
            expected_board=args.board,
            expected_device_serial=args.device_serial.strip(),
            expected_package_sha256=expected_sha,
            confirm_version=version,
        )
        payload.update(asdict(result))
        payload["status"] = "updated" if result.success else (result.error_code or "flash_failed")
        _write_result(result_file, payload)
        return 0 if result.success else 1
    except Exception as exc:  # noqa: BLE001
        payload["status"] = "local_flash_failed"
        payload["detail"] = str(exc)
        _write_result(result_file, payload)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
