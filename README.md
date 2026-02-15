# Dotfiles

Portable Hyprland stack + Odyssey theming + systemd user units + shell configs.

## Contents

- **config/hypr** — Hyprland compositor config
- **config/waybar** — Waybar status bar
- **config/rofi** — Rofi menus and scripts
- **config/swaync** — Sway notification center
- **config/swayosd** — Volume/brightness OSD
- **config/kitty**, **config/ghostty** — Terminal configs
- **config/tmux** — Tmux config
- **config/environment.d** — Environment variables
- **config/odyssey** — Odyssey theme engine and themes
- **config/systemd** — User systemd units (e.g. battery-warn)
- **home/** — `.zshrc`, `.bashrc`, `.gitconfig`
- **localbin/** — `odyssey` CLI

## Install

```bash
git clone https://github.com/Lavdal-Yahya/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install.sh
```

After install, enable the battery-warn timer:

```bash
systemctl --user enable --now battery-warn.timer
```

## Wallpapers

- Place wallpapers in `~/Wallpapers` (or set `WALLPAPER_DIR`)
- Dynamic theme uses matugen with images from `~/Wallpapers`
- Theme-specific wallpapers are in `config/odyssey/themes/<theme>/backgrounds/`

## Safety

- **No SSH keys** or other secrets are tracked
- **VSCode/Cursor/Windsurf** state is excluded
- **odyssey.bak-*** backup dirs are excluded
