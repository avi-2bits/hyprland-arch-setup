-- ~/.config/hypr/conf/opacity.lua
-- Per-window manual opacity controller

local M = {}

-- Configuration
local STEP = 0.1
local MIN_OPACITY = 0.2
local MAX_OPACITY = 1.0

-- Independent opacity state for each window
local opacity_levels = {}

-- Get a unique key for the window
local function get_window_key(win)
    if not win or not win.address then
        return nil
    end

    return tostring(win.address)
end

-- Apply opacity to a specific window
local function apply_opacity(win, opacity)
    local function set(prop, value)
        hl.dispatch(hl.dsp.window.set_prop({
            prop = prop,
            value = tostring(value),
            window = win,
        }))
    end

    -- Enable exact opacity overrides
    set("opacity_override", 1)
    set("opacity_inactive_override", 1)
    set("opacity_fullscreen_override", 1)

    -- Apply the same opacity in every window state
    set("opacity", opacity)
    set("opacity_inactive", opacity)
    set("opacity_fullscreen", opacity)
end

-- Change opacity of the currently focused window
local function change_opacity(direction)
    local win = hl.get_active_window()
    if not win then return end

    local key = get_window_key(win)
    if not key then return end

    local current = opacity_levels[key] or MAX_OPACITY

    local next_opacity = current + direction * STEP

    -- Clamp and avoid floating-point precision errors
    next_opacity = math.floor(next_opacity * 10 + 0.5) / 10
    next_opacity = math.max(
        MIN_OPACITY,
        math.min(MAX_OPACITY, next_opacity)
    )

    opacity_levels[key] = next_opacity

    apply_opacity(win, next_opacity)
end

-- Increase transparency
function M.increase()
    change_opacity(-1)
end

-- Decrease transparency
function M.decrease()
    change_opacity(1)
end

-- Remove stored state after a window is destroyed
hl.on("window.destroy", function(win)
    local key = get_window_key(win)

    if key then
        opacity_levels[key] = nil
    end
end)

return M

