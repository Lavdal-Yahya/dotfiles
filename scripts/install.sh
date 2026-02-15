#!/bin/bash
# Dotfiles install script - symlink-based, with backup
# Usage: ./scripts/install.sh

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"
echo "Backups will be saved to: $BACKUP_DIR"

# Backup and symlink a path
link_config() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "Backing up $dst -> $BACKUP_DIR/"
    cp -a "$dst" "$BACKUP_DIR/$(basename "$dst")" 2>/dev/null || mv "$dst" "$BACKUP_DIR/"
  fi
  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "Linked: $dst -> $src"
}

# Config directories
for dir in hypr waybar rofi swaync swayosd kitty ghostty tmux environment.d systemd odyssey; do
  src="$DOTFILES_ROOT/config/$dir"
  dst="$CONFIG_DIR/$dir"
  [[ -d "$src" ]] || continue
  link_config "$src" "$dst"
done

# Home dotfiles
link_config "$DOTFILES_ROOT/home/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_ROOT/home/.bashrc" "$HOME/.bashrc"
link_config "$DOTFILES_ROOT/home/.gitconfig" "$HOME/.gitconfig"

# Local bin
mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES_ROOT/localbin"/*; do
  [[ -e "$f" ]] || continue
  name=$(basename "$f")
  link_config "$f" "$HOME/.local/bin/$name"
done

# Ensure odyssey/current exists
odyssey_current="$CONFIG_DIR/odyssey/current"
if [[ ! -e "$odyssey_current" ]]; then
  default_theme="void"
  ln -sfn "themes/$default_theme" "$odyssey_current"
  echo "Created odyssey/current -> themes/$default_theme"
fi

echo ""
echo "Install complete. Restart Hyprland or log out and back in for full effect."
echo "Enable battery-warn timer: systemctl --user enable --now battery-warn.timer"
