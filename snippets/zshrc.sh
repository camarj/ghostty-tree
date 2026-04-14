# Append these lines to your ~/.zshrc

# Eza: color directorios en Claude orange (#da7756)
export EZA_COLORS="di=38;2;218;119;86"

# Ghostty + Zellij + Yazi tree profile
alias ghostty-tree='open -na Ghostty --args --config-file=$HOME/.config/ghostty/config-tree'
alias ghostty-tree-dark='open -na Ghostty --args --config-file=$HOME/.config/ghostty/config-tree-dark'

# Sync shell cwd -> yazi floating pane (ghostty-tree profile)
# Requires yazi launched with --client-id writing to /tmp/yazi-zellij-<session>.id
autoload -U add-zsh-hook
_ghostty_tree_sync_yazi() {
    [[ -z "$ZELLIJ_SESSION_NAME" ]] && return
    local id_file="/tmp/yazi-zellij-${ZELLIJ_SESSION_NAME}.id"
    [[ -r "$id_file" ]] || return
    local yazi_id
    yazi_id=$(<"$id_file") || return
    [[ -n "$yazi_id" ]] && ya emit-to "$yazi_id" cd "$PWD" 2>/dev/null
}
add-zsh-hook chpwd _ghostty_tree_sync_yazi
