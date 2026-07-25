#!/usr/bin/env python3
"""Generate compatibility pages and validate mirrored documentation trees."""

from __future__ import annotations

import argparse
from collections.abc import Iterable
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SECTION_PATTERN = re.compile(r"<!--\s*section:(?P<name>[a-z0-9-]+)\s*-->")
MARKDOWN_LINK_PATTERN = re.compile(r"!?\[[^\]]*\]\((?P<target>[^)]+)\)")
HTML_LINK_PATTERN = re.compile(
    r'<(?:a|img)\b[^>]*(?:href|src)="(?P<target>[^"]+)"',
    re.IGNORECASE,
)


def markdown_paths(root: Path) -> set[Path]:
    if not root.exists():
        return set()
    return {path.relative_to(root) for path in root.rglob("*.md") if path.is_file()}


def section_ids(path: Path) -> tuple[str, ...]:
    return tuple(
        match.group("name")
        for match in SECTION_PATTERN.finditer(path.read_text(encoding="utf-8"))
    )


def render_redirect(language: str, target: str, title: str) -> str:
    notice = "<!-- Generated compatibility page. Do not edit directly. -->"
    if language == "zh-CN":
        return f"{notice}\n\n# 文档已迁移\n\n请阅读[{title}]({target})。\n"
    if language == "en":
        return f"{notice}\n\n# Document moved\n\nRead [{title}]({target}).\n"
    raise ValueError(f"unsupported language: {language}")


def validate_pair_trees(left: Path, right: Path) -> list[str]:
    failures: list[str] = []
    left_paths = markdown_paths(left)
    right_paths = markdown_paths(right)
    for relative in sorted(left_paths - right_paths):
        failures.append(f"missing in {right.name}: {relative.as_posix()}")
    for relative in sorted(right_paths - left_paths):
        failures.append(f"missing in {left.name}: {relative.as_posix()}")
    for relative in sorted(left_paths & right_paths):
        left_ids = section_ids(left / relative)
        right_ids = section_ids(right / relative)
        if left_ids != right_ids:
            failures.append(
                f"section IDs differ for {relative.as_posix()}: "
                f"{left.name}={left_ids}, {right.name}={right_ids}"
            )
    return failures


def _link_targets(content: str) -> list[str]:
    targets = [match.group("target") for match in MARKDOWN_LINK_PATTERN.finditer(content)]
    targets.extend(match.group("target") for match in HTML_LINK_PATTERN.finditer(content))
    return targets


def validate_local_links(paths: Iterable[Path]) -> list[str]:
    failures: list[str] = []
    for path in paths:
        content = path.read_text(encoding="utf-8")
        for raw_target in _link_targets(content):
            target = raw_target.strip()
            if target.startswith("<") and target.endswith(">"):
                target = target[1:-1]
            if (
                not target
                or target.startswith("#")
                or re.match(r"^[a-z][a-z0-9+.-]*://", target, re.IGNORECASE)
            ):
                continue
            local_part = target.split("#", 1)[0].split("?", 1)[0]
            if local_part and not (path.parent / local_part).resolve().exists():
                failures.append(f"{path} -> {target}")
    return failures


def sync(check: bool) -> int:
    del check
    failures = validate_pair_trees(ROOT / "docs" / "zh-CN", ROOT / "docs" / "en")
    failures.extend(
        validate_pair_trees(
            ROOT / "skills" / "ai-coding-handle" / "references" / "zh-CN",
            ROOT / "skills" / "ai-coding-handle" / "references" / "en",
        )
    )
    if failures:
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    return sync(args.check)


if __name__ == "__main__":
    raise SystemExit(main())
