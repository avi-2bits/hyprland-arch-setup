-- ~/.config/hypr/conf/keybinds.lua

local opacity = require("conf.opacity")

-- GAP SETTINGS
local GAP_STEP = 2
local MIN_GAP = 0
local MAX_GAP = 30
local inner_gap, outer_gap = 5, 12

local function set_gaps(inner, outer)
    inner_gap = math.max(MIN_GAP, math.min(MAX_GAP, inner))
    outer_gap = math.max(MIN_GAP, math.min(MAX_GAP, outer))

    hl.config({
        general = {
            gaps_in = inner_gap,
            gaps_out = outer_gap,
        }
    })
end

-- SMART NAVIGATION
local function smart_nav(dir, dx, dy)
    return function()
        local win = hl.get_active_window()
        if win and win.floating then
            hl.dispatch(hl.dsp.window.move({ x = dx, y = dy, relative = true }))
        else
            hl.dispatch(hl.dsp.focus({ direction = dir }))
        end
    end
end

-- WINDOW NAVIGATION & SWAPPING
local directions = {
    ["h"] = { dir = "l", dx = -30, dy = 0 },
    ["l"] = { dir = "r", dx = 30, dy = 0 },
    ["k"] = { dir = "u", dx = 0, dy = -30 },
    ["j"] = { dir = "d", dx = 0, dy = 30 },
    ["Left"]  = { dir = "l", dx = -30, dy = 0 },
    ["Right"] = { dir = "r", dx = 30, dy = 0 },
    ["Up"]    = { dir = "u", dx = 0, dy = -30 },
    ["Down"]  = { dir = "d", dx = 0, dy = 30 },
}

for key, d in pairs(directions) do
    hl.bind(MOD .. " + " .. key, smart_nav(d.dir, d.dx, d.dy), { repeating = true })
    hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = d.dir }))
end

hl.bind("ALT + Tab", hl.dsp.window.cycle_next({}))
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))
hl.bind(MOD .. " + a", hl.dsp.focus({ window = "floating" }))

-- WINDOW ACTIONS
hl.bind(MOD .. " + q", hl.dsp.window.close())
hl.bind(MOD .. " + f", hl.dsp.window.fullscreen({ action = "toggle", mode = 0 }))
hl.bind(MOD .. " + SHIFT + f", hl.dsp.window.fullscreen({ action = "toggle", mode = 1 }))
hl.bind(MOD .. " + g", hl.dsp.window.pin())
hl.bind(MOD .. " + v", hl.dsp.layout("togglegroup"))
hl.bind(MOD .. " + backslash", hl.dsp.layout("togglesplit"))

-- WORKSPACES
for i = 1, 9 do
    local key = tostring(i)
    hl.bind(MOD .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(MOD .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind("CTRL + Left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + Right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(MOD .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(MOD .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(MOD .. " + z", hl.dsp.workspace.toggle_special("magic"))
hl.bind(MOD .. " + SHIFT + z", hl.dsp.window.move({ workspace = "special:magic" }))

-- RESIZE MODE (SUPER + R)
hl.bind(MOD .. " + r", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    local resize_deltas = {
        ["h"] = { x = -40, y = 0 },
        ["l"] = { x = 40, y = 0 },
        ["k"] = { x = 0, y = -40 },
        ["j"] = { x = 0, y = 40 },
        ["left"] = { x = -40, y = 0 },
        ["right"] = { x = 40, y = 0 },
        ["up"] = { x = 0, y = -40 },
        ["down"] = { x = 0, y = 40 },
    }

    local move_deltas = {
        ["h"] = { x = -30, y = 0 },
        ["l"] = { x = 30, y = 0 },
        ["k"] = { x = 0, y = -30 },
        ["j"] = { x = 0, y = 30 },
        ["left"] = { x = -30, y = 0 },
        ["right"] = { x = 30, y = 0 },
        ["up"] = { x = 0, y = -30 },
        ["down"] = { x = 0, y = 30 },
    }

    for key, d in pairs(resize_deltas) do
        hl.bind(key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }), { repeating = true })
    end

    for key, d in pairs(move_deltas) do
        hl.bind(MOD .. " + " .. key, hl.dsp.window.move({ x = d.x, y = d.y, relative = true }), { repeating = true })
    end

    -- GAP ADJUSTMENT (INNER + OUTER)
    hl.bind("equal", function()
        set_gaps(inner_gap + GAP_STEP, outer_gap + GAP_STEP)
    end)

    hl.bind("minus", function()
        set_gaps(inner_gap - GAP_STEP, outer_gap - GAP_STEP)
    end)

    hl.bind("BackSpace", function()
        set_gaps(5, 12)
    end)

    hl.bind("c", hl.dsp.window.center())
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- MOUSE CONTROLS
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- AUDIO
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- BACKLIGHT
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeat_key = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeat_key = true })

-- WINDOW OPACITY
hl.bind(MOD .. " + bracketright", function()
    opacity.increase()
end)

hl.bind(MOD .. " + bracketleft", function()
    opacity.decrease()
end)

-- MINIMIZE / RESTORE (SUPER + M)
hl.bind(MOD .. " + m", function()
    if hl.get_workspace("special:minimized") then
        hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
        hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
    else
        local win = hl.get_active_window()
        if win then
            hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = win }))
            hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
        end
    end
end)
