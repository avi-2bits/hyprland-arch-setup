
local M = {}

local bg = "{{colors.background.default.hex}}"

-- Determine theme type from the generated background.
local function get_theme_type(hex)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  local brightness = 0.2126 * r + 0.7152 * g + 0.0722 * b

  return brightness > 127.5 and "light" or "dark"
end

-- NvChad UI palette
M.base_30 = {
  white = "{{colors.on_surface.default.hex}}",
  black = bg,
  darker_black = "{{colors.surface_container_lowest.default.hex}}",
  black2 = "{{colors.surface_container_low.default.hex}}",
  one_bg = "{{colors.surface_container.default.hex}}",
  one_bg2 = "{{colors.surface_container_high.default.hex}}",
  one_bg3 = "{{colors.surface_container_highest.default.hex}}",

  grey = "{{colors.outline_variant.default.hex}}",
  grey_fg = "{{colors.outline.default.hex}}",
  grey_fg2 = "{{colors.on_surface_variant.default.hex}}",
  light_grey = "{{colors.on_surface.default.hex}}",

  red = "{{colors.error.default.hex}}",
  baby_pink = "{{colors.tertiary.default.hex}}",
  pink = "{{colors.secondary.default.hex}}",

  line = "{{colors.outline_variant.default.hex}}",

  green = "{{colors.tertiary.default.hex}}",
  vibrant_green = "{{colors.primary.default.hex}}",

  nord_blue = "{{colors.secondary.default.hex}}",
  blue = "{{colors.primary.default.hex}}",
  seablue = "{{colors.secondary.default.hex}}",

  yellow = "{{colors.tertiary.default.hex}}",
  sun = "{{colors.tertiary_container.default.hex}}",

  purple = "{{colors.secondary.default.hex}}",
  dark_purple = "{{colors.secondary_container.default.hex}}",

  teal = "{{colors.tertiary.default.hex}}",
  orange = "{{colors.tertiary_container.default.hex}}",
  cyan = "{{colors.secondary.default.hex}}",

  statusline_bg = "{{colors.surface_container.default.hex}}",
  lightbg = "{{colors.surface_container_high.default.hex}}",
  pmenu_bg = "{{colors.primary_container.default.hex}}",
  folder_bg = "{{colors.secondary.default.hex}}",
}

-- Base16 syntax palette
M.base_16 = {
  base00 = bg,
  base01 = "{{colors.surface_container_low.default.hex}}",
  base02 = "{{colors.surface_container.default.hex}}",
  base03 = "{{colors.surface_container_high.default.hex}}",
  base04 = "{{colors.outline.default.hex}}",
  base05 = "{{colors.on_surface.default.hex}}",
  base06 = "{{colors.on_background.default.hex}}",
  base07 = "{{colors.on_surface.default.hex}}",

  base08 = "{{colors.error.default.hex}}",
  base09 = "{{colors.tertiary.default.hex}}",
  base0A = "{{colors.tertiary_container.default.hex}}",
  base0B = "{{colors.tertiary.default.hex}}",
  base0C = "{{colors.secondary.default.hex}}",
  base0D = "{{colors.primary.default.hex}}",
  base0E = "{{colors.secondary.default.hex}}",
  base0F = "{{colors.error_container.default.hex}}",
}

M.type = get_theme_type(bg)

M = require("base46").override_theme(M, "matugen")

return M

