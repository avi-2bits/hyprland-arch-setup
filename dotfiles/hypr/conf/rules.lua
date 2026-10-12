-- ~/.config/hypr/conf/rules.lua
-- Declarative Window Rules, Floating Presets, and Dynamic Tiling Toggles

-- =============================================================================
-- [1] SYSTEM & MEDIA RULES
-- =============================================================================

-- Media Player: Float and prevent display sleep
hl.window_rule({
    match        = { class = "^(mpv)$" },
    float        = true,
    idle_inhibit = "focus",
})

-- Picture-in-Picture: Auto-float and pin across workspaces
hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
})

-- Portal File Pickers & System Prompts
hl.window_rule({
    match  = { class = "^(xdg-desktop-portal-gtk)$" },
    float  = true,
    size   = { 950, 600 },
    center = true,
})

hl.window_rule({
    match  = { class = "^(polkit-kde-authentication-agent-1)$" },
    float  = true,
    center = true,
})

-- =============================================================================
-- [2] FLOATING TUI PRESETS (Spawned via SUPER + p)
-- =============================================================================

-- Music Player (kew) - Floating preset in bottom-right corner
-- Network Manager (nmtui)

hl.window_rule({
    match = { class = "^(kew_floating)$" },
    float = true,
    size  = { 480, 570 },
    move  = { "monitor_w - 480 - 20", "monitor_h - 570 - 50" },
})

hl.window_rule({
    match  = { class = "^(nmtui_floating)$" },
    float  = true,
    size   = { 750, 550 },
    center = true,
})

-- Bluetooth Manager (bluetuith)
hl.window_rule({
    match  = { class = "^(bluetuith_floating)$" },
    float  = true,
    size   = { 750, 500 },
    center = true,
})

-- System Monitor (btop)
hl.window_rule({
    match  = { class = "^(btop_floating)$" },
    float  = true,
    size   = { 1000, 650 },
    center = true,
})

-- =============================================================================
-- [3] DYNAMIC SMART FLOATING TOGGLE (SUPER + t)
-- =============================================================================
hl.bind(MOD .. " + t", function()
    local win = hl.get_active_window()
    if not win then return end

    if not win.floating then
        hl.dispatch(hl.dsp.window.float({ action = "on" }))
        hl.dispatch(hl.dsp.window.resize({ x = 800, y = 550, relative = false }))
        hl.dispatch(hl.dsp.window.center())
    else
        hl.dispatch(hl.dsp.window.float({ action = "off" }))
    end
end)

