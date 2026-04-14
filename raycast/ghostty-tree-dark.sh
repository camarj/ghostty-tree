#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Ghostty Tree Dark
# @raycast.mode silent
# @raycast.icon 🌙
# @raycast.packageName Terminal
# @raycast.description Open Ghostty with shell + Yazi tree split (dark mode)

open -na Ghostty --args --config-file="$HOME/.config/ghostty/config-tree-dark"
