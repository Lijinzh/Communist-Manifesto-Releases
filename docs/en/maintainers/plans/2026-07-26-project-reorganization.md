<!-- section:s001 -->
# Project Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to execute this plan task by task. Steps use checkbox syntax for tracking.

**Goal:** Build two primary READMEs, mirrored Chinese and English documentation trees, mirrored Skill reference trees, unified validation, and an exact GitHub/Gitee release mirror without losing content or breaking public documentation paths.

**Architecture:** Canonical documents live under `docs/zh-CN` and `docs/en`; `scripts/sync_docs.py` generates compatibility pages at legacy paths. Testable Python functions perform documentation validation, release comparison, and anonymous asset checks, while PowerShell only orchestrates publication.

**Tech Stack:** Python 3 standard library, PowerShell, Git, GitHub/Gitee HTTP APIs, GitHub Actions, and Markdown.

---

<!-- section:s002 -->
### Task 1: Build the documentation synchronizer

**Files:**
- Create: `scripts/sync_docs.py`
- Create: `tests/test_sync_docs.py`

- [ ] Write failing tests for mismatched tree paths, mismatched section IDs, compatibility-page rendering, and broken local links.
- [ ] Run `uv run --no-project python -m unittest tests.test_sync_docs -v`; expect failure because the module does not exist.
- [ ] Implement `markdown_paths()`, `section_ids()`, `render_redirect()`, `validate_pair_trees()`, `validate_local_links()`, and `sync(check)`.
- [ ] Run the tests again; expect all tests to pass.
- [ ] Run `git diff --check`.
- [ ] Stage only these files and commit `test: add bilingual documentation validation`.

Required interfaces:

```python
def markdown_paths(root: Path) -> set[Path]: ...
def section_ids(path: Path) -> tuple[str, ...]: ...
def render_redirect(language: str, target: str, title: str) -> str: ...
def validate_pair_trees(left: Path, right: Path) -> list[str]: ...
def validate_local_links(paths: Iterable[Path]) -> list[str]: ...
def sync(check: bool) -> int: ...
```

<!-- section:s003 -->
### Task 2: Migrate project documentation and generate compatibility pages

**Files:**
- Move: `docs/user-guide.zh-CN.md` → `docs/zh-CN/user-guide.md`
- Move: `docs/user-guide.en.md` → `docs/en/user-guide.md`
- Move: `docs/software-interface-manual/README.md` → `docs/zh-CN/software-interface-manual.md`
- Move: `docs/software-interface-manual/README.en.md` → `docs/en/software-interface-manual.md`
- Move: `docs/agent-signal-setup.md` → `docs/zh-CN/agent-signal-setup.md`
- Create: `docs/en/agent-signal-setup.md`
- Move: `docs/ch343-driver-installation.zh-CN.md` → `docs/zh-CN/ch343-driver-installation.md`
- Move: `docs/ch343-driver-installation.md` → `docs/en/ch343-driver-installation.md`
- Move: `docs/gitee-publishing.md` → `docs/zh-CN/maintainers/gitee-publishing.md`
- Create: `docs/en/maintainers/gitee-publishing.md`
- Modify: canonical documents to add stable `<!-- section:id -->` markers and correct relative links
- Modify: compatibility mappings in `scripts/sync_docs.py`

- [ ] Move existing bodies with `git mv` to preserve history.
- [ ] Add English counterparts for Agent status and Gitee publishing documentation.
- [ ] Add the same ordered section IDs to every document pair.
- [ ] Configure compatibility pages for every old public path, including the three `.bilingual.md` files.
- [ ] Run `uv run --no-project python scripts/sync_docs.py` to generate compatibility pages.
- [ ] Run `uv run --no-project python scripts/sync_docs.py --check`; expect success.
- [ ] Run `git diff --check` and confirm all removed bodies exist at canonical paths.
- [ ] Commit `docs: organize mirrored documentation trees`.

<!-- section:s004 -->
### Task 3: Migrate and translate Skill technical references

**Files:**
- Move: `skills/ai-coding-handle/references/*.md` → `skills/ai-coding-handle/references/en/*.md`
- Create: `skills/ai-coding-handle/references/zh-CN/*.md`
- Modify: `skills/ai-coding-handle/SKILL.md`
- Modify: Skill compatibility mappings in `scripts/sync_docs.py`

- [ ] Move the five existing English references into `references/en/` with `git mv`.
- [ ] Create same-name Chinese references without changing commands, statuses, JSON fields, or safety boundaries.
- [ ] Add matching ordered section IDs to every pair.
- [ ] Update `SKILL.md` so English is the default tree and Chinese conversations may use the Chinese tree.
- [ ] Generate compatibility pages at the original `references/*.md` paths.
- [ ] Run documentation tests and `sync_docs.py --check`.
- [ ] Commit `docs: add mirrored skill reference trees`.

<!-- section:s005 -->
### Task 4: Clean up primary READMEs, rules, CI, and assets

**Files:**
- Modify: `README.md`
- Modify: `README.en.md`
- Modify: `AGENTS.md`
- Modify: `.github/workflows/readme-sync.yml`
- Modify: `scripts/build_software_interface_manual_assets.py`
- Delete: `scripts/sync_readmes.py`
- Move: `docs/software-interface-manual/assets/*` → `docs/assets/software-interface-manual/*`
- Delete: proven duplicate or unreferenced full-screenshot intermediates

- [ ] Add corresponding tree navigation to both root READMEs and reduce repeated details to summaries and links.
- [ ] Make `AGENTS.md` bilingual and require paired documentation changes and validation.
- [ ] Broaden CI path triggers and run unit tests, documentation checks, and PowerShell syntax checks.
- [ ] Make the image builder read shared full screenshots directly and generate only referenced crops and numbered images.
- [ ] Move software-manual images and update both language references.
- [ ] Delete SHA-256-identical files and unreferenced intermediates.
- [ ] Remove the old README generator and standardize on `sync_docs.py`.
- [ ] Run tests, documentation checks, image reference scans, and `git diff --check`.
- [ ] Commit `refactor: clarify repository documentation structure`.

<!-- section:s006 -->
### Task 5: Repair release verification with TDD

**Files:**
- Modify: `scripts/gitee_release_sync.py`
- Modify: `scripts/sync-github-to-gitee.ps1`
- Create: `tests/test_gitee_release_sync.py`
- Modify: `docs/zh-CN/maintainers/gitee-publishing.md`
- Modify: `docs/en/maintainers/gitee-publishing.md`

- [ ] Write failing tests for different tags, missing assets, extra assets, different sizes, and exact matches.
- [ ] Run `uv run --no-project python -m unittest tests.test_gitee_release_sync -v`; expect failure because the comparison function does not exist.
- [ ] Implement pure `release_asset_map()` and `compare_release_mirrors()` functions.
- [ ] Extend `verify_public_mirror()` to fetch both latest releases, compare exact assets, and anonymously read every Gitee download URL.
- [ ] Add GitHub/Gitee `main` and tag-reference comparison.
- [ ] Make formal synchronization delete extra assets from the current latest Gitee release by default without deleting historical releases.
- [ ] Update PowerShell orchestration and both maintainer documents.
- [ ] Run unit tests, PowerShell AST syntax checks, documentation checks, and `git diff --check`.
- [ ] Commit `fix: verify exact GitHub and Gitee release parity`.

Required comparison interfaces:

```python
def release_asset_map(release: dict[str, object]) -> dict[str, int]: ...
def compare_release_mirrors(
    github_tag: str,
    github_assets: dict[str, int],
    gitee_tag: str,
    gitee_assets: dict[str, int],
) -> list[str]: ...
```

<!-- section:s007 -->
### Task 6: Verify, push, and repair the live mirror

**Files:**
- Modify only in-scope files if final verification exposes an omission

- [ ] Run `uv run --no-project python -m unittest discover -s tests -v`.
- [ ] Run `uv run --no-project python scripts/sync_docs.py --check`.
- [ ] Run PowerShell AST syntax checks for every PowerShell file.
- [ ] Run `git diff --check` and `git status --short`.
- [ ] Push `main` to GitHub.
- [ ] Configure or verify the Gitee SSH remote and push `main` plus all tags.
- [ ] Run formal mirror synchronization to repair missing and incorrect `v0.3.51` assets.
- [ ] Run strict anonymous verification and confirm both platforms use `v0.3.51`, with eight identical assets by name and size.
- [ ] Run `git status --short --branch` and confirm a clean worktree with matching code refs on both remotes.
