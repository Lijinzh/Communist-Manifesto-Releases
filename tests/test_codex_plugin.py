from __future__ import annotations

import json
from pathlib import Path
import unittest

from scripts.sync_codex_plugin import PLUGIN_ROOT, ROOT, compare_trees


class CodexPluginTests(unittest.TestCase):
    def test_plugin_skill_matches_canonical_skill(self) -> None:
        self.assertEqual(compare_trees(), [])

    def test_plugin_manifest_is_public_and_branded(self) -> None:
        manifest = json.loads(
            (PLUGIN_ROOT / ".codex-plugin" / "plugin.json").read_text(encoding="utf-8")
        )

        self.assertEqual(manifest["name"], "zko-ai-coding-handle")
        self.assertEqual(manifest["version"], "0.3.64")
        self.assertEqual(manifest["skills"], "./skills/")
        self.assertEqual(manifest["license"], "MIT")
        self.assertEqual(manifest["interface"]["displayName"], "ZKO 字库一键配置")
        self.assertEqual(manifest["interface"]["websiteURL"], "https://zkolab.com/skill.html")
        for asset_key in ("composerIcon", "logo"):
            asset = manifest["interface"][asset_key]
            self.assertTrue((PLUGIN_ROOT / asset).is_file(), asset)

    def test_marketplace_points_to_the_plugin(self) -> None:
        marketplace = json.loads(
            (ROOT / ".agents" / "plugins" / "marketplace.json").read_text(encoding="utf-8")
        )

        self.assertEqual(marketplace["name"], "zko-lab")
        self.assertEqual(marketplace["interface"]["displayName"], "ZKO Lab")
        entry = marketplace["plugins"][0]
        self.assertEqual(entry["name"], "zko-ai-coding-handle")
        self.assertEqual(entry["source"]["path"], "./plugins/zko-ai-coding-handle")
        self.assertEqual(entry["policy"]["installation"], "AVAILABLE")
        self.assertEqual(entry["policy"]["authentication"], "ON_INSTALL")


if __name__ == "__main__":
    unittest.main()
