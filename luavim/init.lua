local M = {}

M.ybbond_lsp_on_attach = function(client, bufnr)
	local function buf_set_keymap(l, r, c)
		vim.api.nvim_buf_set_keymap(bufnr, l, r, c, { noremap = true, silent = true })
	end
	buf_set_keymap("n", "gd", "<CMD>lua vim.lsp.buf.definition()<CR>")
	buf_set_keymap("n", "gD", "<CMD>lua vim.lsp.buf.declaration()<CR>")
	buf_set_keymap("n", "g<A-d>", "<CMD>lua vim.lsp.buf.type_definition()<CR>")
	buf_set_keymap("n", "gh", "<CMD>lua vim.lsp.buf.hover()<CR>")
	buf_set_keymap("n", "gH", "<CMD>lua vim.diagnostic.open_float()<CR>")
	buf_set_keymap("n", "gi", "<CMD>lua vim.lsp.buf.implementation()<CR>")
	buf_set_keymap("n", "gs", "<CMD>lua vim.lsp.buf.signature_help()<CR>")
	buf_set_keymap("n", "ga", "<CMD>lua vim.lsp.buf.code_action()<CR>")
	-- buf_set_keymap('n', 'ga', '<CMD>Telescope lsp_code_actions theme=cursor layout_config={height=15}<CR>')
	buf_set_keymap("n", "gr", "<CMD>lua vim.lsp.buf.references()<CR>")
	buf_set_keymap("n", "[d", "<CMD>lua vim.diagnostic.goto_prev()<CR>")
	buf_set_keymap("n", "]d", "<CMD>lua vim.diagnostic.goto_next()<CR>")
	-- buf_set_keymap('n', '<LEADER>f', '<CMD>lua vim.lsp.buf.formatting()<CR>')
	-- buf_set_keymap('n', '<LEADER>f', [[<CMD>lua require('format-on-save').format()<CR><CMD>lua require('format-on-save').restore_cursors()<CR>]])
	buf_set_keymap("n", "<LEADER>f", "<CMD>Format<CR>")
end

-- 1. Make sure Lazy is bootstrapped (needed for the code to run)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
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
				"yaml", -- <--- Add this
				"markdown", -- <--- Highly recommended for CodeCompanion
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
					stream = false,
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
			"williamboman/mason.nvim", -- Manages external tools (LSP servers, formatters)
			"williamboman/mason-lspconfig.nvim", -- Bridges Mason and lspconfig
			"hrsh7th/nvim-cmp", -- Autocomplete Engine
			"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
			"neovim/nvim-lspconfig",
			"L3MON4D3/LuaSnip",
			"b0o/schemastore.nvim",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright" }, -- Automatically install Python LSP
			})

			-- 1. Set up nvim-cmp (The Autocompletion Engine)
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				-- Snippet Engine (REQUIRED by nvim-cmp)
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- Keyboard Mappings
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(), -- Manually trigger completion
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
				}),

				-- Where to get suggestions from
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- Suggestions from LSP (Pyright)
					{ name = "luasnip" }, -- Suggestions from Snippets
				}, {
					{ name = "buffer" }, -- Suggestions from text in current file
				}),
			})

			-- Connect Pyright to Neovim
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- 3. Setup Mason and LSP (Updated for Neovim 0.11)
			-- Enable Pyright
			vim.lsp.enable("pyright")
			-- Apply the capabilities to Pyright
			vim.lsp.config("pyright", {
				capabilities = capabilities,
				root_dir = vim.fn.getcwd(),
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

			-- lua/config/lsp.lua or similar
			vim.lsp.config("bashls", {
				cmd = { "bash-language-server", "start" },
				filetypes = { "bash", "sh" },
				-- Optional: Add on_attach function for keymaps or other buffer-local setup
				on_attach = function(client, bufnr)
					-- Keymaps can go here (e.g., vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {buffer=bufnr}))
				end,
			})

			-- Enable the config
			vim.lsp.enable("bashls")

			-- Enable Lua
			vim.lsp.enable("lua_ls")
			vim.lsp.config("lua_ls", {
				on_attach = M.ybbond_lsp_on_attach,
				filetypes = { "lua" },
			})

			vim.lsp.enable("jsonls")
			vim.lsp.config("jsonls", {
				on_attach = M.ybbond_lsp_on_attach,
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" }, -- Load when writing a file
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				-- Run isort first (organize imports), then black (format code)
				python = { "isort", "black" },
				bash = { "shfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	"tpope/vim-fugitive",
})

vim.opt.number = true

vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Could be '■', '▎', 'x'
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})
