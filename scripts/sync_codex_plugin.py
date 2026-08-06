from __future__ import annotations

import argparse
import filecmp
from pathlib import Path
import shutil


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "skills" / "ai-coding-handle"
PLUGIN_ROOT = ROOT / "plugins" / "zko-ai-coding-handle"
TARGET = PLUGIN_ROOT / "skills" / "ai-coding-handle"


def relative_files(root: Path) -> set[Path]:
    return {path.relative_to(root) for path in root.rglob("*") if path.is_file()}


def compare_trees(source: Path = SOURCE, target: Path = TARGET) -> list[str]:
    failures: list[str] = []
    source_files = relative_files(source)
    target_files = relative_files(target) if target.exists() else set()

    for path in sorted(source_files - target_files):
        failures.append(f"missing from plugin: {path.as_posix()}")
    for path in sorted(target_files - source_files):
        failures.append(f"extra in plugin: {path.as_posix()}")
    for path in sorted(source_files & target_files):
        if not filecmp.cmp(source / path, target / path, shallow=False):
            failures.append(f"content differs: {path.as_posix()}")
    return failures


def sync_plugin() -> None:
    resolved_target = TARGET.resolve()
    resolved_plugin_root = PLUGIN_ROOT.resolve()
    if resolved_target.parent != (resolved_plugin_root / "skills").resolve():
        raise RuntimeError(f"refusing to replace unexpected target: {resolved_target}")
    if TARGET.exists():
        shutil.rmtree(TARGET)
    shutil.copytree(SOURCE, TARGET)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Keep the marketplace plugin Skill byte-identical to the canonical public Skill."
    )
    parser.add_argument("--check", action="store_true", help="report drift without writing files")
    args = parser.parse_args()

    if not args.check:
        sync_plugin()

    failures = compare_trees()
    if failures:
        for failure in failures:
            print(failure)
        return 1
    print("Codex plugin Skill is synchronized.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
