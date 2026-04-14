#!/usr/bin/env bash
# Installer for ghostty-tree: Ghostty + Zellij + Yazi profile
# Usage: bash install.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
TS="$(date +%Y%m%d-%H%M%S)"

color() { printf "\033[1;38;2;218;119;86m%s\033[0m\n" "$*"; }
info()  { printf "  %s\n" "$*"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$*"; }
err()   { printf "\033[1;31m✗ %s\033[0m\n" "$*" >&2; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$*"; }

backup() {
    local path="$1"
    if [ -e "$path" ] || [ -L "$path" ]; then
        local bak="${path}.bak.${TS}"
        mv "$path" "$bak"
        info "backup: $(basename "$path") → $(basename "$bak")"
    fi
}

# ── 1. Check OS ─────────────────────────────────────────────
if [ "$(uname)" != "Darwin" ]; then
    warn "This installer is tuned for macOS. Paths for Linux may differ."
fi

# ── 2. Check dependencies ───────────────────────────────────
color "▸ Checking dependencies"

missing=()
for bin in ghostty zellij yazi starship eza; do
    if ! command -v "$bin" >/dev/null 2>&1; then
        # ghostty may live in /Applications and not be on PATH
        if [ "$bin" = "ghostty" ] && [ -x "/Applications/Ghostty.app/Contents/MacOS/ghostty" ]; then
            ok "ghostty (in /Applications)"
            continue
        fi
        missing+=("$bin")
        warn "$bin not found"
    else
        ok "$bin"
    fi
done

if [ "${#missing[@]}" -gt 0 ]; then
    warn "Missing: ${missing[*]}"
    if command -v brew >/dev/null 2>&1; then
        read -rp "Install missing tools via Homebrew? [y/N] " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
            for b in "${missing[@]}"; do
                case "$b" in
                    ghostty)  brew install --cask ghostty ;;
                    *)        brew install "$b" ;;
                esac
            done
        else
            err "Install the tools manually and re-run this script."
            exit 1
        fi
    else
        err "Homebrew not found. Install Homebrew first: https://brew.sh"
        exit 1
    fi
fi

# Nerd Font check (JetBrainsMono Nerd Font)
if ! fc-list 2>/dev/null | grep -iq "JetBrains.*Nerd Font" && \
   ! ls ~/Library/Fonts 2>/dev/null | grep -iq "JetBrains.*Nerd" && \
   ! ls /Library/Fonts 2>/dev/null | grep -iq "JetBrains.*Nerd"; then
    warn "JetBrainsMono Nerd Font not detected."
    if command -v brew >/dev/null 2>&1; then
        read -rp "Install it via Homebrew? [y/N] " yn
        if [[ "$yn" =~ ^[Yy]$ ]]; then
            brew install --cask font-jetbrains-mono-nerd-font
        fi
    fi
else
    ok "JetBrainsMono Nerd Font"
fi

# ── 3. Install configs ──────────────────────────────────────
color "▸ Installing config files"

# Ghostty profile configs (substitute __HOME__)
mkdir -p "$HOME_DIR/.config/ghostty"
backup "$HOME_DIR/.config/ghostty/config-tree"
backup "$HOME_DIR/.config/ghostty/config-tree-dark"
sed "s|__HOME__|$HOME_DIR|g" "$REPO_DIR/ghostty/config-tree"      > "$HOME_DIR/.config/ghostty/config-tree"
sed "s|__HOME__|$HOME_DIR|g" "$REPO_DIR/ghostty/config-tree-dark" > "$HOME_DIR/.config/ghostty/config-tree-dark"
ok "ghostty/config-tree + config-tree-dark"

# Zellij themes
mkdir -p "$HOME_DIR/.config/zellij/themes" "$HOME_DIR/.config/zellij/layouts"
backup "$HOME_DIR/.config/zellij/themes/flexoki-light.kdl"
backup "$HOME_DIR/.config/zellij/themes/flexoki-dark.kdl"
cp "$REPO_DIR/zellij/themes/flexoki-light.kdl" "$HOME_DIR/.config/zellij/themes/"
cp "$REPO_DIR/zellij/themes/flexoki-dark.kdl"  "$HOME_DIR/.config/zellij/themes/"
ok "zellij/themes/flexoki-{light,dark}.kdl"

# Zellij layouts
backup "$HOME_DIR/.config/zellij/layouts/tree.kdl"
backup "$HOME_DIR/.config/zellij/layouts/tree-dark.kdl"
cp "$REPO_DIR/zellij/layouts/tree.kdl"      "$HOME_DIR/.config/zellij/layouts/"
cp "$REPO_DIR/zellij/layouts/tree-dark.kdl" "$HOME_DIR/.config/zellij/layouts/"
ok "zellij/layouts/tree{,-dark}.kdl"

# Yazi configs (light + dark)
mkdir -p "$HOME_DIR/.config/yazi" "$HOME_DIR/.config/yazi-dark"
for f in yazi.toml theme.toml; do
    backup "$HOME_DIR/.config/yazi/$f"
    cp "$REPO_DIR/yazi/$f" "$HOME_DIR/.config/yazi/$f"
    backup "$HOME_DIR/.config/yazi-dark/$f"
    cp "$REPO_DIR/yazi-dark/$f" "$HOME_DIR/.config/yazi-dark/$f"
done
ok "yazi/ + yazi-dark/ (yazi.toml + theme.toml)"

# Dark zellij config (needs a full zellij config with flexoki-dark theme).
# If user has an existing main config.kdl, we derive the dark variant from it.
if [ -f "$HOME_DIR/.config/zellij/config.kdl" ]; then
    if [ ! -f "$HOME_DIR/.config/zellij/config-dark.kdl" ]; then
        sed 's|theme "flexoki-light"|theme "flexoki-dark"|' \
            "$HOME_DIR/.config/zellij/config.kdl" > "$HOME_DIR/.config/zellij/config-dark.kdl"
        ok "zellij/config-dark.kdl (derived from config.kdl)"
    else
        info "config-dark.kdl exists, skipping"
    fi
else
    warn "No zellij main config.kdl found. Run:"
    info "    zellij setup --dump-config > ~/.config/zellij/config.kdl"
    info "Then re-run this installer or create config-dark.kdl manually."
fi

# ── 4. Manual merges ────────────────────────────────────────
color "▸ Manual steps remaining"
cat <<EOF

  The following files must be MERGED (not overwritten) because they likely
  contain your personal settings. Edit each file and add the snippet shown.

  1. Ghostty main config
       ~/Library/Application Support/com.mitchellh.ghostty/config
     Append from:  $REPO_DIR/snippets/ghostty-main.conf
     (Make sure your base theme is set, e.g.:  theme = Flexoki Light)

  2. Zellij main config
       ~/.config/zellij/config.kdl
     Append/merge from:  $REPO_DIR/snippets/zellij-main.kdl
     (Includes theme "flexoki-light" and the Alt+B keybind.)

  3. Starship
       ~/.config/starship.toml
     Merge from:  $REPO_DIR/snippets/starship.toml

  4. Zsh (aliases + EZA_COLORS)
       ~/.zshrc
     Append from:  $REPO_DIR/snippets/zshrc.sh
     Then:  source ~/.zshrc

EOF

color "▸ Done"
echo
echo "Launch:"
echo "    ghostty-tree        # light mode"
echo "    ghostty-tree-dark   # dark mode"
