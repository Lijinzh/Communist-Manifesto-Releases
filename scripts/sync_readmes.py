#!/usr/bin/env python3
"""Generate and validate the English and Simplified Chinese README files."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "README.bilingual.md"
OUTPUTS = {
    "en": ROOT / "README.md",
    "zh-CN": ROOT / "README.zh-CN.md",
}
GENERATED_NOTICE = (
    "<!-- Generated from docs/README.bilingual.md by scripts/sync_readmes.py. "
    "Do not edit directly. -->"
)
LANGUAGE_NAV = {
    "en": "**English** | [简体中文](README.zh-CN.md)",
    "zh-CN": "[English](README.md) | **简体中文**",
}
SECTION_PATTERN = re.compile(
    r"<!-- section:(?P<name>[a-z0-9-]+) -->\s*"
    r"<!-- lang:en -->\s*(?P<en>.*?)\s*"
    r"<!-- lang:zh-CN -->\s*(?P<zh>.*?)\s*"
    r"<!-- endsection -->",
    re.DOTALL,
)


def parse_source() -> list[tuple[str, dict[str, str]]]:
    source_text = SOURCE.read_text(encoding="utf-8")
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
        raise ValueError("no bilingual README sections found")

    remaining = SECTION_PATTERN.sub("", source_text)
    remaining = re.sub(r"<!--.*?-->", "", remaining, flags=re.DOTALL).strip()
    if remaining:
        raise ValueError("content exists outside a recognized bilingual section")

    return sections


def render(language: str, sections: list[tuple[str, dict[str, str]]]) -> str:
    content = "\n\n".join(translations[language] for _, translations in sections)
    return f"{GENERATED_NOTICE}\n\n{LANGUAGE_NAV[language]}\n\n{content}\n"


def sync(check: bool) -> int:
    try:
        sections = parse_source()
    except (OSError, ValueError) as exc:
        print(f"README source error: {exc}", file=sys.stderr)
        return 1

    stale: list[Path] = []
    for language, output_path in OUTPUTS.items():
        expected = render(language, sections)
        actual = output_path.read_text(encoding="utf-8") if output_path.exists() else None
        if actual == expected:
            continue
        if check:
            stale.append(output_path)
        else:
            output_path.write_text(expected, encoding="utf-8", newline="\n")
            print(f"updated {output_path.relative_to(ROOT)}")

    if stale:
        paths = ", ".join(str(path.relative_to(ROOT)) for path in stale)
        print(
            f"README files are stale: {paths}. Run: python scripts/sync_readmes.py",
            file=sys.stderr,
        )
        return 1

    if check:
        print("README translations are complete and generated files are current.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify generated README files without modifying them",
    )
    args = parser.parse_args()
    return sync(check=args.check)


if __name__ == "__main__":
    raise SystemExit(main())
