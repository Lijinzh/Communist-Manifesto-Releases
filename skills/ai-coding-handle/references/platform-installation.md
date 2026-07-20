# Platform installation

The bootstrap scripts always read metadata from:

`https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest/download/latest.json`

They accept only HTTPS assets below `github.com/Lijinzh/Communist-Manifesto-Releases/releases/.../download/...`, then verify the declared byte size and SHA-256 before installation. An explicitly authorized install or hook-configuration bootstrap may access this metadata and its selected installer asset over the network. A local metadata file is accepted only together with dry-run and is intended for offline validation; generic-agent offline dry-run continues to validate the asset without probing or modifying an installed application.

Before a real installation, upgrade, or Hook configuration, explain the selected platform package and obtain one explicit software confirmation. This confirmation covers the software/Hook transaction only, never firmware flashing.

Bootstrap result files use stable statuses: `verified` for a validated dry-run, `ready` after native hook installation and doctor, `configuration_required` when a generic agent still needs a verified lifecycle hook or Codex still needs user Hook approval, and `failed` for rejected or incomplete operations. `configuration_required` deliberately uses `success: false` while the bootstrap process may still exit zero so the calling Agent can continue configuration without mistaking the bridge for ready.

After a real install or configuration attempt, read the result JSON and retain its absolute `executable`. All later Maintenance and Agent Bridge commands must invoke that exact path; do not assume `auto-clipboard` is on `PATH`. A dry-run `verified` result may omit the executable because it did not install anything.

## Windows

Run `scripts/bootstrap-autoclipboard.ps1`. It selects `app.windows`, requires an `.exe`, and runs the Inno Setup installer with silent switches. Parameters are `-DryRun`, `-MetadataFile`, `-Agent auto|codex|claude|generic`, and `-ResultFile`.

## Linux

Run `scripts/bootstrap-autoclipboard.sh`. It selects `app.linux`, requires a `.deb`, and installs with `apt-get`/`apt` when available or `dpkg` as fallback. Flags are `--dry-run`, `--metadata-file`, `--agent auto|codex|claude|generic`, and `--result-file`.

## macOS

The POSIX bootstrap selects `app.macos`, requires a `.dmg`, and mounts it with `hdiutil`. It first copies `AutoClipboard.app` to a unique staging bundle beside the target in `~/Applications` and verifies the staged executable before touching the target. If a target already exists, bootstrap renames it to a unique backup and renames staging to the target. The backup remains until executable discovery, version validation, and Agent Bridge configuration all complete; only then is it removed. Any failure in that transaction removes the new target, restores the backup, and cleans staging, so `ditto` never merges new files into an existing bundle.

Before deciding whether to download, both scripts read the selected platform asset version from latest metadata and compare it with doctor `app_version` using validated SemVer syntax; a leading `v` is accepted. They install or upgrade only when the installed version is older. Equal or newer installations skip the download. Missing or malformed metadata and version values fail closed instead of guessing or silently keeping a stale installation. The first doctor is then a core preflight: `hook_executable_available`, `platform_poll_supported`, and `state_directory_writable` must all pass, while missing or stale Hook checks may fail because native install is expected to repair them. Codex and Claude then use native install; an empty `changes` result means no native Agent was detected and cannot become `ready`.

The final doctor is strict. The only non-fatal exception is a Codex result whose core and Hook configuration checks pass, `hook_trust_probe_available`, `hook_trust_metadata_complete`, and `hook_runtime_enabled` are true, and whose sole failure is `hook_trust_granted`. Bootstrap then returns `configuration_required` and asks the user to approve the AutoClipboard Hooks inside Codex before rerunning doctor. Every other final doctor failure remains fatal.

Generic agents also require the core preflight, but never use native install. The bootstrap returns `configuration_required` so the calling Agent can configure the verified `emit` contract; missing native Hook configuration does not block that result.
