#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-sys-expand"
SIGNAL_NUM=9

is_expanded() {
  [[ -f "$STATE_FILE" ]] && grep -qx "1" "$STATE_FILE"
}

set_expanded() {
  printf "1" > "$STATE_FILE"
}

set_compact() {
  printf "0" > "$STATE_FILE"
}

toggle() {
  if is_expanded; then
    set_compact
  else
    set_expanded
  fi
}

mem_used_gb() {
  awk '
    /^MemTotal:/     {t=$2}
    /^MemAvailable:/ {a=$2}
    END {
      used_kb = t - a
      used_gb = used_kb / 1024 / 1024
      printf "%.1f", used_gb
    }
  ' /proc/meminfo
}

cpu_usage_pct() {
  # delta-based CPU usage using /proc/stat, persisted between runs
  local prev="${XDG_RUNTIME_DIR:-/tmp}/waybar-cpu-prev"
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local idle_all=$((idle + iowait))
  local total=$((user + nice + system + idle_all + irq + softirq + steal))

  if [[ -f "$prev" ]]; then
    read -r ptotal pidle < "$prev" || true
    local dt=$((total - ptotal))
    local di=$((idle_all - pidle))
    if (( dt > 0 )); then
      echo $(( (100 * (dt - di)) / dt ))
    else
      echo 0
    fi
  else
    echo 0
  fi

  printf "%s %s\n" "$total" "$idle_all" > "$prev"
}

gpu_used_gb() {
  # NVIDIA VRAM used (MiB -> GiB)
  if command -v nvidia-smi >/dev/null 2>&1; then
    local mib
    mib="$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>/dev/null | head -n1 || true)"
    if [[ "$mib" =~ ^[0-9]+$ ]]; then
      awk -v mib="$mib" 'BEGIN { printf "%.1f", mib/1024 }'
      return
    fi
  fi
  echo "N/A"
}

print_json() {
  local mem cpu gpu text tooltip cls
  mem="$(mem_used_gb)"

  if is_expanded; then
    cpu="$(cpu_usage_pct)"
    gpu="$(gpu_used_gb)"
    text="󰍛 ${mem}G  󰘚 ${cpu}%  󰢮 ${gpu}G"
    tooltip="RAM used: ${mem} GiB\nCPU usage: ${cpu}%\nGPU used: ${gpu} GiB"
    cls="expanded"
  else
    text="󰍛 ${mem}G"
    tooltip="RAM used: ${mem} GiB (click to expand)"
    cls="compact"
  fi

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$cls"
}

if [[ "${1:-}" == "toggle" ]]; then
  toggle
  pkill -RTMIN+"$SIGNAL_NUM" waybar || true
  exit 0
fi

print_json
