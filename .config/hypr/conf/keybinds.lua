-- ~/.config/hypr/conf/keybinds.lua
-- Core Window Management, Navigation, Resizing, & Hardware Controls
-- =============================================================================

-- [1] CONTEXT-AWARE SMART NAVIGATION HELPER
-- =============================================================================
-- Focuses tiled grid or moves floating windows (30px step)
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

-- =============================================================================
-- [2] WINDOW NAVIGATION & SWAPPING (Vim Keys + Arrows)
-- =============================================================================
local directions = {
    -- Vim Keys
    ["h"]     = { dir = "l", dx = -30, dy =   0 },
    ["l"]     = { dir = "r", dx =  30, dy =   0 },
    ["k"]     = { dir = "u", dx =   0, dy = -30 },
    ["j"]     = { dir = "d", dx =   0, dy =  30 },
    -- Arrow Keys
    ["Left"]  = { dir = "l", dx = -30, dy =   0 },
    ["Right"] = { dir = "r", dx =  30, dy =   0 },
    ["Up"]    = { dir = "u", dx =   0, dy = -30 },
    ["Down"]  = { dir = "d", dx =   0, dy =  30 },
}

for key, d in pairs(directions) do
    -- Smart directional navigation (hold to move/focus continuously)
    hl.bind(MOD .. " + " .. key, smart_nav(d.dir, d.dx, d.dy), { repeating = true })
    -- Swap windows in tiled layout
    hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = d.dir }))
end

-- Universal Window Cycling (Tiled & Floating)
hl.bind("ALT + Tab",         hl.dsp.window.cycle_next({}))
hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))

-- Jump Focus Directly to Floating Layer
hl.bind(MOD .. " + a", hl.dsp.focus({ window = "floating" }))

-- =============================================================================
-- [3] WINDOW ACTIONS & LAYOUT CONTROLS
-- =============================================================================
hl.bind(MOD .. " + q",         hl.dsp.window.close())
hl.bind(MOD .. " + f",         hl.dsp.window.fullscreen({ action = "toggle", mode = 0 }))
hl.bind(MOD .. " + SHIFT + f", hl.dsp.window.fullscreen({ action = "toggle", mode = 1 }))
hl.bind(MOD .. " + g",         hl.dsp.window.pin())
hl.bind(MOD .. " + v",         hl.dsp.layout("togglegroup"))
hl.bind(MOD .. " + backslash", hl.dsp.layout("togglesplit"))

-- =============================================================================
-- [4] WORKSPACE MANAGEMENT
-- =============================================================================
-- Direct Workspace Access & Window Shifting (1-9)
for i = 1, 9 do
    local key = tostring(i)
    hl.bind(MOD .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(MOD .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace Navigation Triggers
hl.bind(MOD .. " + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind("CTRL + Left",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + Right",  hl.dsp.focus({ workspace = "e+1" }))

-- Relative Mouse Wheel Workspace Scrolling
hl.bind(MOD .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(MOD .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad / Special Workspace
hl.bind(MOD .. " + z",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(MOD .. " + SHIFT + z", hl.dsp.window.move({ workspace = "special:magic" }))

-- =============================================================================
-- [5] MODAL RESIZE & MOVE SUBMAP (SUPER + r)
-- =============================================================================
hl.bind(MOD .. " + r", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local resize_deltas = {
        ["h"]     = { x = -40, y =   0 },
        ["l"]     = { x =  40, y =   0 },
        ["k"]     = { x =   0, y = -40 },
        ["j"]     = { x =   0, y =  40 },
        ["left"]  = { x = -40, y =   0 },
        ["right"] = { x =  40, y =   0 },
        ["up"]    = { x =   0, y = -40 },
        ["down"]  = { x =   0, y =  40 },
    }
    local move_deltas = {
        ["h"]     = { x = -30, y =   0 },
        ["l"]     = { x =  30, y =   0 },
        ["k"]     = { x =   0, y = -30 },
        ["j"]     = { x =   0, y =  30 },
        ["left"]  = { x = -30, y =   0 },
        ["right"] = { x =  30, y =   0 },
        ["up"]    = { x =   0, y = -30 },
        ["down"] = { x =   0, y =  30 },
    }

    -- Resize windows (HJKL & Arrows, 40px step)
    for key, d in pairs(resize_deltas) do
        hl.bind(key, hl.dsp.window.resize({ x = d.x, y = d.y, relative = true }), { repeating = true })
    end

    -- Move floating windows within submap (MOD + HJKL & MOD + Arrows, 30px step)
    for key, d in pairs(move_deltas) do
        hl.bind(MOD .. " + " .. key, hl.dsp.window.move({ x = d.x, y = d.y, relative = true }), { repeating = true })
    end

    -- Utilities and Exit
    hl.bind("c",      hl.dsp.window.center())
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- =============================================================================
-- [6] MOUSE BINDINGS & HARDWARE CONTROLS
-- =============================================================================
-- Mouse Dragging & Resizing
hl.bind(MOD .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(MOD .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio Controls (WirePlumber)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- Backlight Controls
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeat_key = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeat_key = true })

-- =============================================================================
-- [7] WINDOW MINIMIZE / RESTORE TOGGLE (MOD + m)
-- =============================================================================
-- Native 1-window minimize toggle. Preserves floating geometry and tiling state.
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

