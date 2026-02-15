#!/usr/bin/env bash
set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCALBIN_DIR="${HOME}/.local/bin"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${HOME}/.dotfiles-backup/${TS}"

mkdir -p "${BACKUP_DIR}" "${CONFIG_DIR}" "${LOCALBIN_DIR}"

log() { printf "\n\033[1m%s\033[0m\n" "$*"; }

backup_path() {
  local dst="$1"
  [[ -e "${dst}" || -L "${dst}" ]] || return 0

  # preserve relative path under $HOME to avoid collisions
  local rel
  rel="${dst#${HOME}/}"
  mkdir -p "${BACKUP_DIR}/$(dirname "${rel}")"
  mv -f "${dst}" "${BACKUP_DIR}/${rel}"
}

link_path() {
  local src="$1"
  local dst="$2"

  [[ -e "${src}" || -L "${src}" ]] || return 0
  mkdir -p "$(dirname "${dst}")"
  backup_path "${dst}"
  ln -s "${src}" "${dst}"
  echo "Linked: ${dst} -> ${src}"
}

log "Dotfiles install"
echo "Repo:   ${DOTFILES_ROOT}"
echo "Backup: ${BACKUP_DIR}"

# Link core config directories
log "Linking ~/.config"
for dir in hypr waybar rofi swaync swayosd kitty ghostty tmux environment.d systemd odyssey; do
  src="${DOTFILES_ROOT}/config/${dir}"
  dst="${CONFIG_DIR}/${dir}"
  [[ -d "${src}" ]] || continue
  link_path "${src}" "${dst}"
done

# Home dotfiles (only if present in repo)
log "Linking home dotfiles"
for f in .zshrc .bashrc .gitconfig; do
  src="${DOTFILES_ROOT}/home/${f}"
  [[ -f "${src}" ]] || continue
  link_path "${src}" "${HOME}/${f}"
done

# Local bin
log "Linking ~/.local/bin"
if [[ -d "${DOTFILES_ROOT}/localbin" ]]; then
  shopt -s nullglob
  for f in "${DOTFILES_ROOT}/localbin/"*; do
    name="$(basename "${f}")"
    link_path "${f}" "${LOCALBIN_DIR}/${name}"
  done
  shopt -u nullglob
fi

# Ensure odyssey/current exists (relative symlink is best)
log "Odyssey current theme"
odyssey_current="${CONFIG_DIR}/odyssey/current"
if [[ ! -e "${odyssey_current}" && ! -L "${odyssey_current}" ]]; then
  default_theme="void"
  ln -s "themes/${default_theme}" "${odyssey_current}"
  echo "Created: ${odyssey_current} -> themes/${default_theme}"
fi

log "Done ✅"
echo "Next:"
echo "  systemctl --user daemon-reload"
echo "  systemctl --user enable --now battery-warn.timer"
echo "  (optional) ${DOTFILES_ROOT}/scripts/apply-theme.sh void"
