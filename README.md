# ghostty-tree

A terminal profile that opens **Ghostty** with a split layout: a regular shell on the left and a file-tree navigator on the right that edits files in nano and returns to the tree on close. Two modes — **light** and **dark** — themed end-to-end to match Claude Code's accent color (`#da7756`).

![preview placeholder — replace with your own screenshot](docs/preview-light.png)

---

## What this gives you

- `ghostty-tree` — launches a Ghostty window in **light mode**, splitted:
  - Left pane: plain zsh shell in `~/Documents`.
  - Right pane: [Yazi](https://yazi-rs.github.io/) (TUI file manager). Hit `Enter` on any file and it opens in `nano`; exit nano with `Ctrl+X` and you're back in the tree.
- `ghostty-tree-dark` — same thing in **dark mode**.
- `Option+B` inside the window toggles the right pane (hide/show the tree, like VS Code's sidebar).

Every UI element (shell prompt, file icons, status bars, cursor, selection) is harmonized to Claude's orange accent `#da7756` on a Flexoki base palette.

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Terminal emulator | [Ghostty](https://ghostty.org) | Fast GPU-accelerated terminal with theme support and per-window config files |
| Multiplexer / layout | [Zellij](https://zellij.dev) | Declarative KDL layouts, so the split opens pre-configured every time |
| File tree | [Yazi](https://yazi-rs.github.io/) | Modern Rust TUI file manager with async previews and `$EDITOR` integration |
| Prompt | [Starship](https://starship.rs) | Fast cross-shell prompt |
| `ls` replacement | [eza](https://eza.rocks/) | Modern `ls` with icons and git awareness |
| Editor | `nano` | Simple, no config required |
| Font | JetBrainsMono Nerd Font | Provides the glyphs Yazi and the status bar use |

---

## Requirements

- macOS (tested on Apple Silicon). Linux should work with minor path tweaks.
- [Homebrew](https://brew.sh) (the installer uses it to pull missing tools).
- A clone of this repo.

### Tools installed by the script

Run without them and `install.sh` will offer to install via Homebrew:

```
ghostty  zellij  yazi  starship  eza  font-jetbrains-mono-nerd-font
```

---

## Quick install

```bash
git clone https://github.com/camarj/ghostty-tree.git ~/ghostty-tree
cd ~/ghostty-tree
bash install.sh
```

The installer:

1. Verifies all CLI tools are present; offers to `brew install` anything missing.
2. Checks for JetBrainsMono Nerd Font.
3. Copies profile configs into place (backing up any existing files as `<name>.bak.<timestamp>`).
4. Derives `config-dark.kdl` from your existing Zellij config if present.
5. Prints a short list of **manual merges** for files it won't overwrite (your main Ghostty config, your Zellij config, your Starship config, and your `.zshrc`) so personal settings stay intact.

After the script finishes, follow the 4 manual merge steps below, then run:

```bash
source ~/.zshrc
ghostty-tree         # light
ghostty-tree-dark    # dark
```

---

## Manual install (step by step)

If you prefer to do everything by hand, or need to adapt for a different setup.

### 1. Install the tools

```bash
brew install ghostty zellij yazi starship eza
brew install --cask font-jetbrains-mono-nerd-font
```

Open Ghostty once so macOS registers it in `/Applications`.

### 2. Drop in the profile config files

Replace `<REPO>` with the path where you cloned this repo, and replace `/Users/YOU` with your actual `$HOME`.

```bash
# Ghostty per-profile configs
mkdir -p ~/.config/ghostty
sed "s|__HOME__|$HOME|g" <REPO>/ghostty/config-tree      > ~/.config/ghostty/config-tree
sed "s|__HOME__|$HOME|g" <REPO>/ghostty/config-tree-dark > ~/.config/ghostty/config-tree-dark

# Zellij themes and layouts
mkdir -p ~/.config/zellij/themes ~/.config/zellij/layouts
cp <REPO>/zellij/themes/flexoki-light.kdl ~/.config/zellij/themes/
cp <REPO>/zellij/themes/flexoki-dark.kdl  ~/.config/zellij/themes/
cp <REPO>/zellij/layouts/tree.kdl         ~/.config/zellij/layouts/
cp <REPO>/zellij/layouts/tree-dark.kdl    ~/.config/zellij/layouts/

# Yazi (light + dark)
mkdir -p ~/.config/yazi ~/.config/yazi-dark
cp <REPO>/yazi/yazi.toml       ~/.config/yazi/
cp <REPO>/yazi/theme.toml      ~/.config/yazi/
cp <REPO>/yazi-dark/yazi.toml  ~/.config/yazi-dark/
cp <REPO>/yazi-dark/theme.toml ~/.config/yazi-dark/
```

### 3. Merge into your existing configs

These files you **edit**, not overwrite — they contain your personal settings too.

#### 3a. Ghostty main config

Path (macOS): `~/Library/Application Support/com.mitchellh.ghostty/config`
Path (Linux): `~/.config/ghostty/config`

Make sure your base theme is set — then append the Claude accent overrides:

```ini
theme = Flexoki Light

macos-option-as-alt = true
cursor-color = #da7756
```

(Full snippet in [`snippets/ghostty-main.conf`](snippets/ghostty-main.conf).)

> The two profile configs (`config-tree` and `config-tree-dark`) already carry their own cursor/selection overrides; this change applies to regular Ghostty windows too.

#### 3b. Zellij main config

Path: `~/.config/zellij/config.kdl`

If you don't have one:
```bash
zellij setup --dump-config > ~/.config/zellij/config.kdl
```

Then in that file:

- Set the theme: change or add `theme "flexoki-light"`
- Disable pane frames and startup noise:
  ```kdl
  pane_frames false
  show_startup_tips false
  show_release_notes false
  ```
- Add the sidebar toggle keybind **inside** the `shared_except "locked" { ... }` block:
  ```kdl
  bind "Alt b" { MoveFocus "left"; ToggleFocusFullscreen; }
  ```

Full snippet: [`snippets/zellij-main.kdl`](snippets/zellij-main.kdl).

Then derive the dark variant:
```bash
sed 's|theme "flexoki-light"|theme "flexoki-dark"|' \
    ~/.config/zellij/config.kdl > ~/.config/zellij/config-dark.kdl
```

#### 3c. Starship

Path: `~/.config/starship.toml`

Merge the color tweaks:

```toml
[directory]
style = "bold #da7756"

[git_branch]
style = "bold #A02F6F"

[character]
success_symbol = "[❯](bold #da7756)"
error_symbol = "[❯](bold #AF3029)"
```

Full snippet: [`snippets/starship.toml`](snippets/starship.toml).

#### 3d. Zsh

Path: `~/.zshrc`

Append:

```bash
export EZA_COLORS="di=38;2;218;119;86"
alias ghostty-tree='open -na Ghostty --args --config-file=$HOME/.config/ghostty/config-tree'
alias ghostty-tree-dark='open -na Ghostty --args --config-file=$HOME/.config/ghostty/config-tree-dark'
```

Full snippet: [`snippets/zshrc.sh`](snippets/zshrc.sh).

Reload:
```bash
source ~/.zshrc
```

---

## Usage

### Launch

```bash
ghostty-tree         # light mode window
ghostty-tree-dark    # dark mode window
```

Both are fully independent windows — you can open several of each.

### Keybinds inside the window

| Key | Action |
|---|---|
| `Option+B` | Toggle the right pane (hide/show the tree) |
| Arrow keys in Yazi | Navigate files and directories |
| `Enter` on a file | Open in `nano` |
| `Ctrl+X` in nano | Save/quit → return to tree |
| `q` in Yazi | Quit the file manager pane |
| `Ctrl+P` then `n/d/r/s` | Zellij pane mode: new, down, right, stacked |
| `Ctrl+T` then `n/1..9/x` | Zellij tab mode: new tab, switch, close |
| `Ctrl+G` | Zellij "locked" mode (passes keys through) |
| `Ctrl+Q` | Quit zellij session |

### Opening Claude Code

The left pane is a regular shell. Just run:

```bash
claude
```

Or any other CLI you'd normally run in a terminal.

---

## File structure

```
ghostty-tree/
├── README.md
├── install.sh
├── ghostty/
│   ├── config-tree              # Light profile — launched by `ghostty-tree`
│   └── config-tree-dark         # Dark profile — launched by `ghostty-tree-dark`
├── zellij/
│   ├── themes/
│   │   ├── flexoki-light.kdl    # UI palette for light mode
│   │   └── flexoki-dark.kdl     # UI palette for dark mode
│   └── layouts/
│       ├── tree.kdl             # Split layout (shell 65% | yazi 35%) — light
│       └── tree-dark.kdl        # Same layout — dark (launches yazi with YAZI_CONFIG_HOME)
├── yazi/
│   ├── yazi.toml                # Single-column tree, opens files in nano
│   └── theme.toml               # Light color scheme
├── yazi-dark/
│   ├── yazi.toml                # Copy of above
│   └── theme.toml               # Dark color scheme
└── snippets/
    ├── ghostty-main.conf        # Append to your main Ghostty config
    ├── zellij-main.kdl          # Append/merge into ~/.config/zellij/config.kdl
    ├── starship.toml            # Merge into ~/.config/starship.toml
    └── zshrc.sh                 # Append to ~/.zshrc
```

### Files created in your `~/.config` after install

```
~/.config/ghostty/config-tree
~/.config/ghostty/config-tree-dark
~/.config/zellij/themes/flexoki-light.kdl
~/.config/zellij/themes/flexoki-dark.kdl
~/.config/zellij/layouts/tree.kdl
~/.config/zellij/layouts/tree-dark.kdl
~/.config/zellij/config-dark.kdl       # derived from your config.kdl
~/.config/yazi/yazi.toml
~/.config/yazi/theme.toml
~/.config/yazi-dark/yazi.toml
~/.config/yazi-dark/theme.toml
```

The dark mode reads its Yazi theme from `~/.config/yazi-dark/` via the env var `YAZI_CONFIG_HOME`, set inline in `zellij/layouts/tree-dark.kdl`.

---

## Customization

| You want to… | Edit |
|---|---|
| Change the split ratio | `zellij/layouts/tree.kdl` and `tree-dark.kdl` — the `size="65%"` / `size="35%"` values |
| Use a different editor | `yazi/yazi.toml` (and `yazi-dark/yazi.toml`) — replace `nano %s` with your editor |
| Change the accent color | Global find/replace `#da7756` across all config files |
| Disable the sidebar toggle | Remove the `bind "Alt b"` line in `~/.config/zellij/config.kdl` |
| Start in a different directory | `ghostty/config-tree` → `working-directory = /path/to/dir` |

### Color palette reference

| Token | Light | Dark | Used for |
|---|---|---|---|
| Accent | `#da7756` | `#da7756` | Claude orange — selection, cursor, prompt, active tabs, folder icons |
| Background | `#FFFCF0` | `#100F0F` | Flexoki paper / black |
| Foreground | `#100F0F` | `#CECDC3` | Default text |
| Error | `#AF3029` | `#D14D41` | Errors, warnings |
| Warning | `#AD8301` | `#D0A215` | `find_keyword`, select mode |

Greens and blues are intentionally removed from the UI to match Claude Code's visual language.

---

## Uninstall

Each config file has a timestamped backup next to it from when the installer ran:

```bash
# Restore the most recent backups (adjust the timestamp)
cd ~/.config/ghostty && for f in *.bak.*; do mv "$f" "${f%.bak.*}"; done
```

Or delete the files outright:

```bash
rm ~/.config/ghostty/config-tree{,-dark}
rm ~/.config/zellij/themes/flexoki-{light,dark}.kdl
rm ~/.config/zellij/layouts/tree{,-dark}.kdl
rm ~/.config/zellij/config-dark.kdl
rm -rf ~/.config/yazi ~/.config/yazi-dark
```

And remove the four manual-merge blocks from Ghostty config, Zellij config, Starship, and `.zshrc`.

---

## Credits

- Color palette derived from [Flexoki](https://stephango.com/flexoki) by Steph Ango.
- Accent color `#da7756` extracted from the [Claude Code](https://docs.claude.com/claude-code) CLI binary (`w_.hex("#da7756")`).
- Inspired by VS Code's integrated terminal + Explorer split.

---

## License

MIT
