from __future__ import annotations

from pathlib import Path
import unittest


class BuildAssetsTests(unittest.TestCase):
    def test_full_screenshots_are_shared_inputs_not_manual_outputs(self) -> None:
        script = (
            Path(__file__).resolve().parents[1]
            / "scripts"
            / "build_software_interface_manual_assets.py"
        ).read_text(encoding="utf-8")

        self.assertIn('ASSET_DIR = ROOT / "docs" / "assets" / "software-interface-manual"', script)
        self.assertIn(
            'DEVICE_SOURCE = ROOT / "docs" / "assets" / "user-guide" / "autoclipboard-settings.webp"',
            script,
        )
        self.assertNotIn('ASSET_DIR / "main-window-full.webp"', script)
        self.assertNotIn('ASSET_DIR / "device-settings-full.webp"', script)


if __name__ == "__main__":
    unittest.main()
