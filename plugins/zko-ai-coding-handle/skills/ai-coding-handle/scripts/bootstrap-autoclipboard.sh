#!/usr/bin/env bash
set -euo pipefail

METADATA_URL="https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest/download/latest.json"
RELEASE_URL_RE='^https://github\.com/Lijinzh/Communist-Manifesto-Releases/releases/[^/]+/download/[^/?#]+$'
REQUIRED_AGENT_BRIDGE_VERSION=1

dry_run=0
metadata_file=""
agent="auto"
result_file=""
temp_root=""
mount_active=0
mount_point=""
app_target=""
app_staging=""
app_backup=""
app_target_replaced=0
probe_timeout_seconds="${AUTOCLIPBOARD_BOOTSTRAP_PROBE_TIMEOUT_SECONDS:-30}"

usage() {
  cat <<'EOF'
Usage: bootstrap-autoclipboard.sh [--dry-run] [--metadata-file PATH]
       [--agent auto|codex|claude|generic] [--result-file PATH]
EOF
}

json_escape() {
  printf '%s' "$1" | LC_ALL=C tr '[:cntrl:]' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g'
}

write_result() {
  local success="$1"
  local status="$2"
  local message="$3"
  local executable="${4:-}"
  [[ -n "$result_file" ]] || return 0
  mkdir -p "$(dirname "$result_file")"
  printf '{"schema_version":1,"success":%s,"status":"%s","agent":"%s","message":"%s","executable":"%s"}\n' \
    "$success" "$(json_escape "$status")" "$(json_escape "$agent")" "$(json_escape "$message")" "$(json_escape "$executable")" \
    > "$result_file"
}

fail() {
  local message="$1"
  write_result false failed "$message"
  printf 'Error: %s\n' "$message" >&2
  exit 1
}

need_value() {
  [[ $# -ge 2 && -n "$2" ]] || fail "$1 requires a value"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --metadata-file) need_value "$1" "${2:-}"; metadata_file="$2"; shift 2 ;;
    --metadata-file=*) metadata_file="${1#*=}"; shift ;;
    --agent) need_value "$1" "${2:-}"; agent="$2"; shift 2 ;;
    --agent=*) agent="${1#*=}"; shift ;;
    --result-file) need_value "$1" "${2:-}"; result_file="$2"; shift 2 ;;
    --result-file=*) result_file="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

case "$agent" in
  auto|codex|claude|generic) ;;
  *) fail "--agent must be auto, codex, claude, or generic" ;;
esac
if [[ -n "$metadata_file" && "$dry_run" -ne 1 ]]; then
  fail "--metadata-file is only allowed with --dry-run"
fi
if [[ -n "$metadata_file" && ! -f "$metadata_file" ]]; then
  fail "metadata file does not exist: $metadata_file"
fi
if [[ ! "$probe_timeout_seconds" =~ ^[1-9][0-9]*$ ]]; then
  fail "AUTOCLIPBOARD_BOOTSTRAP_PROBE_TIMEOUT_SECONDS must be a positive integer"
fi

temp_root="$(mktemp -d "${TMPDIR:-/tmp}/autoclipboard-bootstrap.XXXXXX")"
rollback_app_install() {
  if [[ -n "$app_backup" && -e "$app_backup" && -n "$app_target" ]]; then
    [[ ! -e "$app_target" ]] || rm -rf "$app_target"
    mv "$app_backup" "$app_target" >/dev/null 2>&1 || true
  elif [[ "$app_target_replaced" -eq 1 && -n "$app_target" && -e "$app_target" ]]; then
    rm -rf "$app_target"
  fi
  [[ -z "$app_staging" ]] || rm -rf "$app_staging"
  app_staging=""
  app_backup=""
  app_target_replaced=0
}

cleanup() {
  if [[ "$mount_active" -eq 1 && -n "$mount_point" ]] && command -v hdiutil >/dev/null 2>&1; then
    hdiutil detach "$mount_point" >/dev/null 2>&1 || true
  fi
  rollback_app_install
  rm -rf "$temp_root"
}
trap cleanup EXIT

json_get() {
  local file="$1"
  local path="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -er ".${path}" "$file"
    return
  fi
  if command -v plutil >/dev/null 2>&1; then
    local plutil_path="${path//\[/.}"
    plutil_path="${plutil_path//\]/}"
    plutil -extract "$plutil_path" raw -o - "$file"
    return
  fi
  LC_ALL=C awk -v wanted="$path" '
function skip_ws(    c) {
  while (pos <= data_length) {
    c = substr(data, pos, 1)
    if (c !~ /[[:space:]]/) return
    pos++
  }
}
function parse_string(    output, c, escaped) {
  output = ""
  pos++
  while (pos <= data_length) {
    c = substr(data, pos, 1)
    pos++
    if (c == "\"") return output
    if (c == "\\") {
      escaped = substr(data, pos, 1)
      pos++
      if (escaped == "n") output = output "\n"
      else if (escaped == "r") output = output "\r"
      else if (escaped == "t") output = output "\t"
      else if (escaped == "b") output = output sprintf("%c", 8)
      else if (escaped == "f") output = output sprintf("%c", 12)
      else if (escaped == "u") {
        output = output "\\u" substr(data, pos, 4)
        pos += 4
      } else output = output escaped
    } else output = output c
  }
  parse_error = 1
  return output
}
function emit(path_name, value) {
  if (path_name == wanted) {
    print value
    found = 1
  }
}
function parse_literal(    start, c) {
  start = pos
  while (pos <= data_length) {
    c = substr(data, pos, 1)
    if (c == "," || c == "}" || c == "]" || c ~ /[[:space:]]/) break
    pos++
  }
  return substr(data, start, pos - start)
}
function parse_array(path_name,    array_index, c) {
  pos++
  skip_ws()
  if (substr(data, pos, 1) == "]") { pos++; return }
  array_index = 0
  while (pos <= data_length) {
    parse_value(path_name "[" array_index "]")
    array_index++
    skip_ws()
    c = substr(data, pos, 1)
    if (c == "]") { pos++; return }
    if (c != ",") { parse_error = 1; return }
    pos++
    skip_ws()
  }
  parse_error = 1
}
function parse_object(path_name,    key, child, c) {
  pos++
  skip_ws()
  if (substr(data, pos, 1) == "}") { pos++; return }
  while (pos <= data_length) {
    if (substr(data, pos, 1) != "\"") { parse_error = 1; return }
    key = parse_string()
    skip_ws()
    if (substr(data, pos, 1) != ":") { parse_error = 1; return }
    pos++
    child = path_name == "" ? key : path_name "." key
    parse_value(child)
    skip_ws()
    c = substr(data, pos, 1)
    if (c == "}") { pos++; return }
    if (c != ",") { parse_error = 1; return }
    pos++
    skip_ws()
  }
  parse_error = 1
}
function parse_value(path_name,    c, value) {
  skip_ws()
  c = substr(data, pos, 1)
  if (c == "{") parse_object(path_name)
  else if (c == "[") parse_array(path_name)
  else if (c == "\"") { value = parse_string(); emit(path_name, value) }
  else { value = parse_literal(); emit(path_name, value) }
}
{
  if (NR > 1) data = data "\n"
  data = data $0
}
END {
  data_length = length(data)
  pos = 1
  parse_value("")
  if (parse_error || !found) exit 1
}
' "$file"
}

parse_semver() {
  local raw="$1"
  local version="$raw"
  local core=""
  local prerelease=""
  local build=""
  local identifier=""
  local identifiers=()
  [[ "$version" == v* ]] && version="${version#v}"
  [[ -n "$version" ]] || return 1
  if [[ "$version" == *+* ]]; then
    build="${version#*+}"
    version="${version%%+*}"
    [[ "$build" != *+* && "$build" =~ ^[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*$ ]] || return 1
  fi
  core="$version"
  if [[ "$version" == *-* ]]; then
    prerelease="${version#*-}"
    core="${version%%-*}"
    [[ "$prerelease" =~ ^[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*$ ]] || return 1
    IFS='.' read -r -a identifiers <<< "$prerelease"
    for identifier in "${identifiers[@]}"; do
      if [[ "$identifier" =~ ^[0-9]+$ && ${#identifier} -gt 1 && "$identifier" == 0* ]]; then
        return 1
      fi
    done
  fi
  [[ "$core" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || return 1
  semver_major="${BASH_REMATCH[1]}"
  semver_minor="${BASH_REMATCH[2]}"
  semver_patch="${BASH_REMATCH[3]}"
  semver_prerelease="$prerelease"
}

compare_decimal() {
  local left="$1"
  local right="$2"
  local LC_ALL=C
  if (( ${#left} < ${#right} )); then printf '%s\n' -1; return; fi
  if (( ${#left} > ${#right} )); then printf '%s\n' 1; return; fi
  if [[ "$left" == "$right" ]]; then printf '%s\n' 0; return; fi
  if [[ "$left" < "$right" ]]; then printf '%s\n' -1; else printf '%s\n' 1; fi
}

semver_compare() {
  local installed="$1"
  local release="$2"
  local installed_major installed_minor installed_patch installed_prerelease
  local release_major release_minor release_patch release_prerelease
  local comparison index installed_identifier release_identifier
  local installed_identifiers=()
  local release_identifiers=()
  local LC_ALL=C
  parse_semver "$installed" || return 2
  installed_major="$semver_major"
  installed_minor="$semver_minor"
  installed_patch="$semver_patch"
  installed_prerelease="$semver_prerelease"
  parse_semver "$release" || return 3
  release_major="$semver_major"
  release_minor="$semver_minor"
  release_patch="$semver_patch"
  release_prerelease="$semver_prerelease"
  for comparison in \
    "$(compare_decimal "$installed_major" "$release_major")" \
    "$(compare_decimal "$installed_minor" "$release_minor")" \
    "$(compare_decimal "$installed_patch" "$release_patch")"; do
    if [[ "$comparison" != 0 ]]; then printf '%s\n' "$comparison"; return 0; fi
  done
  if [[ -z "$installed_prerelease" && -z "$release_prerelease" ]]; then printf '%s\n' 0; return 0; fi
  if [[ -z "$installed_prerelease" ]]; then printf '%s\n' 1; return 0; fi
  if [[ -z "$release_prerelease" ]]; then printf '%s\n' -1; return 0; fi
  IFS='.' read -r -a installed_identifiers <<< "$installed_prerelease"
  IFS='.' read -r -a release_identifiers <<< "$release_prerelease"
  index=0
  while (( index < ${#installed_identifiers[@]} && index < ${#release_identifiers[@]} )); do
    installed_identifier="${installed_identifiers[$index]}"
    release_identifier="${release_identifiers[$index]}"
    if [[ "$installed_identifier" == "$release_identifier" ]]; then
      index=$((index + 1))
      continue
    fi
    if [[ "$installed_identifier" =~ ^[0-9]+$ ]]; then
      if [[ "$release_identifier" =~ ^[0-9]+$ ]]; then
        compare_decimal "$installed_identifier" "$release_identifier"
      else
        printf '%s\n' -1
      fi
      return 0
    fi
    if [[ "$release_identifier" =~ ^[0-9]+$ ]]; then printf '%s\n' 1; return 0; fi
    if [[ "$installed_identifier" < "$release_identifier" ]]; then printf '%s\n' -1; else printf '%s\n' 1; fi
    return 0
  done
  if (( ${#installed_identifiers[@]} < ${#release_identifiers[@]} )); then
    printf '%s\n' -1
  elif (( ${#installed_identifiers[@]} > ${#release_identifiers[@]} )); then
    printf '%s\n' 1
  else
    printf '%s\n' 0
  fi
}

download_file() {
  local url="$1"
  local output="$2"
  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --silent --show-error "$url" --output "$output"
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -q -O "$output" "$url"
    return
  fi
  fail "curl or wget is required to download release files"
}

locate_executable() {
  local candidate=""
  if command -v auto-clipboard >/dev/null 2>&1; then
    command -v auto-clipboard
    return 0
  fi
  for candidate in \
    /usr/local/bin/auto-clipboard \
    /usr/bin/auto-clipboard \
    "$HOME/Applications/AutoClipboard.app/Contents/MacOS/AutoClipboard" \
    /Applications/AutoClipboard.app/Contents/MacOS/AutoClipboard; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

bridge_agent="$agent"
[[ "$bridge_agent" == "generic" ]] && bridge_agent="auto"

run_doctor() {
  local executable="$1"
  local output="$2"
  local doctor_pid=0
  local elapsed=0
  local terminate_elapsed=0
  local exit_code=0
  rm -f "$output"
  "$executable" --agent-bridge doctor --agent "$bridge_agent" --result-file "$output" --quiet &
  doctor_pid=$!
  while kill -0 "$doctor_pid" >/dev/null 2>&1; do
    if (( elapsed >= probe_timeout_seconds )); then
      kill "$doctor_pid" >/dev/null 2>&1 || true
      while kill -0 "$doctor_pid" >/dev/null 2>&1 && (( terminate_elapsed < 2 )); do
        sleep 1
        terminate_elapsed=$((terminate_elapsed + 1))
      done
      if kill -0 "$doctor_pid" >/dev/null 2>&1; then
        kill -KILL "$doctor_pid" >/dev/null 2>&1 || true
      fi
      wait "$doctor_pid" >/dev/null 2>&1 || true
      return 124
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  if wait "$doctor_pid"; then exit_code=0; else exit_code=$?; fi
  return "$exit_code"
}

doctor_core_check_ok() {
  local file="$1"
  local wanted_code="$2"
  local index=0
  local check_code=""
  while check_code="$(json_get "$file" "checks[$index].code" 2>/dev/null)"; do
    if [[ "$check_code" == "$wanted_code" ]]; then
      [[ "$(json_get "$file" "checks[$index].ok" 2>/dev/null || printf 'false')" == "true" ]]
      return
    fi
    index=$((index + 1))
  done
  return 1
}

require_core_preflight() {
  local file="$1"
  local check_code=""
  for check_code in hook_executable_available platform_poll_supported state_directory_writable; do
    doctor_core_check_ok "$file" "$check_code" \
      || fail "doctor core preflight failed: $check_code"
  done
}

doctor_only_requires_codex_trust() {
  local file="$1"
  local check_code=""
  local check_ok=""
  local index=0
  local trust_blocked=0
  for check_code in \
    hook_executable_available platform_poll_supported state_directory_writable \
    hook_config_readable hook_events_complete hook_source_command_absent hook_executable_matches \
    hook_trust_probe_available hook_trust_metadata_complete hook_runtime_enabled \
    hook_trust_status_known; do
    doctor_core_check_ok "$file" "$check_code" || return 1
  done
  if json_get "$file" "errors[0].code" >/dev/null 2>&1; then
    return 1
  fi
  while check_code="$(json_get "$file" "checks[$index].code" 2>/dev/null)"; do
    check_ok="$(json_get "$file" "checks[$index].ok" 2>/dev/null || printf 'false')"
    if [[ "$check_ok" != "true" ]]; then
      [[ "$check_code" == "hook_trust_granted" ]] || return 1
      trust_blocked=1
    fi
    index=$((index + 1))
  done
  [[ "$trust_blocked" -eq 1 ]]
}

configure_existing() {
  local executable="$1"
  local release_version="$2"
  local first_result="$temp_root/doctor-before.json"
  run_doctor "$executable" "$first_result" || true
  if [[ ! -f "$first_result" ]]; then
    printf 'Existing executable does not support Agent Bridge v1; upgrade required.\n'
    return 2
  fi
  local bridge_version
  bridge_version="$(json_get "$first_result" agent_bridge_version 2>/dev/null || printf '0')"
  if [[ ! "$bridge_version" =~ ^[0-9]+$ ]] || (( bridge_version < REQUIRED_AGENT_BRIDGE_VERSION )); then
    printf 'Existing executable has Agent Bridge version %s; upgrade required.\n' "$bridge_version"
    return 2
  fi
  local installed_version
  local version_comparison
  installed_version="$(json_get "$first_result" app_version 2>/dev/null)" \
    || fail "doctor result is missing installed app version"
  if ! parse_semver "$installed_version"; then
    fail "installed app version is not valid SemVer: $installed_version"
  fi
  version_comparison="$(semver_compare "$installed_version" "$release_version")" \
    || fail "failed to compare installed and release app versions"
  if [[ "$version_comparison" == -1 ]]; then
    printf 'Installed app_version=%s is older than release %s; upgrade required.\n' \
      "$installed_version" "$release_version"
    return 2
  fi
  printf 'Skipping download: installed app_version=%s is not older than release %s\n' \
    "$installed_version" "$release_version"
  require_core_preflight "$first_result"
  if [[ "$agent" == "generic" ]]; then
    printf 'Generic agent selected: native install is not used; configure verified lifecycle hooks with emit.\n'
    write_result false configuration_required "Configure a verified lifecycle hook to call emit, then run doctor again" "$executable"
    return 0
  fi
  local install_result="$temp_root/install.json"
  local install_args=(--agent-bridge install --agent "$agent")
  [[ "$dry_run" -eq 1 ]] && install_args+=(--dry-run)
  install_args+=(--result-file "$install_result" --quiet)
  if ! "$executable" "${install_args[@]}"; then
    fail "native install failed"
  fi
  [[ "$(json_get "$install_result" success 2>/dev/null || printf 'false')" == "true" ]] \
    || fail "native install returned an unsuccessful result"
  json_get "$install_result" "changes[0].code" >/dev/null 2>&1 \
    || fail "native install did not detect any native agent to configure"
  local final_result="$temp_root/doctor-after.json"
  local final_exit=0
  run_doctor "$executable" "$final_result" || final_exit=$?
  if [[ "$final_exit" -ne 0 ]] \
    || [[ "$(json_get "$final_result" success 2>/dev/null || printf 'false')" != "true" ]]; then
    if [[ -f "$final_result" ]] && doctor_only_requires_codex_trust "$final_result"; then
      printf 'Codex Hook approval is required before Agent Bridge can become ready.\n'
      write_result false configuration_required \
        "Review and approve the AutoClipboard Hooks in Codex, then rerun doctor" "$executable"
      return 0
    fi
    fail "doctor failed after hook configuration"
  fi
  write_result true ready "AutoClipboard Agent Bridge is ready" "$executable"
  return 0
}

existing=""
offline_asset_check=0
if [[ "$dry_run" -eq 1 && "$agent" == "generic" && -n "$metadata_file" ]]; then
  offline_asset_check=1
fi

metadata_path="$metadata_file"
if [[ -z "$metadata_path" ]]; then
  metadata_path="$temp_root/latest.json"
  download_file "$METADATA_URL" "$metadata_path" \
    || fail "failed to download release metadata"
fi

platform_name=""
extension=""
case "$(uname -s)" in
  Linux) platform_name="linux"; extension=".deb" ;;
  Darwin) platform_name="macos"; extension=".dmg" ;;
  *) fail "unsupported operating system: $(uname -s)" ;;
esac

release_version="$(json_get "$metadata_path" "app.${platform_name}.version")" \
  || fail "release metadata is missing app.${platform_name}.version"
package="$(json_get "$metadata_path" "app.${platform_name}.package")" \
  || fail "release metadata is missing app.${platform_name}.package"
sha256="$(json_get "$metadata_path" "app.${platform_name}.sha256")" \
  || fail "release metadata is missing app.${platform_name}.sha256"
size="$(json_get "$metadata_path" "app.${platform_name}.size")" \
  || fail "release metadata is missing app.${platform_name}.size"
download_url="$(json_get "$metadata_path" "app.${platform_name}.download_url")" \
  || fail "release metadata is missing app.${platform_name}.download_url"

if ! parse_semver "$release_version"; then
  fail "release app version is not valid SemVer: $release_version"
fi

case "$package" in
  ""|.|..|*/*|*\\*) fail "package must be a plain basename" ;;
esac
[[ "$package" == *"$extension" ]] || fail "selected package must end in $extension"
[[ "$sha256" =~ ^[0-9a-fA-F]{64}$ ]] || fail "release metadata contains an invalid SHA-256"
[[ "$size" =~ ^[0-9]+$ ]] || fail "release metadata contains an invalid size"
[[ "$download_url" =~ $RELEASE_URL_RE ]] || fail "Release URL is not an approved GitHub Release asset"
encoded_download_name="${download_url##*/}"
decoded_download_name="$(
  printf '%s' "$encoded_download_name" | LC_ALL=C awk '
function hex_value(c) {
  c = toupper(c)
  return index("0123456789ABCDEF", c) - 1
}
{
  output = ""
  for (position = 1; position <= length($0); position++) {
    character = substr($0, position, 1)
    if (character == "%") {
      if (position + 2 > length($0)) exit 1
      high = hex_value(substr($0, position + 1, 1))
      low = hex_value(substr($0, position + 2, 1))
      if (high < 0 || low < 0) exit 1
      output = output sprintf("%c", high * 16 + low)
      position += 2
    } else output = output character
  }
  print output
}'
)" || fail "download URL basename is not valid percent encoding"
[[ "$decoded_download_name" == "$package" ]] || fail "package does not match download URL basename"

if [[ "$offline_asset_check" -ne 1 ]]; then
  if existing="$(locate_executable)"; then
    if configure_existing "$existing" "$release_version"; then
      exit 0
    fi
  fi
fi

asset_path=""
if [[ -n "$metadata_file" && -f "$(dirname "$metadata_file")/$package" ]]; then
  asset_path="$(dirname "$metadata_file")/$package"
else
  asset_path="$temp_root/$package"
  download_file "$download_url" "$asset_path" \
    || fail "failed to download installer"
fi

actual_size="$(wc -c < "$asset_path" | tr -d '[:space:]')"
if command -v sha256sum >/dev/null 2>&1; then
  actual_sha="$(sha256sum "$asset_path" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual_sha="$(shasum -a 256 "$asset_path" | awk '{print $1}')"
else
  fail "sha256sum or shasum is required to verify the installer"
fi
[[ "$actual_size" == "$size" ]] || fail "installer size mismatch: expected $size, got $actual_size"
actual_sha_lower="$(printf '%s' "$actual_sha" | tr '[:upper:]' '[:lower:]')"
sha256_lower="$(printf '%s' "$sha256" | tr '[:upper:]' '[:lower:]')"
[[ "$actual_sha_lower" == "$sha256_lower" ]] || fail "installer SHA-256 mismatch"
printf 'Selected asset: %s\n' "$package"

if [[ "$dry_run" -eq 1 ]]; then
  if [[ "$platform_name" == "linux" ]]; then
    printf 'Dry run: install with apt (preferred) or dpkg: %s\n' "$asset_path"
  else
    printf 'Dry run: mount with hdiutil and copy AutoClipboard.app to %s/Applications\n' "$HOME"
  fi
  write_result true verified "Dry run completed; installer verified"
  exit 0
fi

if [[ "$platform_name" == "linux" ]]; then
  prefix=()
  [[ "$(id -u)" -eq 0 ]] || prefix=(sudo)
  if command -v apt-get >/dev/null 2>&1; then
    "${prefix[@]}" apt-get install -y "$asset_path"
  elif command -v apt >/dev/null 2>&1; then
    "${prefix[@]}" apt install -y "$asset_path"
  elif command -v dpkg >/dev/null 2>&1; then
    "${prefix[@]}" dpkg -i "$asset_path"
  else
    fail "apt or dpkg is required to install the Debian package"
  fi
else
  mount_point="$temp_root/mount"
  mkdir -p "$mount_point" "$HOME/Applications"
  hdiutil attach -nobrowse -readonly -mountpoint "$mount_point" "$asset_path" >/dev/null
  mount_active=1
  app_source="$(find "$mount_point" -maxdepth 2 -name AutoClipboard.app -print -quit)"
  [[ -n "$app_source" ]] || fail "AutoClipboard.app was not found in the dmg"
  app_target="$HOME/Applications/AutoClipboard.app"
  app_staging="$(mktemp -d "$HOME/Applications/.AutoClipboard.app.staging.XXXXXX")"
  app_backup="$(mktemp -d "$HOME/Applications/.AutoClipboard.app.backup.XXXXXX")"
  rmdir "$app_backup"
  ditto "$app_source" "$app_staging"
  staged_executable="$app_staging/Contents/MacOS/AutoClipboard"
  [[ -f "$staged_executable" && -x "$staged_executable" ]] \
    || fail "staged AutoClipboard executable is missing or not executable"
  if [[ -e "$app_target" ]]; then
    if ! mv "$app_target" "$app_backup"; then
      fail "failed to move the existing AutoClipboard.app to backup"
    fi
  else
    app_backup=""
  fi
  if ! mv "$app_staging" "$app_target"; then
    rm -rf "$app_staging"
    app_staging=""
    if [[ -n "$app_backup" && -e "$app_backup" ]]; then
      mv "$app_backup" "$app_target" \
        || fail "failed to install AutoClipboard.app and rollback the previous bundle"
      app_backup=""
    fi
    fail "failed to install AutoClipboard.app; the previous bundle was restored"
  fi
  app_staging=""
  app_target_replaced=1
  hdiutil detach "$mount_point" >/dev/null
  mount_active=0
fi

installed="$(locate_executable)" || fail "AutoClipboard installed, but its executable was not found"
configure_existing "$installed" "$release_version" || fail "installed Agent Bridge or app version is below the release requirement"
if [[ "$platform_name" == "macos" ]]; then
  if [[ -n "$app_backup" ]]; then
    rm -rf "$app_backup"
    app_backup=""
  fi
  app_target_replaced=0
fi
