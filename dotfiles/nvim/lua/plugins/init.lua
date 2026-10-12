-- ==========================================================================
-- 🌲 CORE INITIALIZATION FLOW & AUTOMATIONS (Loaded before Plugins)
-- ==========================================================================

local autocmd = vim.api.nvim_create_autocmd

-- Setup Tree-sitter Folding & Conceal options for Markdown
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Enable heading folding
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 99 -- Files open with all headings expanded

    -- 🌟 CRITICAL FIX: Hide markdown & LaTeX markup delimiters (e.g. $, $$, *)
    vim.opt_local.conceallevel = 2 -- 2 = Hide text except for cursor line; 3 = Hide completely
    vim.opt_local.concealcursor = "nc" -- Keep hidden in Normal and Command modes
  end,
})

-- Setup Auto-saving on focus-loss or buffer exit to prevent note loss
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = { "*.md", "*.py", "*.c", "*.cpp" },
  callback = function()
    if vim.bo.modified and vim.bo.buflisted then
      vim.cmd("silent! write")
    end
  end,
})


-- ==========================================================================
-- 📦 THE LAZY.NVIM PLUGINS LIST
-- ==========================================================================

return {

  -- 1. Format-on-save formatting tool (NvChad built-in wrapper)
  {
    "stevearc/conform.nvim",
    opts = require "configs.conform",
  },

  -- 2. LSP Configuration (NvChad built-in configuration)
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- 3. Tree-sitter configuration (Now covers CSE, Math, and Web parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "yaml", "bash",
        -- Web Technologies (Fixes HTML & CSS errors):
        "html", "css",
        -- Academic & Systems Programming:
        "c", "cpp", "python",
        -- Note-taking & Math Equation Support:
        "markdown", "markdown_inline", "latex",
      },
      highlight = {
        enable = true,
        use_languagetree = true,
      },
    },
  },

  -- 4. Markdown Note & Equation Rendering (Slick UI & No Emacs Overhead)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      heading = {
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = " " },
      },
      pipe_table = {
        preset = "round",
        style = "full",
      },
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
      },
      -- 🧮 MATHEMATICAL EQUATIONS RENDERING (ASCII / Unicode)
      latex = {
        enabled = true,
        converter = "latex2text",     -- Converts LaTeX to clean Unicode/ASCII characters via pylatexenc
        highlight = "RenderMarkdownMath",
        position = "above",           -- Displays rendered math above raw LaTeX
      },
      -- 🌲 EMACS ORG-MODE STYLE INDENTED TREE LAYOUT
      indent = {
        enabled = true,               -- Enables progressive hierarchical indentation
        per_level = 2,                -- Indents 2 spaces per heading level
        skip_level = 1,               -- Level 1 (#) stays left-aligned; Level 2+ indents
        skip_heading = false,         -- Indents headers to preserve the visual tree
        icon = "▎",                   -- Tree indicator line
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
    end,
  },

  -- 5. Obsidian note and task manager (Highly optimized)
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = vim.fn.expand "~/vaults/notes",
        },
      },
      daily_notes = {
        folder = "dailies",
        date_format = "%Y-%m-%d",
        alias_format = "%B %d, %Y",
      },
      ui = { enable = false }, -- Let render-markdown manage the buffer visuals
      completion = {
        nvim_lsp = true,
        min_chars = 2,
      },
    },
    config = function(_, opts)
      local path = opts.workspaces.path
      if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
      end
      require("obsidian").setup(opts)
    end,
  },

  -- 6. Aztex.nvim (Direct Unicode Math inside $...$ blocks)
  {
    "seokgukim/aztex.nvim",
    ft = { "markdown", "text" },
    config = function()
      require("aztex").setup({
        inline_enabled = true,
        inline_triggers = { " ", "\t" },
        math_only = true,
        filetypes = { "markdown", "text" },
      })
    end,
  },

    -- Add this inside your plugin return table in plugins/init.lua:
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP Servers
        "html-lsp",           -- Visual Studio Code HTML Language Server [source: 7]
        "css-lsp",            -- CSS Language Server [source: 7]
        "pyright",            -- Python Language Server
        "clangd",             -- C/C++ Language Server
        -- Formatting Tools (for conform.nvim)
        "prettier",           -- HTML/CSS formatter [source: 7]
        "black",              -- Python formatter
      },
    },
  },

}

