-- 1. Make sure Lazy is bootstrapped (needed for the code to run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Setup Lazy with your plugins
require("lazy").setup({
     {
	  "nvim-treesitter/nvim-treesitter",
	  build = ":TSUpdate",
	  opts = {
	    ensure_installed = {
	      "lua",
	      "vim",
	      "vimdoc",
	      "yaml",            -- <--- Add this
	      "markdown",        -- <--- Highly recommended for CodeCompanion
	      "markdown_inline", -- <--- Highly recommended for CodeCompanion
	    },
	    highlight = { enable = true },
	  },
	  config = function()
             require("nvim-treesitter.configs").setup({
             ensure_installed = { "python", "lua", "vim", "markdown" },
             highlight = { enable = true },
             indent = { enable = true }, -- Better Python indentation
              })
           end,
    },
    {
      "olimorris/codecompanion.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
         "nvim-telescope/telescope.nvim", -- Optional: For using the action palette
      },
      config = function()
        require("codecompanion").setup({
          strategies = {
            -- Change "openai" to "anthropic", "ollama", etc. if needed
	    chat = { adapter = "ollama" },
            inline = { 
	            adapter = "ollama",
		    keymaps = {
		    -- Map "Accept Change" to something easy, like 'ga' (Go Accept)
		    accept_change = {
		      modes = { n = "ga" },
		      description = "Accept the inline change",
		    },
		    -- Map "Reject Change" to 'gr' (Go Reject)
		    reject_change = {
		      modes = { n = "gr" },
		      description = "Reject the inline change",
			},
		      },
            },
	    agent = { adapter = "ollama" },
          },
	  opts = {
             log_level = "DEBUG", -- or "TRACE"
	     stream = false
          },
	  adapters = {
            ollama = function()
              return require("codecompanion.adapters.http").extend("ollama", {
            schema = {
              model = {
                -- MAKE SURE THIS MATCHES THE MODEL YOU PULLED (e.g., "llama3", "deepseek-coder:v2")
                default = "qwen3-coder:30b", 
              },
            },
          })
        end,
          },
        })
      end,
    },
    -- LSP & Autocomplete (Pyright)
    {
  -- Main LSP Configuration
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",          -- Manages external tools (LSP servers, formatters)
    "williamboman/mason-lspconfig.nvim", -- Bridges Mason and lspconfig
    "hrsh7th/nvim-cmp",                 -- Autocomplete Engine
    "hrsh7th/cmp-nvim-lsp",             -- LSP source for nvim-cmp
    'neovim/nvim-lspconfig',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "pyright" }, -- Automatically install Python LSP
    })

	-- 1. Set up nvim-cmp (The Autocompletion Engine)
	local cmp = require('cmp')
	local luasnip = require('luasnip')

	cmp.setup({
	  -- Snippet Engine (REQUIRED by nvim-cmp)
	  snippet = {
	    expand = function(args)
	      luasnip.lsp_expand(args.body)
	    end,
	  },
	  
	  -- Keyboard Mappings
	  mapping = cmp.mapping.preset.insert({
	    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
	    ['<C-f>'] = cmp.mapping.scroll_docs(4),
	    ['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
	    ['<C-e>'] = cmp.mapping.abort(),
	    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
	  }),

	  -- Where to get suggestions from
	  sources = cmp.config.sources({
	    { name = 'nvim_lsp' }, -- Suggestions from LSP (Pyright)
	    { name = 'luasnip' },  -- Suggestions from Snippets
	  }, {
	    { name = 'buffer' },   -- Suggestions from text in current file
	  })
	})

    -- Connect Pyright to Neovim
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 3. Setup Mason and LSP (Updated for Neovim 0.11)
-- Apply the capabilities to Pyright
    vim.lsp.config("pyright", {
	      capabilities = capabilities,
	      root_dir =  vim.fn.getcwd(),
              settings = {
                python = {
                   analysis = {
                    typeCheckingMode = "basic", -- Options: off, basic, strict
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
		    diagnosticMode = "workspace",
		    -- If you have a specific folder where modules live, add it here
                    extraPaths = { "./src", "./lib" }, 
                   },
                },
           },
      })

-- Enable Pyright
    vim.lsp.enable("pyright")
 end,
     },
     {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- Load when writing a file
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      -- Run isort first (organize imports), then black (format code)
      python = { "isort", "black" }, 
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
},
'tpope/vim-fugitive',

})

vim.opt.number = true

vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x'
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})
