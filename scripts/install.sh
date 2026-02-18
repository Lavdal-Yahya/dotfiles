#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Error on line $LINENO"; exit 1' ERR

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCALBIN_DIR="${HOME}/.local/bin"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="${HOME}/.dotfiles-backup/${TS}"

mkdir -p "${BACKUP_DIR}" "${CONFIG_DIR}" "${LOCALBIN_DIR}"

log() { printf "\n\033[1m%s\033[0m\n" "$*"; }

# ---------------------------
# Args
# ---------------------------
INSTALL_PKGS=0
for arg in "$@"; do
  case "$arg" in
    --install|--packages) INSTALL_PKGS=1 ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [--install]

Options:
  --install, --packages   Install missing packages via yay (Arch only)
  -h, --help              Show this help
EOF
      exit 0
      ;;
  esac
done

# ---------------------------
# Package check / install (Arch + yay)
# ---------------------------
log "Checking packages (Arch + yay)"

deps=(
  "Hyprland:hyprland"
  "waybar:waybar"
  "rofi:rofi-wayland"
  "swaync:swaync"
  "swayosd:swayosd"
  "kitty:kitty"
  "ghostty:ghostty"
  "tmux:tmux"
  "nwg-look:nwg-look"
)

missing_pkgs=()
missing_cmds=()

for item in "${deps[@]}"; do
  cmd="${item%%:*}"
  pkg="${item##*:}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing_cmds+=("$cmd")
    missing_pkgs+=("$pkg")
  fi
done

if ((${#missing_pkgs[@]})); then
  echo "Missing commands:"
  printf "  - %s\n" "${missing_cmds[@]}"
  echo
  echo "Packages to install:"
  printf "  - %s\n" "${missing_pkgs[@]}"
  echo

  if [[ "${INSTALL_PKGS}" -eq 1 ]]; then
    if ! command -v yay >/dev/null 2>&1; then
      echo "Error: yay is not installed. Install yay first, then re-run."
      exit 1
    fi
    log "Installing missing packages via yay"
    yay -S --needed --noconfirm "${missing_pkgs[@]}"
  else
    echo "Run this to install:"
    echo "  yay -S --needed ${missing_pkgs[*]}"
    echo "Or rerun installer with:"
    echo "  $0 --install"
    exit 1
  fi
else
  echo "All required packages look installed ✅"
fi

# ---------------------------
# Backup + link helpers
# ---------------------------
backup_path() {
  local dst="$1"
  [[ -e "${dst}" || -L "${dst}" ]] || return 0

  local rel
  if [[ "${dst}" == "${HOME}/"* ]]; then
    rel="${dst#${HOME}/}"
  else
    rel="_external/${dst#/}"
  fi

  mkdir -p "${BACKUP_DIR}/$(dirname "${rel}")"
  mv -f "${dst}" "${BACKUP_DIR}/${rel}"
}

link_path() {
  local src="$1"
  local dst="$2"

  [[ -e "${src}" || -L "${src}" ]] || return 0
  mkdir -p "$(dirname "${dst}")"

  # Idempotency: if dst already links to src, skip
  if [[ -L "${dst}" ]]; then
    local dst_target
    dst_target="$(readlink "${dst}")" || dst_target=""
    if command -v realpath >/dev/null 2>&1; then
      local src_abs dst_abs
      src_abs="$(realpath "${src}")"
      dst_abs="$(realpath "$(dirname "${dst}")/${dst_target}" 2>/dev/null || true)"
      if [[ -n "${dst_abs}" && "${dst_abs}" == "${src_abs}" ]]; then
        echo "OK: ${dst} already linked"
        return 0
      fi
    else
      [[ "${dst_target}" == "${src}" ]] && { echo "OK: ${dst} already linked"; return 0; }
    fi
  fi

  backup_path "${dst}"
  ln -sfn "${src}" "${dst}"
  echo "Linked: ${dst} -> ${src}"
}

# ---------------------------
# Main install
# ---------------------------
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

# Ensure odyssey/current exists (note: if odyssey is symlinked, this may write into the repo)
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
