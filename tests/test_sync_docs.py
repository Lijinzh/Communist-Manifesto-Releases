from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from scripts.sync_docs import (
    render_redirect,
    section_ids,
    validate_local_links,
    validate_pair_trees,
)


class SyncDocsTests(unittest.TestCase):
    def test_pair_trees_report_missing_counterpart(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            zh = root / "zh-CN"
            en = root / "en"
            zh.mkdir()
            en.mkdir()
            (zh / "guide.md").write_text("<!-- section:title -->\n# 指南\n", encoding="utf-8")

            failures = validate_pair_trees(zh, en)

            self.assertEqual(failures, ["missing in en: guide.md"])

    def test_pair_trees_report_section_order_mismatch(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            zh = root / "zh-CN"
            en = root / "en"
            zh.mkdir()
            en.mkdir()
            (zh / "guide.md").write_text(
                "<!-- section:title -->\n# 指南\n<!-- section:setup -->\n## 安装\n",
                encoding="utf-8",
            )
            (en / "guide.md").write_text(
                "<!-- section:title -->\n# Guide\n<!-- section:usage -->\n## Usage\n",
                encoding="utf-8",
            )

            failures = validate_pair_trees(zh, en)

            self.assertEqual(
                failures,
                ["section IDs differ for guide.md: zh-CN=('title', 'setup'), en=('title', 'usage')"],
            )

    def test_section_ids_preserve_document_order(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "guide.md"
            path.write_text(
                "<!-- section:intro -->\n# Guide\n<!-- section:setup -->\n## Setup\n",
                encoding="utf-8",
            )

            self.assertEqual(section_ids(path), ("intro", "setup"))

    def test_render_redirect_is_short_and_language_specific(self) -> None:
        rendered = render_redirect("zh-CN", "zh-CN/user-guide.md", "完整使用指南")

        self.assertEqual(
            rendered,
            "<!-- Generated compatibility page. Do not edit directly. -->\n\n"
            "# 文档已迁移\n\n"
            "请阅读[完整使用指南](zh-CN/user-guide.md)。\n",
        )

    def test_local_link_validator_reports_missing_target(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            document = root / "guide.md"
            document.write_text("[Missing](missing.md)\n", encoding="utf-8")

            failures = validate_local_links([document])

            self.assertEqual(failures, [f"{document} -> missing.md"])


if __name__ == "__main__":
    unittest.main()
