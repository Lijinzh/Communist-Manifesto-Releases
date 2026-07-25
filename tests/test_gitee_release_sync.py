from __future__ import annotations

import unittest

from scripts.gitee_release_sync import (
    compare_git_refs,
    compare_release_mirrors,
    release_asset_map,
)


class ReleaseMirrorComparisonTests(unittest.TestCase):
    def test_release_asset_map_rejects_duplicate_names(self) -> None:
        with self.assertRaisesRegex(RuntimeError, "duplicate release asset: app.exe"):
            release_asset_map(
                [
                    {"name": "app.exe", "size": 10},
                    {"name": "app.exe", "size": 10},
                ]
            )

    def test_exact_release_mirror_has_no_failures(self) -> None:
        failures = compare_release_mirrors(
            "v1.2.3",
            {"app.exe": 10, "latest.json": 20},
            "v1.2.3",
            {"app.exe": 10, "latest.json": 20},
        )

        self.assertEqual(failures, [])

    def test_release_mirror_reports_every_difference(self) -> None:
        failures = compare_release_mirrors(
            "v1.2.3",
            {"app.exe": 10, "driver.exe": 30, "latest.json": 20},
            "v1.2.2",
            {"app.exe": 11, "extra.zip": 40, "latest.json": 20},
        )

        self.assertEqual(
            failures,
            [
                "release tag differs: GitHub=v1.2.3, Gitee=v1.2.2",
                "missing on Gitee: driver.exe",
                "extra on Gitee: extra.zip",
                "asset size differs for app.exe: GitHub=10, Gitee=11",
            ],
        )

    def test_git_refs_require_matching_main_and_tags(self) -> None:
        failures = compare_git_refs(
            {"refs/heads/main": "aaa", "refs/tags/v1": "bbb"},
            {"refs/heads/main": "ccc", "refs/tags/v2": "ddd"},
        )

        self.assertEqual(
            failures,
            [
                "Git ref differs for refs/heads/main: GitHub=aaa, Gitee=ccc",
                "missing Git ref on Gitee: refs/tags/v1",
                "extra Git ref on Gitee: refs/tags/v2",
            ],
        )


if __name__ == "__main__":
    unittest.main()
