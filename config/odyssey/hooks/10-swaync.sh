#!/bin/bash
# swaync - link theme css + reload

src="$CURRENT_LINK/.config/swaync/style.css"
dst="$HOME/.config/swaync/style.css"

if [[ -f "$src" ]]; then
  mkdir -p "$HOME/.config/swaync"
  ln -sf "$src" "$dst"
fi

# reload if running
if pgrep -x swaync &>/dev/null; then
  swaync-client -R >/dev/null 2>&1 || true
fi

exit 0
