#!/usr/bin/env bash
set -euo pipefail

ROFI="${ROFI:-rofi}"
PROMPT="${PROMPT:-Clipboard}"
CLEAR_LABEL="${CLEAR_LABEL:-🗑️ Clear clipboard}"

# Build menu:
# - first item: clear
# - then a separator line (optional)
# - then cliphist items
menu="$(
  {
    printf '%s\n' "$CLEAR_LABEL"
    printf '\n'
    cliphist list
  } | "$ROFI" -dmenu -i -p "$PROMPT"
)"

# User hit Escape / closed menu
[[ -z "${menu:-}" ]] && exit 0

if [[ "$menu" == "$CLEAR_LABEL" ]]; then
  cliphist wipe
  wl-copy --clear
  exit 0
fi

# Otherwise: decode selected line into clipboard
printf '%s' "$menu" | cliphist decode | wl-copy
