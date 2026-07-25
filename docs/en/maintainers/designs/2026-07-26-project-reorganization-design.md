# Project Reorganization and Bilingual Documentation Design

## Goal

Reorganize the repository without breaking existing public documentation paths or losing necessary content. The target is two primary READMEs, two strictly mirrored language trees, one shared asset area, one isolated Skill distribution area, and a verifiable dual-platform release process.

## Confirmed problems

- Three bilingual source files generate six public documents, while sources and generated outputs share the same visible hierarchy and have unclear ownership.
- `docs/software-interface-manual/` contains several substantive README files, making the entry point and source of truth difficult to identify.
- Some documents are generated and others are maintained manually, with inconsistent language coverage and CI triggers.
- Skill technical references exist only in English and are outside the repository-wide bilingual rules.
- Software-interface assets include an exact duplicate and committed full-image intermediates that no document references.
- `gitee_release_sync.py verify` only checks that Gitee metadata exists; it neither compares the latest GitHub and Gitee releases nor verifies anonymous asset reads.
- The live `v0.3.51` releases currently differ: GitHub has eight assets and Gitee has seven, with different Linux packages and `latest.json` files.

## Documentation architecture

Only two substantive README files remain at the repository root:

```text
README.md       Chinese entry point, downloads, quick start, and Chinese documentation tree
README.en.md    English entry point, downloads, quick start, and English documentation tree
```

Detailed documents move into two trees with identical relative paths:

```text
docs/
├─ zh-CN/
│  ├─ user-guide.md
│  ├─ software-interface-manual.md
│  ├─ agent-signal-setup.md
│  └─ maintainers/
│     ├─ ch343-driver-installation.md
│     ├─ gitee-publishing.md
│     └─ designs/
├─ en/
│  └─ the same relative path set as zh-CN
└─ assets/
   ├─ user-guide/
   └─ software-interface-manual/
```

The Skill retains its platform-required entry point while its technical references become mirrored trees:

```text
skills/ai-coding-handle/
├─ SKILL.md
└─ references/
   ├─ zh-CN/
   └─ en/
```

`AGENTS.md`, `SKILL.md`, and `LICENSE` retain fixed paths for platform discovery or legal reasons. `AGENTS.md` contains both Chinese and English rules, while `SKILL.md` routes Codex to the appropriate reference tree.

## Compatibility policy

Existing public documentation paths are not removed. Each legacy path becomes a short generated compatibility page that links to the new Chinese or English canonical document. Compatibility pages no longer carry a second copy of the body text, preserving external links while eliminating substantive duplication.

The paths include, but are not limited to:

- `docs/user-guide.zh-CN.md`
- `docs/user-guide.en.md`
- `docs/software-interface-manual/README.md`
- `docs/software-interface-manual/README.en.md`
- `docs/ch343-driver-installation*.md`
- `docs/agent-signal-setup.md`
- `docs/gitee-publishing.md`
- the three existing `.bilingual.md` paths
- `skills/ai-coding-handle/references/*.md`

## Loss-prevention migration

1. Move existing public bodies to canonical paths with `git mv` so history remains traceable.
2. Add missing language counterparts without shortening bodies during migration.
3. Generate and validate compatibility pages for old paths.
4. Delete exact duplicate images and unreferenced intermediates only after both trees and all links pass validation.
5. Shorten a primary README only when the complete detail remains in a linked document, replacing the repeated block with a summary and link.
6. Before every deletion, inspect references, hashes, and the Git diff so each fact remains in at least one canonical document per language.

## Bilingual synchronization mechanism

A unified `scripts/sync_docs.py` tool will:

- Require identical relative Markdown path sets in `docs/zh-CN` and `docs/en`.
- Require identical relative path sets in `skills/ai-coding-handle/references/zh-CN` and `en`.
- Require matching ordered stable `section` IDs in each document pair.
- Verify that both root README navigation trees point to corresponding existing documents.
- Validate local links in canonical documents and compatibility pages.
- Generate legacy compatibility pages and reject stale pages in `--check` mode.

`AGENTS.md` will require every human-readable documentation change to update both language counterparts in the same change and to run the synchronization and validation commands. GitHub Actions will run the same checks for every Markdown, shared asset, documentation script, or workflow change.

## Asset cleanup

Shared images live under `docs/assets/`. Derived software-interface crops live under `docs/assets/software-interface-manual/`. The asset builder reads the shared full screenshots directly and no longer commits duplicate full screenshots or unreferenced re-encoded copies.

Only files proven redundant by SHA-256 comparison and reference scanning are deleted. Every crop referenced by a document remains.

## Release mirror repair

`gitee_release_sync.py verify` must confirm:

- Identical latest-release tags on GitHub and Gitee.
- Identical asset-name sets.
- Identical sizes for every same-name asset.
- Anonymous Gitee asset URLs can establish a response and return data.
- Matching `main` and historical tag references on GitHub and Gitee.

The formal synchronization command makes the latest release asset set exact by default. It removes extra assets only from the current latest Gitee release and never deletes historical Gitee releases. Anonymous verification runs again after synchronization, and any mismatch returns a nonzero exit code.

After code validation, this work will repair the live `v0.3.51` release by uploading the missing `CH343SER.EXE`, replacing the incorrect Linux package and `latest.json`, and verifying all eight assets individually.

## Testing and completion criteria

- Bilingual trees, section IDs, compatibility pages, and local-link checks pass.
- Python unit tests cover tree comparison, compatibility-page generation, and release-difference detection.
- PowerShell syntax checks pass.
- `git diff --check` passes.
- GitHub and Gitee have matching `main`, tags, latest-release tags, asset names, and asset sizes.
- Every latest Gitee release asset is anonymously readable.
- The final worktree is clean and the relevant commits are pushed to both platforms.

## Non-goals

- Do not backfill release assets from before the Gitee mirror was enabled.
- Do not delete previously synchronized Gitee releases.
- Do not modify private AutoClipboard or firmware source code.
- Do not merge distinct user guides, interface manuals, maintainer documentation, or Skill protocols merely to reduce file count.
