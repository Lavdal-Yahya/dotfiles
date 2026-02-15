#!/bin/bash

TMP_DIR="$HOME/.cache/swaync"
TMP_COVER_PATH="$TMP_DIR/${SWAYNC_SUMMARY}.png"
TMP_TEMP_PATH="$TMP_DIR/temp.png"

mkdir -p "$TMP_DIR"

ART_FROM_SPOTIFY="$(playerctl -p %any,spotify metadata mpris:artUrl | sed -e 's/open.spotify.com/i.scdn.co/g')"

if [[ $(playerctl -p spotify,%any,firefox,chromium,brave,mpd metadata mpris:artUrl) ]]; then
  curl -s "$ART_FROM_SPOTIFY" --output "$TMP_COVER_PATH"
fi

# Only copy if temp.png exists
if [[ -f "$TMP_TEMP_PATH" ]]; then
  cp "$TMP_TEMP_PATH" "$TMP_COVER_PATH"
fi
