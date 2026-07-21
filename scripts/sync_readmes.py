#!/usr/bin/env python3
"""Generate and validate the bilingual repository documentation."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DOCUMENTS = (
    {
        "source": ROOT / "docs" / "README.bilingual.md",
        "outputs": {
            "zh-CN": ROOT / "README.md",
            "en": ROOT / "README.en.md",
        },
        "language_nav": {
            "zh-CN": "**简体中文** | [English](README.en.md)",
            "en": "[简体中文](README.md) | **English**",
        },
    },
    {
        "source": ROOT / "docs" / "user-guide.bilingual.md",
        "outputs": {
            "zh-CN": ROOT / "docs" / "user-guide.zh-CN.md",
            "en": ROOT / "docs" / "user-guide.en.md",
        },
        "language_nav": {
            "zh-CN": "**简体中文** | [English](user-guide.en.md) | [返回仓库首页](../README.md)",
            "en": "[简体中文](user-guide.zh-CN.md) | **English** | [Back to repository](../README.en.md)",
        },
    },
)
SECTION_PATTERN = re.compile(
    r"<!-- section:(?P<name>[a-z0-9-]+) -->\s*"
    r"<!-- lang:en -->\s*(?P<en>.*?)\s*"
    r"<!-- lang:zh-CN -->\s*(?P<zh>.*?)\s*"
    r"<!-- endsection -->",
    re.DOTALL,
)
MARKDOWN_LINK_PATTERN = re.compile(r"!?\[[^\]]*\]\((?P<target>[^)]+)\)")
HTML_LINK_PATTERN = re.compile(r"<(?:a|img)\b[^>]*(?:href|src)=\"(?P<target>[^\"]+)\"", re.IGNORECASE)


def parse_source(source: Path) -> list[tuple[str, dict[str, str]]]:
    source_text = source.read_text(encoding="utf-8")
    sections: list[tuple[str, dict[str, str]]] = []
    names: set[str] = set()

    for match in SECTION_PATTERN.finditer(source_text):
        name = match.group("name")
        if name in names:
            raise ValueError(f"duplicate section: {name}")
        names.add(name)

        translations = {
            "en": match.group("en").strip(),
            "zh-CN": match.group("zh").strip(),
        }
        for language, content in translations.items():
            if not content:
                raise ValueError(f"section {name!r} has an empty {language} block")
        sections.append((name, translations))

    if not sections:
        raise ValueError("no bilingual documentation sections found")

    remaining = SECTION_PATTERN.sub("", source_text)
    remaining = re.sub(r"<!--.*?-->", "", remaining, flags=re.DOTALL).strip()
    if remaining:
        raise ValueError("content exists outside a recognized bilingual section")

    return sections


def render(
    source: Path,
    language: str,
    language_nav: dict[str, str],
    sections: list[tuple[str, dict[str, str]]],
) -> str:
    source_name = source.relative_to(ROOT).as_posix()
    generated_notice = f"<!-- Generated from {source_name} by scripts/sync_readmes.py. Do not edit directly. -->"
    content = "\n\n".join(translations[language] for _, translations in sections)
    return f"{generated_notice}\n\n{language_nav[language]}\n\n{content}\n"


def validate_local_links(output_path: Path, content: str) -> list[str]:
    failures: list[str] = []
    targets = [match.group("target") for match in MARKDOWN_LINK_PATTERN.finditer(content)]
    targets.extend(match.group("target") for match in HTML_LINK_PATTERN.finditer(content))

    for raw_target in targets:
        target = raw_target.strip()
        if target.startswith("<") and target.endswith(">"):
            target = target[1:-1]
        if not target or target.startswith("#") or re.match(r"^[a-z][a-z0-9+.-]*://", target, re.IGNORECASE):
            continue

        local_part = target.split("#", 1)[0].split("?", 1)[0]
        if not local_part:
            continue
        resolved = (output_path.parent / local_part).resolve()
        if not resolved.exists():
            failures.append(f"{output_path.relative_to(ROOT)} -> {target}")

    return failures


def sync(check: bool) -> int:
    stale: list[Path] = []
    broken_links: list[str] = []

    for document in DOCUMENTS:
        source = document["source"]
        outputs = document["outputs"]
        language_nav = document["language_nav"]
        try:
            sections = parse_source(source)
        except (OSError, ValueError) as exc:
            print(f"Documentation source error in {source.relative_to(ROOT)}: {exc}", file=sys.stderr)
            return 1

        for language, output_path in outputs.items():
            expected = render(source, language, language_nav, sections)
            broken_links.extend(validate_local_links(output_path, expected))
            actual = output_path.read_text(encoding="utf-8") if output_path.exists() else None
            if actual == expected:
                continue
            if check:
                stale.append(output_path)
            else:
                output_path.write_text(expected, encoding="utf-8", newline="\n")
                print(f"updated {output_path.relative_to(ROOT)}")

    if broken_links:
        print("Broken local documentation links:", file=sys.stderr)
        for failure in broken_links:
            print(f"- {failure}", file=sys.stderr)
        return 1

    if stale:
        paths = ", ".join(str(path.relative_to(ROOT)) for path in stale)
        print(
            f"Generated documentation is stale: {paths}. Run: python scripts/sync_readmes.py",
            file=sys.stderr,
        )
        return 1

    if check:
        print("Bilingual documentation is complete and generated files are current.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify generated documentation without modifying files",
    )
    args = parser.parse_args()
    return sync(args.check)


if __name__ == "__main__":
    raise SystemExit(main())
