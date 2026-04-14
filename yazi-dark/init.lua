-- git.yazi — status signs next to files/dirs
-- Styles MUST be set before setup().

th.git = th.git or {}

-- Colors (Flexoki Dark + Claude accent)
th.git.modified  = ui.Style():fg("#D0A215")           -- yellow (dirty)
th.git.added     = ui.Style():fg("#da7756")           -- Claude orange (staged)
th.git.untracked = ui.Style():fg("#878580")           -- dim gray
th.git.ignored   = ui.Style():fg("#403E3C")           -- very dim
th.git.deleted   = ui.Style():fg("#D14D41"):bold()    -- red
th.git.updated   = ui.Style():fg("#D0A215")
th.git.unknown   = ui.Style():fg("#878580")

-- Symbols
th.git.modified_sign  = "M"
th.git.added_sign     = "A"
th.git.untracked_sign = "?"
th.git.ignored_sign   = ""
th.git.deleted_sign   = "D"
th.git.updated_sign   = "U"
th.git.unknown_sign   = ""

require("git"):setup { order = 1500 }
