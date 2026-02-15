#!/bin/bash
# Hyprland - apply theme file + reload

# Prefer theme.conf; fallback to theme/colors.conf, then colors.conf
src="$CURRENT_LINK/.config/hypr/theme.conf"
[[ -f "$src" ]] || src="$CURRENT_LINK/.config/hypr/theme/colors.conf"
[[ -f "$src" ]] || src="$CURRENT_LINK/.config/hypr/colors.conf"
[[ -f "$src" ]] || exit 0

dst="$HOME/.config/hypr/theme.conf"
mkdir -p "$(dirname "$dst")"
ln -sf "$src" "$dst"

pgrep -x Hyprland &>/dev/null && hyprctl reload >/dev/null 2>&1 || true
exit 0
