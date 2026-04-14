-- git.yazi — status signs next to files/dirs
-- Styles MUST be set before setup().

th.git = th.git or {}

-- Colors (Flexoki Light + Claude accent)
th.git.modified  = ui.Style():fg("#AD8301")           -- yellow (dirty)
th.git.added     = ui.Style():fg("#da7756")           -- Claude orange (staged)
th.git.untracked = ui.Style():fg("#6F6E69")           -- dim gray
th.git.ignored   = ui.Style():fg("#CECDC3")           -- very dim
th.git.deleted   = ui.Style():fg("#AF3029"):bold()    -- red
th.git.updated   = ui.Style():fg("#AD8301")
th.git.unknown   = ui.Style():fg("#6F6E69")

-- Symbols
th.git.modified_sign  = "M"
th.git.added_sign     = "A"
th.git.untracked_sign = "?"
th.git.ignored_sign   = ""
th.git.deleted_sign   = "D"
th.git.updated_sign   = "U"
th.git.unknown_sign   = ""

require("git"):setup { order = 1500 }
