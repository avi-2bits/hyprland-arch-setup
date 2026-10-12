-- ~/.config/hypr/hyprland.lua
-- Master Orchestrator

-- Global Mod Key (Accessible by all required configuration files)
MOD = "SUPER"

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Modular Configurations
require("conf.settings")
require("conf.autostart")
require("conf.keybinds")
require("conf.programs")
require("conf.rules")

