#!/bin/bash
# Waybar - apply theme css and restart

mkdir -p "$HOME/.config/waybar"

# Link theme colors.css if present
csrc="$CURRENT_LINK/.config/waybar/colors.css"
if [[ -f "$csrc" ]]; then
  ln -sf "$csrc" "$HOME/.config/waybar/colors.css"
fi

# Ensure style.css imports colors.css (one-time, safe)
style="$HOME/.config/waybar/style.css"
if [[ -f "$style" ]]; then
  grep -q '@import "colors.css";' "$style" || sed -i '1i @import "colors.css";\n' "$style"
fi

# If the theme provides a full style.css, prefer linking it (optional but useful)
ssrc="$CURRENT_LINK/.config/waybar/style.css"
if [[ -f "$ssrc" ]]; then
  ln -sf "$ssrc" "$HOME/.config/waybar/style.css"
  # If we linked style.css from theme, it should still import colors.css if needed.
fi

pkill -x waybar 2>/dev/null
sleep 0.3
# Start waybar in the same way the system expects (keep existing)
setsid uwsm-app -- waybar >/dev/null 2>&1 &
exit 0
