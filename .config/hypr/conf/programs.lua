-- ~/.config/hypr/conf/programs.lua
-- Application launchers, standalone scripts, and multi-key chord submaps

local home          = os.getenv("HOME")
local terminal      = "foot"
local filemanager   = "pcmanfm"
local browser       = "librewolf"
local menu          = "rofi -show drun"
-- Helper: Atomically reset submap and execute a command
local function chord(cmd)
    return function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.dispatch(hl.dsp.exec_cmd(cmd))
    end
end

-- =============================================================================
-- [1] PRIMARY APPLICATIONS (DIRECT SUPER + KEY)
-- Everyday essentials you access constantly without chord delays
-- =============================================================================

hl.bind(MOD .. " + Return", hl.dsp.exec_cmd(terminal))       -- Terminal
hl.bind(MOD .. " + e",      hl.dsp.exec_cmd(filemanager))    -- File Manager (PCManFM)
hl.bind(MOD .. " + w",      hl.dsp.exec_cmd(browser))        -- Web Browser
hl.bind(MOD .. " + space",  hl.dsp.exec_cmd(menu))           -- App Launcher / Rofi
hl.bind(MOD .. " + n",      hl.dsp.exec_cmd(terminal .. " -e nvim")) -- Neovim

-- hl.bind("SUPER + c", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/linux-control/bin/control"))
hl.bind("SUPER + Escape", hl.dsp.exec_cmd(home .. "/.config/scripts/system/sys"))


-- =============================================================================
-- [2] UTILITY & SCREENSHOT LEADER CHORD (SUPER + s)
-- Executes folder routers and unified utilities without wrapping overhead
-- =============================================================================
local scripts_dir = home .. "/.config/scripts"

hl.bind(MOD .. " + s", hl.dsp.submap("scripts_leader"))

hl.define_submap("scripts_leader", function()
    local script_actions = {
        -- --- Folder Menu Routers ---
        ["s"] = scripts_dir .. "/system/sys-menu",     -- System folder menu
        ["d"] = scripts_dir .. "/desktop/desk-menu",   -- Desktop folder menu
        ["n"] = scripts_dir .. "/notes/notes-menu",     -- Notes folder menu
        ["t"] = scripts_dir .. "/tools/tools-menu",     -- Tools folder menu

        -- --- Quick Unified Actions (No wrapper) ---
        ["f"] = scripts_dir .. "/desktop/shot full",    -- Full-screen screenshot
        ["a"] = scripts_dir .. "/desktop/shot window",  -- Active window screenshot
        ["w"] = scripts_dir .. "/desktop/shot",         -- Selected area screenshot (using slurp)
        ["p"] = scripts_dir .. "/desktop/shot color",   -- Colorpicker (HEX to clipboard)
    }

    for key, command in pairs(script_actions) do
        hl.bind(key, chord(command))
    end

    -- Cancel submap manually
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- =============================================================================
-- [3] SECONDARY TOOLS & TUIs LEADER CHORD (SUPER + p)
-- =============================================================================
hl.bind(MOD .. " + p", hl.dsp.submap("programs_leader"))

hl.define_submap("programs_leader", function()
    local program_actions = {
        -- Floating TUIs (class flag -a matched in rules.lua)
        ["m"] = terminal .. " -a kew_floating -T 'kew' -e kew",
        ["n"] = terminal .. " -a nmtui_floating nmtui-go",
        ["b"] = terminal .. " -a bluetuith_floating bluetuith",
        
        -- Floating Todo TUI (Directly executes ~/todo using the absolute path variable)
        ["t"] = terminal .. " -a todo_floating -T 'Todo' -e " .. home .. "/.config/scripts/todo/todo.py",


        -- Floating Foot Terminal (SUPER + p followed by f)
        ["f"] = terminal .. " -a term_floating -T 'Floating Terminal'",

        -- Secondary CLI / GUI utilities
        ["h"] = terminal .. " -a btop_floating btop",
        ["c"] = terminal .. " -a calc_floating qalc",
    }
    
    for key, command in pairs(program_actions) do
        hl.bind(key, chord(command))
    end

    -- Cancel submap manually
    hl.bind("escape", hl.dsp.submap("reset"))
end)

