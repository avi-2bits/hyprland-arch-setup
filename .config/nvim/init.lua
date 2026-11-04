-- Sync Foot background with Neovim
local function sync_terminal_background()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })

  if not normal.bg then
    return
  end

  io.stdout:write(string.format("\027]11;#%06x\027\\", normal.bg))
  io.stdout:flush()
end

local function reset_terminal_background()
  io.stdout:write("\027]111\027\\")
  io.stdout:flush()
end

local group = vim.api.nvim_create_augroup("FootBackgroundSync", {
  clear = true,
})

vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
  group = group,
  callback = sync_terminal_background,
})

vim.api.nvim_create_autocmd({ "VimLeavePre", "UILeave" }, {
  group = group,
  callback = reset_terminal_background,
})

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Simple command to auto-align and clean markdown tables
vim.api.nvim_create_user_command("FormatTable", function()
  -- If you have a command-line tool like 'column', it can format it instantly
  vim.cmd("'<,'>!column -t -s '|' -o '|'")
end, { range = true })

