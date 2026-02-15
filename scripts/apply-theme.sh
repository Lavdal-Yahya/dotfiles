#!/bin/bash
# Apply Odyssey theme with optional WALLPAPER_DIR override
# Usage: ./scripts/apply-theme.sh [theme-name]

export WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Wallpapers}"
odyssey switch "$@"
