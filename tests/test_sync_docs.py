from __future__ import annotations

from pathlib import Path
import tempfile
import unittest

from scripts.sync_docs import (
    Redirect,
    render_redirect,
    section_ids,
    sync_redirects,
    validate_document_pair,
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

    def test_sync_redirects_reports_stale_page_in_check_mode(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            target = root / "docs" / "zh-CN" / "guide.md"
            legacy = root / "docs" / "guide.zh-CN.md"
            target.parent.mkdir(parents=True)
            legacy.parent.mkdir(parents=True, exist_ok=True)
            target.write_text("# 指南\n", encoding="utf-8")
            legacy.write_text("old body\n", encoding="utf-8")
            redirects = (
                Redirect("docs/guide.zh-CN.md", "zh-CN", "zh-CN/guide.md", "指南"),
            )

            stale = sync_redirects(root, redirects, check=True)

            self.assertEqual(stale, [Path("docs/guide.zh-CN.md")])

    def test_document_pair_requires_matching_section_ids(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            zh = root / "README.md"
            en = root / "README.en.md"
            zh.write_text("<!-- section:intro -->\n# 中文\n", encoding="utf-8")
            en.write_text("<!-- section:download -->\n# English\n", encoding="utf-8")

            failures = validate_document_pair(zh, en, label="root README")

            self.assertEqual(
                failures,
                ["section IDs differ for root README: zh-CN=('intro',), en=('download',)"],
            )


if __name__ == "__main__":
    unittest.main()
