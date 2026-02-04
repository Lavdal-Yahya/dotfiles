### Dotfiles setup (Arch + Hyprland)

This system uses a **bare git repository** at `~/.dotfiles` with `$HOME` as the work tree. Real config files live in your home directory (e.g. `~/.config/hypr`, `~/.zshrc`), and git history is stored in `~/.dotfiles`.

#### Tracked configs

The bare repo currently tracks these key paths:

- `~/.config/hypr/` – Hyprland core config, layouts, rules, scripts, and themes.
- `~/.config/kitty/kitty.conf` – Kitty terminal configuration.
- `~/.config/nwg-look/config` – GTK theme and icon configuration.
- `~/.config/rofi/` – Rofi launcher configuration and themes.
- `~/.config/mako/config` – Mako notification daemon configuration.
- `~/.config/swaync/` – Sway notification center configuration, assets, and scripts.
- `~/.config/waybar/` – Waybar configuration, styles, and helper scripts.
- `~/.config/xsettingsd/xsettingsd.conf` – Xsettingsd configuration for theme/GTK settings.
- `~/.config/backgrounds/` – Curated wallpapers for the setup.
- `~/.zshrc` – Shell configuration using Oh My Zsh and plugins.

#### Using the repo on this machine

Define a convenient alias in your shell (e.g. in `~/.zshrc`):

```sh
alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Then you can manage your dotfiles with:

```sh
dots status
dots add <path>
dots commit -m "message"
dots push
```

Because the repo is bare, `~/.dotfiles` should **not** be used as a normal working tree.

#### Using the repo on a new machine

On a fresh system:

1. Clone the bare repo:
   ```sh
   git clone --bare <REPO-URL> "$HOME/.dotfiles"
   ```
2. Define the alias:
   ```sh
   alias dots='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   ```
3. Check out your dotfiles into `$HOME`:
   ```sh
   dots checkout
   ```
   If there are conflicts with existing files, back them up or remove them, then run `dots checkout` again.
4. Optionally hide untracked files in status (already configured here via `status.showUntrackedFiles=no`).
5. Install the required packages and tools (Arch examples):
   - Hyprland and related tools
   - kitty
   - rofi
   - swaync
   - waybar
   - mako
   - nwg-look
   - xsettingsd
   - zsh, Oh My Zsh, plugins (`zsh-syntax-highlighting`, `zsh-autosuggestions`)

#### Oh My Zsh and plugins

`~/.zshrc` expects **Oh My Zsh** to be installed at `~/.oh-my-zsh`. On a new machine, install it with the official installer from the Oh My Zsh repository, then ensure the theme and plugins in `~/.zshrc` match what you want.

The `~/.oh-my-zsh` directory itself is not tracked in this repo to avoid nested git repos and noise; only your `~/.zshrc` and related shell configuration are versioned.

#### What is intentionally not tracked

To avoid committing large or sensitive data, the repo uses an internal exclude list (`~/.dotfiles/info/exclude`) to skip, for example:

- `~/.cache/`
- `~/.pki/`
- `~/.gnupg/`
- `~/.ssh/`
- `~/.local/share/Trash/`
- `~/.config/Code - OSS/`
- `~/.config/Cursor/`
- `~/.config/mozilla/`
- `~/Downloads/`
- `~/Pictures/` (only the curated wallpapers in `~/.config/backgrounds/` are tracked)

If you want to add more things later, just run `dots add <path>` and commit as usual.

#### Optional helper scripts

You can add helper scripts here in `~/Dotfiles/`, for example:

- `sync.sh` – run `dots status`, then stage common paths and commit.
- `bootstrap.sh` – a scripted version of the clone/checkout steps above.

These scripts can themselves be tracked by the bare repo by adding `~/Dotfiles/` to it.
