#!/usr/bin/env bash
set -euo pipefail

# --- packages (pacman) ---
sudo pacman -S --needed \
  git base-devel \
  hyprland \
  waybar hyprpaper nautilus \
  kitty starship wofi \
  mako \
  grim slurp wl-clipboard \
  ranger \
  xdg-desktop-portal-hyprland \
  qt5-wayland qt6-wayland

# --- yay install (idempotent) ---
if ! command -v yay >/dev/null 2>&1; then
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si)
  rm -rf "$tmpdir"
fi

# --- AUR packages ---
yay -S --needed \
  zen-browser \
  swaylock-effects

# --- dirs ---
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/wallpapers"
mkdir -p "$HOME/.config/swaylock"
mkdir -p "$HOME/.config"

# --- configs ---
install -m 644 ./hyprland.conf "$HOME/.config/hypr/hyprland.conf"
install -m 644 ./hyprpaper.conf "$HOME/.config/hypr/hyprpaper.conf"
install -m 644 ./wall.png "$HOME/.config/wallpapers/wall.png"

# --- kitty (replace directory) ---
rm -rf "$HOME/.config/kitty"
cp -a ./kitty "$HOME/.config/kitty"

# --- waybar (replace directory) ---
rm -rf "$HOME/.config/waybar"
cp -a ./waybar "$HOME/.config/waybar"

# --- wofi (replace directory) ---
rm -rf "$HOME/.config/wofi"
cp -a ./wofi "$HOME/.config/wofi"

# --- swaylock (copy config) ---
# Expected repo path: ./swaylock/config
# (If you instead have a single file, change this to an install -m 644 line.)
if [ -f "./swaylock/config" ]; then
  install -m 644 ./swaylock/config "$HOME/.config/swaylock/config"
fi

# --- starship ---
install -m 644 ./starship.toml "$HOME/.config/starship.toml"

# --- starship init (zsh) ---
if [ -f "$HOME/.zshrc" ] && ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
  printf '\n# Starship\neval "$(starship init zsh)"\n' >>"$HOME/.zshrc"
fi

# --- starship init (bash) ---
if [ -f "$HOME/.bashrc" ] && ! grep -q 'starship init bash' "$HOME/.bashrc"; then
  printf '\n# Starship\neval "$(starship init bash)"\n' >>"$HOME/.bashrc"
fi

echo "Hyprland setup complete."
