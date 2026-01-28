#!/usr/bin/env bash
set -euo pipefail

echo "Starting Hyprland & Zsh deployment..."

# --- 1. Core Packages (pacman) ---
# Added ttf-jetbrains-mono-nerd for icons and blueman for bluetooth management
sudo pacman -S --needed \
  git base-devel \
  hyprland \
  waybar hyprpaper nautilus \
  kitty starship wofi \
  mako \
  grim slurp wl-clipboard \
  ranger \
  xdg-desktop-portal-hyprland \
  qt5-wayland qt6-wayland \
  nvim \
  zsh \
  ttf-jetbrains-mono-nerd \
  blueman \
  network-manager-applet \
  pulseaudio

# --- 2. Set Zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  sudo usermod --shell "$(which zsh)" "$USER"
fi

# --- 3. yay install (idempotent) ---
if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay..."
  tmpdir="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

# --- 4. AUR packages ---
# Added inter-font for the UI text styling
yay -S --needed --noconfirm \
  zen-browser-bin \
  swaylock-effects \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  inter-font

# --- 5. Directory Structure ---
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/wallpapers"
mkdir -p "$HOME/.config/swaylock"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/wofi"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/nvim"

# --- 6. Configuration Files Deployment ---
# Standard configs
[ -f ./hyprland.conf ] && install -m 644 ./hyprland.conf "$HOME/.config/hypr/hyprland.conf"
[ -f ./hyprpaper.conf ] && install -m 644 ./hyprpaper.conf "$HOME/.config/hypr/hyprpaper.conf"
[ -f ./wall.png ] && install -m 644 ./wall.png "$HOME/.config/wallpapers/wall.png"
[ -f ./starship.toml ] && install -m 644 ./starship.toml "$HOME/.config/starship.toml"

# Directory-based configs (Kitty, Waybar, Wofi, Nvim)
for dir in kitty waybar wofi nvim; do
  if [ -d "./$dir" ]; then
    echo "Updating $dir configuration..."
    rm -rf "$HOME/.config/$dir"
    cp -ra "./$dir" "$HOME/.config/"
  fi
done

# Swaylock config check
if [ -f "./swaylock/config" ]; then
  install -m 644 ./swaylock/config "$HOME/.config/swaylock/config"
fi

# --- 7. Zsh & Starship Initialization ---
touch "$HOME/.zshrc"
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
  printf '\n# Starship Prompt\neval "$(starship init zsh)"\n' >>"$HOME/.zshrc"
fi

touch "$HOME/.bashrc"
if ! grep -q 'starship init bash' "$HOME/.bashrc"; then
  printf '\n# Starship Prompt\neval "$(starship init bash)"\n' >>"$HOME/.bashrc"
fi

{
  echo "# Plugins"
  echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
} >>"$HOME/.zshrc.tmp"

if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
  cat "$HOME/.zshrc.tmp" >>"$HOME/.zshrc"
fi
rm "$HOME/.zshrc.tmp"

echo "-------------------------------------------------------"
echo "Setup complete! Please log out and back in for shell changes."
echo "To enter your new shell immediately, type: zsh"
echo "-------------------------------------------------------"
