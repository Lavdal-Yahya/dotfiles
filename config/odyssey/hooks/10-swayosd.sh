#!/bin/bash
# swayosd - restart server so config/theme changes apply

if pgrep -x swayosd-server &>/dev/null; then
  pkill -x swayosd-server 2>/dev/null || true
  sleep 0.1
fi

# start if available
command -v swayosd-server >/dev/null 2>&1 && swayosd-server >/dev/null 2>&1 &

exit 0

