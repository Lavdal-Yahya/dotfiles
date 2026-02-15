#!/bin/bash
# GTK - link theme colors + ensure gtk.css imports it

for ver in "gtk-3.0" "gtk-4.0"; do
  mkdir -p "$HOME/.config/$ver"

  src="$CURRENT_LINK/.config/$ver/colors.css"
  if [[ -f "$src" ]]; then
    ln -sf "$src" "$HOME/.config/$ver/colors.css"
  fi

  css="$HOME/.config/$ver/gtk.css"
  if [[ -f "$css" ]]; then
    grep -q '@import "colors.css";' "$css" || sed -i '1i @import "colors.css";\n' "$css"
  fi
done

# refresh gtk apps (best-effort)
killall nautilus 2>/dev/null || true
command -v nwg-look &>/dev/null && nwg-look -a >/dev/null 2>&1 || true
exit 0
