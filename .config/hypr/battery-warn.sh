#!/usr/bin/env bash
set -euo pipefail

# Notify once per discharge cycle at these thresholds
LOW=20
CRIT=10

# Pick first battery + AC adapter from sysfs
BAT="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1 || true)"
AC="$(ls -d /sys/class/power_supply/AC* /sys/class/power_supply/ADP* 2>/dev/null | head -n1 || true)"

# If no battery, do nothing
[[ -n "$BAT" ]] || exit 0

cap="$(cat "$BAT/capacity" 2>/dev/null || echo 0)"
status="$(cat "$BAT/status" 2>/dev/null || echo Unknown)"

# AC online detection
ac_online="0"
if [[ -n "$AC" && -f "$AC/online" ]]; then
  ac_online="$(cat "$AC/online" 2>/dev/null || echo 0)"
else
  # Fallback inference if AC device isn't exposed
  if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    ac_online="1"
  fi
fi

# State file: remembers whether we've already warned this discharge cycle
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/battery-warn"
STATE_FILE="$STATE_DIR/state"
mkdir -p "$STATE_DIR"

warned_low=0
warned_crit=0
if [[ -f "$STATE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$STATE_FILE" || true
fi

# Reset warnings when plugged in or charging/full
if [[ "$ac_online" == "1" || "$status" == "Charging" || "$status" == "Full" ]]; then
  warned_low=0
  warned_crit=0
  {
    echo "warned_low=0"
    echo "warned_crit=0"
  } > "$STATE_FILE"
  exit 0
fi

# Only warn while actually discharging
if [[ "$status" != "Discharging" ]]; then
  exit 0
fi

# Notify via swaync (notify-send)
if ! command -v notify-send >/dev/null 2>&1; then
  exit 0
fi

if (( cap <= CRIT )) && [[ "${warned_crit:-0}" -ne 1 ]]; then
  notify-send -u critical -a "Power" "Critical battery" "${cap}% remaining — plug in now"
  warned_crit=1
fi

if (( cap <= LOW )) && [[ "${warned_low:-0}" -ne 1 ]]; then
  notify-send -u normal -a "Power" "Low battery" "${cap}% remaining"
  warned_low=1
fi

{
  echo "warned_low=$warned_low"
  echo "warned_crit=$warned_crit"
} > "$STATE_FILE"

