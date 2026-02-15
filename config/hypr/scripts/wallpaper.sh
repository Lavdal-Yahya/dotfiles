#!/bin/bash
# Minimal wallpaper script for Hyprland autostart
# Delegates to odyssey/current and cycle-wallpaper where appropriate

set -e

rofiDir="$HOME/.config/rofi/scripts"
wallpaper_path="$HOME/.config/odyssey/current/wallpaper"

case "${1:-init}" in
  init)
    swww query &>/dev/null || swww-daemon --format xrgb &
    sleep 0.3
    if [[ -e "$wallpaper_path" ]]; then
      swww img "$(readlink -f "$wallpaper_path")" 2>/dev/null || swww img "$wallpaper_path"
    fi
    ;;
  random|next|prev)
    [[ -x "$rofiDir/cycle-wallpaper" ]] && exec "$rofiDir/cycle-wallpaper" "$1"
    [[ -e "$wallpaper_path" ]] && swww img "$(readlink -f "$wallpaper_path")" 2>/dev/null || true
    ;;
  *)
    echo "Usage: $0 {init|random|next|prev}" >&2
    exit 1
    ;;
esac
