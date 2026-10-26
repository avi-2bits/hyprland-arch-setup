-- ==========================================================================
-- 🌲 CORE INITIALIZATION FLOW & AUTOMATIONS
-- ==========================================================================

local autocmd = vim.api.nvim_create_autocmd

-- Auto-saving on focus-loss or buffer exit to prevent code loss
autocmd({ "FocusLost", "BufLeave" }, {
  pattern = { "*.py", "*.c", "*.cpp", "*.html", "*.css", "*.md" },
  callback = function()
    if vim.bo.modified and vim.bo.buflisted then
      vim.cmd("silent! write")
    end
  end,
})

-- ==========================================================================
-- 📦 THE LAZY.NVIM PLUGINS LIST (Ultimate "Markdown Pro" Workspace)
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

  -- 3. Tree-sitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "yaml", "bash",
        "html", "css", "c", "cpp", "python",
        "markdown", "markdown_inline",
      },
      highlight = {
        enable = true,
        use_languagetree = true,
      },
    },
  },

  -- 4. 🌐 HTML Auto-Closing Tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- 5. 🚫 GLOBAL INDENT-BLANKLINE OVERRIDE (Hides standard code pipes in prose)
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      exclude = {
        filetypes = { "markdown", "text", "help", "lazy", "mason" },
      },
    },
  },

  -- 6. 🎨 PREMIUM EMACS / OBSIDIAN HYBRID MARKDOWN RENDERER
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      -- Live rendering: Stay rendered in ALL modes (including Insert mode!)
      render_modes = true,
      -- Prevent active line from flashing back to raw markup
      anti_conceal = {
        enabled = false, 
      },
      -- Emacs-Style Indentation
      indent = {
        enabled = true,
        per_level = 2,
        skip_level = 1,
        icon = " ", -- Uses empty space for indentation instead of vertical bars!
      },
      -- Flat, prominent headings (Classic Emacs typographic style with custom padding)
      heading = {
        enabled = true,
        sign = false,
        position = "inline",
        -- Perfectly aligned headers: 1-4 are boxed, 5-6 are majestic fantasy sparkles!
        icons = { "󰫢 ", "󰫣 ", "󰫤 ", "󰫥 ", "✦  ", "✧  " },
        width = "block", -- Shrinks background highlights to the text bounds
        border = false,
        
        -- VISUAL PROMINENCE: Inserts elegant padding around your headings!
        above = " ", -- Inserts virtual empty breathing space above headings!
        below = " ", -- Inserts virtual empty breathing space below headings!
        
        -- Transparent backgrounds so headings blend flatly into your theme background
        backgrounds = {},
        
        -- High-definition typographic heading foreground highlights
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
        },
      },
      -- Doom Emacs Code Blocks (Border-free flat styling)
      code = {
        enabled = true,
        style = "language", -- Hides borders; shows language tags
        position = "left",
        width = "block",
        left_pad = 2,
        right_pad = 0,
        border = "none",
      },
      -- Minimal Inline Code Highlights
      inline_code = {
        enabled = true,
        highlight = "RenderMarkdownCodeInline",
      },
      -- 4. Premium High-Definition Obsidian Square Checkbox Config
      checkbox = {
        enabled = true,
        unchecked = { 
          icon = "[ ]", -- Clean outline square
          highlight = "RenderMarkdownUnchecked" 
        },
        checked = { 
          icon = "[x]", -- Clean checkmark
          highlight = "Comment", 
          scope_highlight = "@markup.strikethrough" -- Draws clean strikethrough line
        },
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },
      link = {
        enabled = true,
        wiki = {
          icon = "> ",
        },
      },
      -- Classic Math Formula Parser (Using text fallback for absolute performance)
      latex = {
        enabled = true,
        highlight = "RenderMarkdownLatex",
      },
    },
  },

  -- 7. 🏷️ TODO-COMMENTS (Highlights todo tags globally inside Neovim)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufRead",
    opts = {
      signs = true, -- Enable search icons in the sign column
      keywords = {
        TODO = { icon = " ", color = "info" },
        FIX  = { icon = " ", color = "error" },
        WARN = { icon = " ", color = "warning" },
        NOTE = { icon = " ", color = "hint" },
      },
    },
  },

  -- 8. 📝 MARKDOWN TABLE OF CONTENTS GENERATOR
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
  },

  -- 9. Mason Tool Installer
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "html-lsp",
        "css-lsp",
        "pyright",
        "clangd",
        "prettier",
        "clang-format",
      },
    },
  },
}

