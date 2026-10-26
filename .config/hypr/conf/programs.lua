-- ~/.config/hypr/conf/programs.lua
-- Application launchers, standalone scripts, and multi-key chord submaps

local home          = os.getenv("HOME")
local terminal      = "foot"
local filemanager   = "pcmanfm"
local browser       = "librewolf"
local menu          = "rofi -show drun"
local powermenu_cmd = home .. "/.config/scripts/powermenu.sh"
local sp_cmd        = home .. "/.config/scripts/sp.sh"

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
hl.bind(MOD .. " + Escape", hl.dsp.exec_cmd(powermenu_cmd))  -- Power Menu

-- Launch Neovim in a standard, tiled window
hl.bind(MOD .. " + n",      hl.dsp.exec_cmd(terminal .. " -e nvim")) 

-- =============================================================================
-- [2] SCRIPTS LEADER CHORD (SUPER + s)
-- Triggers Mako HUD menu via sp.sh, then awaits single action key
-- =============================================================================
hl.bind(MOD .. " + s", function()
    hl.dispatch(hl.dsp.submap("scripts_leader"))
    hl.dispatch(hl.dsp.exec_cmd(sp_cmd))
end)

hl.define_submap("scripts_leader", function()
    local script_actions = {
        ["f"] = sp_cmd .. " f",
        ["a"] = sp_cmd .. " a",
        ["s"] = sp_cmd .. " s",
        ["n"] = sp_cmd .. " n",
        ["m"] = sp_cmd .. " m",
    }
    for key, command in pairs(script_actions) do
        hl.bind(key, chord(command))
    end

    -- Cancel with Escape
    hl.bind("escape", function()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.dispatch(hl.dsp.exec_cmd("makoctl dismiss -a"))
    end)
end)

-- =============================================================================
-- [3] SECONDARY TOOLS & TUIs LEADER CHORD (SUPER + p)
-- =============================================================================
hl.bind(MOD .. " + p", hl.dsp.submap("programs_leader"))

hl.define_submap("programs_leader", function()
    local program_actions = {
        -- Floating TUIs (class flag -a matched in rules.lua)
        ["m"] = terminal .. " -a kew_floating -T 'kew' -e kew",
        ["n"] = terminal .. " -a nmtui_floating nmtui",
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

