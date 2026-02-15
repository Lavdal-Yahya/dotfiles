#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Symlinks that still hardcode /home:"
if rg -n "/home/" config home >/dev/null 2>&1; then
  rg -n "/home/" config home
  exit 1
else
  echo "OK"
fi

echo "Wallpaper symlinks:"
find config/odyssey/themes -maxdepth 2 -name wallpaper -print -exec readlink {} \; 2>/dev/null || true

echo "Done"
