#!/usr/bin/env bash
set -euo pipefail

action="check"
action_seen=0
requested_hci=""
hci_seen=0
sysfs_root="${AUTOCLIPBOARD_SYSFS_ROOT:-/sys}"
udev_rules_dir="${AUTOCLIPBOARD_UDEV_RULES_DIR:-/etc/udev/rules.d}"
rule_prefix="81-autoclipboard-bluetooth-power"
managed_header="# Managed by AutoClipboard ai-coding-handle skill."
temp_rule=""
previous_rule_backup=""

declare -a candidate_hcis=()
declare -a candidate_usb_paths=()
declare -a candidate_vendor_ids=()
declare -a candidate_product_ids=()

usage() {
  cat <<'EOF'
Usage: configure-linux-bluetooth-autosuspend.sh [--check] [--hci hciN]
       configure-linux-bluetooth-autosuspend.sh --apply [--hci hciN]
       configure-linux-bluetooth-autosuspend.sh --remove [--hci hciN]

--check   Inspect the btusb adapter and proposed persistent rule (default).
--apply   Set power/control to on and install an exact VID/PID udev rule.
--remove  Remove this script's exact rule and restore power/control to auto.
EOF
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

json_array() {
  local first=1
  local value
  printf '['
  for value in "$@"; do
    if [[ "$first" -eq 0 ]]; then
      printf ','
    fi
    first=0
    printf '"%s"' "$(json_escape "$value")"
  done
  printf ']'
}

emit_discovery_error() {
  local status="$1"
  local message="$2"
  local exit_code="$3"
  printf '{"schema_version":1,"success":false,"status":"%s","action":"%s","message":"%s","candidate_count":%d,"candidates":' \
    "$(json_escape "$status")" "$(json_escape "$action")" "$(json_escape "$message")" "${#candidate_hcis[@]}"
  json_array "${candidate_hcis[@]}"
  printf '}\n'
  exit "$exit_code"
}

read_value() {
  local path="$1"
  if [[ -r "$path" ]]; then
    LC_ALL=C tr -d '\r\n' < "$path"
  else
    printf 'unavailable'
  fi
}

rule_line() {
  printf '%s\n%s' \
    "ACTION==\"add\", SUBSYSTEM==\"usb\", ENV{DEVTYPE}==\"usb_device\", ATTR{idVendor}==\"$selected_vendor_id\", ATTR{idProduct}==\"$selected_product_id\", TEST==\"power/control\", ATTR{power/control}=\"on\"" \
    "ACTION==\"bind\", SUBSYSTEM==\"usb\", DRIVER==\"btusb\", ATTRS{idVendor}==\"$selected_vendor_id\", ATTRS{idProduct}==\"$selected_product_id\", TEST==\"../power/control\", ATTR{../power/control}=\"on\""
}

legacy_rule_line() {
  printf 'ACTION=="add|bind", SUBSYSTEM=="usb", ATTR{idVendor}=="%s", ATTR{idProduct}=="%s", TEST=="power/control", ATTR{power/control}="on"' \
    "$selected_vendor_id" "$selected_product_id"
}

render_rule_file() {
  printf '%s\n%s\n' "$managed_header" "$(rule_line)"
}

render_legacy_rule_file() {
  printf '%s\n%s\n' "$managed_header" "$(legacy_rule_line)"
}

load_selected_state() {
  selected_power_control="$(read_value "$selected_usb_path/power/control")"
  selected_autosuspend_delay="$(read_value "$selected_usb_path/power/autosuspend_delay_ms")"
  btusb_autosuspend="$(read_value "$sysfs_root/module/btusb/parameters/enable_autosuspend")"
  selected_rule_file="$udev_rules_dir/${rule_prefix}-${selected_vendor_id}-${selected_product_id}.rules"

  if [[ ! -e "$selected_rule_file" ]]; then
    selected_rule_state="missing"
  elif [[ ! -r "$selected_rule_file" ]]; then
    selected_rule_state="unreadable"
  elif cmp -s <(render_rule_file) "$selected_rule_file"; then
    selected_rule_state="managed"
  elif cmp -s <(render_legacy_rule_file) "$selected_rule_file"; then
    selected_rule_state="legacy_managed"
  else
    selected_rule_state="conflict"
  fi
}

emit_selected() {
  local success="$1"
  local status="$2"
  local recommended="$3"
  local message="$4"
  load_selected_state
  printf '{"schema_version":1,"success":%s,"status":"%s","action":"%s","message":"%s","candidate_count":%d,"hci":"%s","driver":"btusb","usb_device":"%s","vendor_id":"%s","product_id":"%s","power_control":"%s","autosuspend_delay_ms":"%s","btusb_autosuspend":"%s","persistent_rule":"%s","persistent_rule_state":"%s","recommended":%s,"udev_rule":"%s"}\n' \
    "$success" \
    "$(json_escape "$status")" \
    "$(json_escape "$action")" \
    "$(json_escape "$message")" \
    "${#candidate_hcis[@]}" \
    "$(json_escape "$selected_hci")" \
    "$(json_escape "$selected_usb_path")" \
    "$(json_escape "$selected_vendor_id")" \
    "$(json_escape "$selected_product_id")" \
    "$(json_escape "$selected_power_control")" \
    "$(json_escape "$selected_autosuspend_delay")" \
    "$(json_escape "$btusb_autosuspend")" \
    "$(json_escape "$selected_rule_file")" \
    "$(json_escape "$selected_rule_state")" \
    "$recommended" \
    "$(json_escape "$(rule_line)")"
}

fail_selected() {
  local status="$1"
  local message="$2"
  local exit_code="$3"
  emit_selected false "$status" false "$message"
  exit "$exit_code"
}

discover_hci() {
  local hci="$1"
  local class_path="$sysfs_root/class/bluetooth/$hci"
  local current=""
  local parent=""
  local driver_name=""
  local btusb_seen=0
  local vendor_id=""
  local product_id=""

  [[ -e "$class_path/device" ]] || return 0
  current="$(readlink -f -- "$class_path/device" 2>/dev/null || true)"
  [[ -n "$current" && "$current" == "$sysfs_root/devices/"* ]] || return 0

  while [[ "$current" == "$sysfs_root/devices/"* ]]; do
    if [[ -e "$current/driver" ]]; then
      driver_name="$(basename "$(readlink -f -- "$current/driver" 2>/dev/null || true)")"
      if [[ "$driver_name" == "btusb" ]]; then
        btusb_seen=1
      fi
    fi

    if [[ "$btusb_seen" -eq 1 && -r "$current/idVendor" && -r "$current/idProduct" && -e "$current/power/control" ]]; then
      vendor_id="$(read_value "$current/idVendor")"
      product_id="$(read_value "$current/idProduct")"
      if [[ "$vendor_id" =~ ^[0-9A-Fa-f]{4}$ && "$product_id" =~ ^[0-9A-Fa-f]{4}$ ]]; then
        candidate_hcis+=("$hci")
        candidate_usb_paths+=("$current")
        candidate_vendor_ids+=("${vendor_id,,}")
        candidate_product_ids+=("${product_id,,}")
      fi
      return 0
    fi

    parent="$(dirname -- "$current")"
    [[ "$parent" != "$current" ]] || break
    current="$parent"
  done
}

verify_selected_identity() {
  local hci_device=""
  local current=""
  local parent=""
  local driver_name=""
  local btusb_seen=0
  local current_vendor_id=""
  local current_product_id=""

  hci_device="$(readlink -f -- "$sysfs_root/class/bluetooth/$selected_hci/device" 2>/dev/null || true)"
  [[ -n "$hci_device" && "$hci_device" == "$selected_usb_path/"* ]] || return 1
  current="$hci_device"
  while [[ "$current" == "$selected_usb_path/"* ]]; do
    if [[ -e "$current/driver" ]]; then
      driver_name="$(basename "$(readlink -f -- "$current/driver" 2>/dev/null || true)")"
      if [[ "$driver_name" == "btusb" ]]; then
        btusb_seen=1
      fi
    fi
    parent="$(dirname -- "$current")"
    [[ "$parent" != "$current" ]] || break
    current="$parent"
  done
  [[ "$btusb_seen" -eq 1 ]] || return 1
  current_vendor_id="$(read_value "$selected_usb_path/idVendor")"
  current_product_id="$(read_value "$selected_usb_path/idProduct")"
  [[ "${current_vendor_id,,}" == "$selected_vendor_id" && "${current_product_id,,}" == "$selected_product_id" ]]
}

write_managed_rule() {
  if [[ ! -d "$udev_rules_dir" ]]; then
    install -d -m 0755 -- "$udev_rules_dir" || return 1
  fi
  temp_rule="$(mktemp "$udev_rules_dir/.${rule_prefix}.XXXXXX")" || return 1
  if ! render_rule_file > "$temp_rule"; then
    return 1
  fi
  chmod 0644 -- "$temp_rule" || return 1
  mv -fT -- "$temp_rule" "$selected_rule_file" || return 1
  temp_rule=""
}

backup_existing_rule() {
  previous_rule_backup="$(mktemp "$udev_rules_dir/.${rule_prefix}.backup.XXXXXX")" || return 1
  cp -- "$selected_rule_file" "$previous_rule_backup" || return 1
  chmod 0644 -- "$previous_rule_backup" || return 1
}

rollback_rule_change() {
  local previous_state="$1"
  if [[ "$previous_state" == "missing" ]]; then
    rm -f -- "$selected_rule_file"
  elif [[ -n "$previous_rule_backup" && -e "$previous_rule_backup" ]]; then
    mv -fT -- "$previous_rule_backup" "$selected_rule_file"
    previous_rule_backup=""
  fi
  reload_udev_rules || true
}

reload_udev_rules() {
  udevadm control --reload-rules >/dev/null
}

cleanup() {
  if [[ -n "$temp_rule" && -e "$temp_rule" ]]; then
    rm -f -- "$temp_rule"
  fi
  if [[ -n "$previous_rule_backup" && -e "$previous_rule_backup" ]]; then
    rm -f -- "$previous_rule_backup"
  fi
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      [[ "$action_seen" -eq 0 ]] || emit_discovery_error invalid_arguments "choose only one action" 64
      action="check"
      action_seen=1
      shift
      ;;
    --apply)
      [[ "$action_seen" -eq 0 ]] || emit_discovery_error invalid_arguments "choose only one action" 64
      action="apply"
      action_seen=1
      shift
      ;;
    --remove)
      [[ "$action_seen" -eq 0 ]] || emit_discovery_error invalid_arguments "choose only one action" 64
      action="remove"
      action_seen=1
      shift
      ;;
    --hci)
      [[ "$hci_seen" -eq 0 ]] || emit_discovery_error invalid_arguments "--hci may be specified only once" 64
      [[ $# -ge 2 && -n "$2" ]] || emit_discovery_error invalid_arguments "--hci requires a value" 64
      requested_hci="$2"
      hci_seen=1
      shift 2
      ;;
    --hci=*)
      [[ "$hci_seen" -eq 0 ]] || emit_discovery_error invalid_arguments "--hci may be specified only once" 64
      requested_hci="${1#*=}"
      hci_seen=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      emit_discovery_error invalid_arguments "unknown argument: $1" 64
      ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  emit_discovery_error unsupported_platform "this workflow supports Linux only" 69
fi
if [[ "$hci_seen" -eq 1 && -z "$requested_hci" ]]; then
  emit_discovery_error invalid_arguments "--hci requires a non-empty hciN value" 64
fi
if [[ -n "$requested_hci" && ! "$requested_hci" =~ ^hci[0-9]+$ ]]; then
  emit_discovery_error invalid_arguments "--hci must match hciN" 64
fi

if [[ -n "$requested_hci" ]]; then
  discover_hci "$requested_hci"
else
  shopt -s nullglob
  for class_path in "$sysfs_root"/class/bluetooth/hci*; do
    hci="$(basename -- "$class_path")"
    [[ "$hci" =~ ^hci[0-9]+$ ]] || continue
    discover_hci "$hci"
  done
fi

if [[ "${#candidate_hcis[@]}" -eq 0 ]]; then
  emit_discovery_error device_not_found "no matching btusb Bluetooth controller was found" 2
fi
if [[ "${#candidate_hcis[@]}" -gt 1 ]]; then
  emit_discovery_error ambiguous_device "multiple btusb Bluetooth controllers were found; rerun with an explicitly identified --hci" 3
fi

selected_hci="${candidate_hcis[0]}"
selected_usb_path="${candidate_usb_paths[0]}"
selected_vendor_id="${candidate_vendor_ids[0]}"
selected_product_id="${candidate_product_ids[0]}"
load_selected_state

if [[ "$action" == "check" ]]; then
  if [[ "$selected_rule_state" == "conflict" || "$selected_rule_state" == "unreadable" ]]; then
    emit_selected false rule_conflict false "the exact rule path contains unmanaged or unreadable content; do not apply automatically"
    exit 6
  elif [[ "$selected_power_control" == "on" && "$selected_rule_state" == "managed" ]]; then
    emit_selected true configured false "the exact btusb adapter already uses persistent power/control=on"
  elif [[ "$selected_power_control" == "unavailable" ]]; then
    emit_selected false inspection_failed false "the adapter power policy could not be read; do not apply automatically"
    exit 5
  elif [[ "$btusb_autosuspend" == "Y" || "$btusb_autosuspend" == "1" ]]; then
    emit_selected true diagnosis_ready true "persistent power/control=on is recommended for this exact btusb adapter when idle stalls or reconnects occur"
  else
    emit_selected true diagnosis_ready false "btusb autosuspend is not enabled globally; continue diagnosis before changing power policy"
  fi
  exit 0
fi

if [[ "$EUID" -ne 0 ]]; then
  fail_selected privilege_required "rerun this exact action through pkexec only after explicit system-configuration authorization" 4
fi
if ! command -v udevadm >/dev/null 2>&1; then
  fail_selected dependency_missing "udevadm is required before changing persistent USB power policy" 5
fi
if [[ "$selected_rule_state" == "conflict" || "$selected_rule_state" == "unreadable" ]]; then
  fail_selected rule_conflict "the exact rule path already contains unmanaged or unreadable content; no changes were made" 6
fi
if ! verify_selected_identity; then
  fail_selected device_changed "the selected HCI no longer resolves to the verified btusb VID/PID; no changes were made" 10
fi
case "$selected_power_control" in
  on|auto) ;;
  *) fail_selected inspection_failed "the current adapter power policy is not readable or recognized; no changes were made" 5 ;;
esac

if [[ "$action" == "apply" ]]; then
  if [[ "$selected_power_control" == "on" && "$selected_rule_state" == "managed" ]]; then
    emit_selected true configured false "the exact btusb adapter already uses persistent power/control=on"
    exit 0
  fi
  if [[ "$btusb_autosuspend" != "Y" && "$btusb_autosuspend" != "1" ]]; then
    fail_selected not_recommended "btusb autosuspend is not enabled globally; no changes were made" 11
  fi
  previous_rule_state="$selected_rule_state"
  rule_changed=0
  if [[ "$selected_rule_state" == "legacy_managed" ]]; then
    if ! backup_existing_rule; then
      fail_selected apply_failed "could not back up the legacy managed rule; no changes were made" 7
    fi
  fi
  if [[ "$selected_rule_state" == "missing" || "$selected_rule_state" == "legacy_managed" ]]; then
    if ! write_managed_rule; then
      fail_selected apply_failed "could not install the persistent udev rule; no USB power setting was changed" 7
    fi
    rule_changed=1
  fi

  if ! reload_udev_rules; then
    if [[ "$rule_changed" -eq 1 ]]; then
      rollback_rule_change "$previous_rule_state"
    fi
    fail_selected apply_failed "could not reload udev rules; no live USB power setting was changed and the previous rule state was restored" 7
  fi
  if ! printf 'on\n' > "$selected_usb_path/power/control"; then
    if [[ "$rule_changed" -eq 1 ]]; then
      rollback_rule_change "$previous_rule_state"
    fi
    fail_selected apply_failed "could not set power/control=on; the previous rule state was restored" 7
  fi
  load_selected_state
  if [[ "$selected_power_control" != "on" || "$selected_rule_state" != "managed" ]]; then
    if [[ "$rule_changed" -eq 1 ]]; then
      rollback_rule_change "$previous_rule_state"
    fi
    fail_selected verification_failed "the live power setting or persistent managed rule failed post-apply verification" 8
  fi
  if [[ -n "$previous_rule_backup" && -e "$previous_rule_backup" ]]; then
    rm -f -- "$previous_rule_backup"
    previous_rule_backup=""
  fi
  emit_selected true configured false "persistent power/control=on is active for the exact btusb VID/PID"
  exit 0
fi

previous_power_control="$selected_power_control"
if ! printf 'auto\n' > "$selected_usb_path/power/control"; then
  fail_selected remove_failed "could not restore power/control=auto; the persistent rule was not removed" 9
fi
if [[ "$(read_value "$selected_usb_path/power/control")" != "auto" ]]; then
  printf '%s\n' "$previous_power_control" > "$selected_usb_path/power/control" 2>/dev/null || true
  fail_selected verification_failed "power/control did not remain auto; the persistent rule was not removed" 8
fi

if [[ "$selected_rule_state" == "managed" || "$selected_rule_state" == "legacy_managed" ]]; then
  if ! rm -- "$selected_rule_file"; then
    printf '%s\n' "$previous_power_control" > "$selected_usb_path/power/control" 2>/dev/null || true
    fail_selected remove_failed "could not remove the managed udev rule; the previous live power setting was restored" 9
  fi
  if ! reload_udev_rules; then
    rollback_rule_state="missing"
    if write_managed_rule && reload_udev_rules; then
      rollback_rule_state="managed"
    fi
    printf '%s\n' "$previous_power_control" > "$selected_usb_path/power/control" 2>/dev/null || true
    if [[ "$rollback_rule_state" == "managed" ]]; then
      fail_selected remove_failed "could not reload the removal; the managed rule was restored and the previous live setting was requested" 9
    fi
    fail_selected rollback_failed "could not reload the removal or fully restore the managed rule; inspect the returned live state before retrying" 12
  fi
fi

load_selected_state
if [[ "$selected_power_control" != "auto" || "$selected_rule_state" != "missing" ]]; then
  fail_selected verification_failed "the live power setting or managed-rule removal failed post-remove verification" 8
fi
emit_selected true removed false "the exact managed rule was removed and power/control=auto was restored"
