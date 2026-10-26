-- ==========================================================================
--                  NVCHAD CORE & SYSTEMS KEYMAPS
-- ==========================================================================

require "nvchad.mappings"

local map = vim.keymap.set

-- Standard Quality-of-Life Mappings
map("n", ";", ":", { desc = "CMD Enter command mode" })
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Tree" })

-- Better Centered Window Navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
map("n", "n", "nzzzv", { desc = "Next search match and center" })
map("n", "N", "Nzzzv", { desc = "Prev search match and center" })

-- Terminal Mode: Easy Escape to Normal Mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })

-- ==========================================================================
-- 📄 DEDICATED BUFFER NAVIGATION (Safe from Tab/Checkbox conflicts)
-- ==========================================================================
-- Switch NvChad buffer tabs using Shift+H and Shift+L
map("n", "L", function() require("nvchad.tabufline").next() end, { desc = "Buffer Next Note" })
map("n", "H", function() require("nvchad.tabufline").prev() end, { desc = "Buffer Prev Note" })

-- Close/Kill current note buffer without breaking your leader+x checkbox mapping
map("n", "<leader>bk", function() require("nvchad.tabufline").close_buffer() end, { desc = "Buffer Kill/Close Note" })

-- ==========================================================================
-- 🎨 OBSIDIAN / ORG-MODE CLEAN FOLD RENDERER (NO CLIPPING, PERFECT PADDING)
-- ==========================================================================

_G.OrgFoldText = function()
  local line = vim.fn.getline(vim.v.foldstart)
  
  -- 1. Strip virtual whitespace
  local clean_line = line:gsub("^%s*", "")
  
  -- 2. Match headings and extract exact title text
  local level, title = clean_line:match("^(#+)%s+(.*)$")
  
  if level and title then
    local icons = { 
      "󰫢 ", -- H1
      "󰫣 ", -- H2
      "󰫤 ", -- H3
      "󰫥 ", -- H4
      "✦  ", -- H5 (Aligned)
      "✧  ", -- H6 (Aligned)
    }
    
    local icon = icons[#level] or "•  "
    local clean_title = title:gsub("%s*$", "")
    
    return "  " .. icon .. " " .. clean_title .. "  ··· "
  end
  
  -- Fallback for non-heading folds
  return "  " .. clean_line:gsub("%s*$", "") .. "  ··· "
end

-- ==========================================================================
-- 🌲 MARKDOWN & FOLDING UTILITIES (TRUE EMACS / ORG-MODE STYLE)
-- ==========================================================================

-- 1. Helper function to compute heading fold levels (ignores C #include/macros)
_G.MarkdownHeadingLevel = function(lnum)
  local line = vim.fn.getline(lnum)
  -- Require space after '#' to prevent matching #include or Python comments
  local heading = line:match("^(#+)%s+")
  if heading then
    return ">" .. #heading
  end
  return "="
end

-- ==========================================================================
-- Org-Mode Checkbox Toggle Logic
-- ==========================================================================

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local unchecked_pat = "^(%s*[%-%*]%s*)%[%s*%](.*)$"
  local checked_pat   = "^(%s*[%-%*]%s*)%[[xX]%](.*)$"
  local plain_list    = "^(%s*[%-%*]%s*)(.*)$"

  if line:match(unchecked_pat) then
    local new_line = (line:gsub(unchecked_pat, "%1[x]%2", 1))
    vim.api.nvim_set_current_line(new_line)
  elseif line:match(checked_pat) then
    local new_line = (line:gsub(checked_pat, "%1[ ]%2", 1))
    vim.api.nvim_set_current_line(new_line)
  elseif line:match(plain_list) then
    local new_line = (line:gsub(plain_list, "%1[ ] %2", 1))
    vim.api.nvim_set_current_line(new_line)
  else
    local indent = line:match("^%s*") or ""
    local text = line:gsub("^%s*", "")
    vim.api.nvim_set_current_line(indent .. "- [ ] " .. text)
  end
end

-- 3. Org-Mode Smart Enter (Creates a new checkbox item on the next line)
local function new_checkbox_below()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^(%s*)") or ""
  vim.api.nvim_put({ indent .. "- [ ] " }, "l", true, true)
  vim.cmd("startinsert!")
end

-- 4. Markdown FileType Autocommands & Controls
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local buf_map = function(mode, lhs, rhs, desc)
      map(mode, lhs, rhs, { buffer = true, silent = true, desc = desc })
    end

    -- Folding Engine Setup
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.MarkdownHeadingLevel(v:lnum)"
    vim.opt_local.foldtext = "v:lua.OrgFoldText()"
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldenable = true

    -- Conceal formatting characters for clean buffer aesthetic
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nv" -- 'i' keeps headings rendered while typing

    -- Disable indent-blankline vertical pipes in markdown buffers
    local ok_ibl, ibl = pcall(require, "ibl")
    if ok_ibl then
      ibl.setup_buffer(0, { enabled = false })
    end

    -- 📂 Emacs <Tab> Heading Folding (za on headers, standard fallback elsewhere)
    map("n", "<Tab>", function()
      if vim.fn.getline("."):match("^#+%s+") then
        return "za"
      end
      return vim.api.nvim_replace_termcodes("<C-i>", true, true, true)
    end, { expr = true, buffer = true, desc = "Emacs Tab Fold / Jump" })

    -- 🔄 Emacs <S-Tab> Global Fold Cycling (Cycle between all open / all closed)
    buf_map("n", "<S-Tab>", function()
      if vim.opt_local.foldlevel:get() == 0 then
        vim.opt_local.foldlevel = 99
      else
        vim.opt_local.foldlevel = 0
      end
    end, "Cycle Global Folds")

    -- 📋 Org-Mode Action Keys
    buf_map("n", "<C-c><C-c>", toggle_checkbox, "Toggle Todo Checkbox (Org-Style)")
    buf_map("n", "<leader>x",   toggle_checkbox, "Toggle Todo Checkbox")
    buf_map("n", "<A-CR>",     new_checkbox_below, "Insert new checkbox below")
    buf_map("i", "<A-CR>",     function()
      vim.cmd("stopinsert")
      new_checkbox_below()
    end, "Insert new checkbox below")

    -- 🔤 Emacs Fast Headings (Insert mode or Normal mode)
    buf_map("n", "<A-1>", "I# <Esc>A",   "Convert to H1")
    buf_map("n", "<A-2>", "I## <Esc>A",  "Convert to H2")
    buf_map("n", "<A-3>", "I### <Esc>A", "Convert to H3")

    -- ✨ Visual Surround Wrappers (Highlight text, then trigger)
    buf_map("v", "<leader>b", 'c**<C-r>"**<Esc>', "Wrap Bold")
    buf_map("v", "<leader>i", 'c*<C-r>"*<Esc>',   "Wrap Italic")
    buf_map("v", "<leader>c", 'c`<C-r>"`<Esc>',   "Wrap Inline Code")
    buf_map("v", "<leader>k", 'c~~<C-r>"~~<Esc>', "Wrap Strikethrough")
    buf_map("v", "<leader>w", 'c[[<C-r>"]][[<Esc>', "Wrap in WikiLink") -- FAST WIKILINK WRAPPER

    -- 🎨 Toggle Render Markdown Plugin
    buf_map("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", "Toggle Markdown Rendering")

    -- 📝 Table of Contents Generator
    buf_map("n", "<leader>mc", "<cmd>GenTocGFM<CR>", "Generate Table of Contents")

    -- ==========================================================================
    -- 🔗 OBSIDIAN-STYLE LINK NAVIGATION
    -- ==========================================================================
    vim.opt_local.suffixesadd:append(".md")
    vim.opt_local.isfname:append("[")
    vim.opt_local.isfname:append("]")
    vim.opt_local.isfname:append("@-@")

    local function resolve_link_path(target)
      local filename = target:match("%.md$") and target or (target .. ".md")
      local note_dir = vim.fn.expand("%:p:h")
      local candidate_in_note_dir = note_dir .. "/" .. filename
      if vim.fn.filereadable(candidate_in_note_dir) == 1 then
        return candidate_in_note_dir
      end
      if vim.fn.filereadable(filename) == 1 then
        return filename
      end
      return candidate_in_note_dir
    end

    -- Hitting <CR> on a link opens it instantly
    buf_map("n", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local md_link = line:match("%b[]%b()")
      local wiki_target = line:match("%[%[(.-)%]%]")
      
      if wiki_target then
        local clean = wiki_target:gsub("^%s*", ""):gsub("%s*$", "")
        local final_path = resolve_link_path(clean)
        vim.cmd("edit " .. vim.fn.fnameescape(final_path))
      elseif md_link then
        local raw_path = md_link:match("%((.-)%)")
        local clean = raw_path:gsub("^%s*", ""):gsub("%s*$", "")
        local final_path = resolve_link_path(clean)
        vim.cmd("edit " .. vim.fn.fnameescape(final_path))
      else
        local ok, _ = pcall(vim.cmd, "normal! gf")
        if not ok then
          vim.notify("No valid link or file path under cursor.", vim.log.levels.WARN)
        end
      end
    end, "Follow Markdown Link / Open File")
    
    -- Trigger render-markdown safely on buffer open
    vim.schedule(function()
      pcall(vim.cmd, "RenderMarkdown enable")
    end)
  end,
})

-- ==========================================================================
-- 📝 INTEGRATION WITH YOUR PERSONAL PYTHON TODO ENGINE
-- ==========================================================================
map("n", "<leader>td", function()
  vim.cmd("silent update")
  vim.cmd("split | resize 15 | terminal ~/.config/scripts/todo/todo.py")
  vim.cmd("startinsert")
end, { desc = "Launch Today's Workspace" })

map("n", "<leader>ts", function()
  vim.cmd("edit ~/.config/scripts/todo/Schedule.md")
end, { desc = "Edit Schedule Template" })

map("n", "<leader>tl", function()
  vim.cmd("edit ~/.config/scripts/todo/todo.md")
end, { desc = "Edit Master Work Backlog" })

-- ==========================================================================
-- 📚 DIRECT-JUMP HOTKEYS TO YOUR 4 SUBJECT NOTEBOOKS
-- ==========================================================================
map("n", "<leader>lac", "<cmd>edit ~/.config/scripts/todo/LAC.md<CR>", { desc = "Jump to Linear Algebra" })
map("n", "<leader>iwt", "<cmd>edit ~/.config/scripts/todo/IWT.md<CR>", { desc = "Jump to Internet Tech" })
map("n", "<leader>fcs", "<cmd>edit ~/.config/scripts/todo/FCS.md<CR>", { desc = "Jump to Comp Sci" })
map("n", "<leader>spc", "<cmd>edit ~/.config/scripts/todo/SPC.md<CR>", { desc = "Jump to System Prog" })

-- ==========================================================================
-- ⚡ LIGHTNING-FAST CSE COMPILER & EXECUTION ENGINE
-- ==========================================================================
map("n", "<leader>ex", function()
  vim.cmd("silent update")
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local file_no_ext = vim.fn.expand("%:r")
  local command

  if filetype == "c" then
    command = string.format(
      "gcc -Wall -Wextra -O2 -std=c11 %s -o %s -lm && ./%s",
      filename, file_no_ext, file_no_ext
    )
  elseif filetype == "cpp" then
    command = string.format(
      "g++ -Wall -Wextra -O2 -std=c++17 %s -o %s -lm && ./%s",
      filename, file_no_ext, file_no_ext
    )
  elseif filetype == "python" then
    command = string.format("python3 %s", filename)
  elseif filetype == "sh" then
    command = string.format("bash %s", filename)
  else
    vim.notify("No execution profile configured for: " .. filetype, vim.log.levels.WARN)
    return
  end

  vim.cmd("split | resize 12 | terminal " .. command)
  vim.cmd("startinsert")
end, { desc = "Auto-save, Compile & Run active file" })

map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Search Todo Comments" })

-- Transparent background blend for folded lines (Removes ugly default high-contrast bars)
vim.api.nvim_set_hl(0, "Folded", { bg = "none", fg = "NONE" })

-- Locks checkbox highlights to transparent backgrounds so they never flash raw text
vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { bg = "none", fg = "#8ec07c" }) -- Beautiful Gruvbox Green
vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { bg = "none", fg = "#928374" })   -- Soft Muted Grey

