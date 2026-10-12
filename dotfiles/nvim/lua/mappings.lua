-- ==========================================================================
--                  NVCHAD CORE & SYSTEMS KEYMAPS
-- ==========================================================================

-- Load default NvChad mappings first
require "nvchad.mappings"

local map = vim.keymap.set

-- Standard Quality-of-Life Mappings
map("n", ";", ":", { desc = "CMD Enter command mode" })
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })

-- 🌳 Overwrite NvChad to make Space+e toggle NvimTree (File Manager)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })


-- ==========================================================================
-- 🌲 MARKDOWN, OBSIDIAN & FOLDING UTILITIES (EMACS/ORG-MODE STYLE)
-- ==========================================================================

-- 1. Helper function to compute heading fold levels
function MarkdownLevel(lnum)
  local line = vim.fn.getline(lnum)
  local heading = line:match("^(#+)")
  if heading then
    return ">" .. #heading -- Folds begin exactly at the heading level (>1, >2, >3)
  end
  return "=" -- Inherit the fold level from the line above
end

-- 2. Markdown FileType Autocommands & Custom Controls
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local buffer_map = function(mode, lhs, rhs, desc)
        map(mode, lhs, rhs, {buffer = true, silent = true, desc = desc })
    end

    -- Enable Custom Expression Folding
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.MarkdownLevel(v:lnum)"
    vim.opt_local.foldlevel = 99 -- Open all headings by default
    vim.opt_local.foldenable = true

    -- 🔍 Conceal markdown symbols for clean reading
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"

    -- 📂 Emacs <Tab> Heading Cycling (za toggle on header, tab everywhere else)
    map("n", "<Tab>", function()
      if vim.fn.getline("."):match("^#+") then
        return "za"
      else
        -- This allows <Tab> to work with autocompletion plugins
        return vim.fn["copilot#Accept"] and vim.fn["copilot#Accept"]() or "<Tab>"
      end
    end, { expr = true, buffer = true, desc = "Emacs Heading Fold Toggle" })

    -- 🔄 Emacs <S-Tab> Global Fold Cycling (Collapses/Expands all notes)
    buffer_map("n", "<S-Tab>", function()
      if vim.opt_local.foldlevel:get() == 0 then
        vim.opt_local.foldlevel = 99
      else
        vim.opt_local.foldlevel = 0
      end
    end, "Cycle Global Folds")

    -- 🧮 Toggle Markdown & LaTeX Equation Rendering
    buffer_map("n", "<leader>tm", function() require("render-markdown").toggle() end, "Toggle Markdown & Math Rendering")

    -- 🗓️ Obsidian Workspace Shortcuts
    buffer_map("n", "<leader>dn", "<cmd>ObsidianToday<CR>", "Open Daily Note")
    buffer_map("n", "<leader>sn", "<cmd>ObsidianSearch<CR>", "Search Notes Vault")
  end,
})

-- ==========================================================================
-- ⚡ LIGHTNING-FAST CSE COMPILER & EXECUTION ENGINE
-- ==========================================================================

-- Automatically detects active buffer type to compile and run files
map("n", "<leader>ex", function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local file_no_ext = vim.fn.expand("%:r")
  local command

  if filetype == "c" then
    command = string.format("gcc -Wall -Wextra -O2 -std=c11 %s -o %s && ./%s", filename, file_no_ext, file_no_ext)
  elseif filetype == "cpp" then
    command = string.format("g++ -Wall -Wextra -O2 -std=c++17 %s -o %s && ./%s", filename, file_no_ext, file_no_ext)
  elseif filetype == "python" then
    command = string.format("python3 %s", filename)
  elseif filetype == "sh" then
    command = string.format("bash %s", filename)
  else
    vim.notify("No native execution script mapped for: " .. filetype, vim.log.levels.WARN)
    return
  end
  -- Execute in a clean floating terminal window
  vim.cmd('split | resize 10 | terminal ' .. command)
end, { desc = "Compile & Run active file" })


