return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"nanotee/sqls.nvim", -- LSP para SQL
		},
		config = function()
			-- O novo padrão para Neovim 0.11+
			-- 1. Carrega as configurações padrão do gopls fornecidas pelo nvim-lspconfig
			vim.lsp.config('gopls', {
				settings = {
					gopls = {
						-- Define o prefixo dos seus pacotes internos (Bloco 3)
						-- Opcional: ativa gofumpt para uma formatação mais rigorosa
						gofumpt = true,
					},
				},
			})

			-- 2. Ativa o servidor usando a nova API nativa
			vim.lsp.enable('gopls', config)

			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			vim.lsp.config('sqls', {
				cmd = { 'sqls' },
				filetypes = { 'sql', 'mysql', 'psql' },
				capabilities = capabilities,
				settings = {
					sqls = {
						connections = {
							{
								driver = 'postgresql',
								dataSourceName = 'host=localhost port=5432 user=user password=password dbname=offer-eligibility sslmode=disable',
							},
						},
					},
				},
			})
			vim.lsp.enable('sqls')

			-- Opcional: Configurações de UI quando um LSP é anexado
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					-- Seus atalhos de teclado (keymaps) LSP entram aqui
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "sql",
				callback = function()
					vim.opt_local.expandtab = true
					vim.opt_local.shiftwidth = 4
					vim.opt_local.tabstop = 4
				end,
			})
		end,
	},
	{
		"dense-analysis/ale",
		config = function()
			-- Define os linters específicos para SQL
			vim.g.ale_linters = {
				sql = { "sqlfluff" }, -- sqlfluff é o melhor para detectar tipos errados offline
			}

			-- Configuração específica do sqlfluff para Postgres
			vim.g.ale_sql_sqlfluff_executable = "sqlfluff"
			vim.g.ale_sql_sqlfluff_options = "--dialect postgres"

			-- Garante que o ALE não tente usar o LSP como linter (evita duplicados)
			vim.g.ale_disable_lsp = 1

			-- Mostrar erros na lateral e ao salvar
			vim.g.ale_sign_error = "✘"
			vim.g.ale_sign_warning = "⚠"
			vim.g.ale_lint_on_text_changed = "always"
			vim.g.ale_lint_on_insert_leave = 1
		end,
	},
	{
		"hrsh7th/nvim-cmp", -- autocompletar
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- Explicitly use the new branch
		build = ":TSUpdate",
		config = function()
			local ts = require("nvim-treesitter")

			-- 1. Install parsers manually or via a list
			ts.install({ "go", "gomod", "gowork", "gosum", "lua", "vim", "vimdoc", "sql", "markdown" })

			-- 2. Enable highlighting globally using Neovim's core API
			-- In the new 'main' branch, you typically use an autocmd to start TS
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					if pcall(vim.treesitter.start) then
						-- Optional: any buffer-local settings
					end
				end,
			})
		end,
	},
	{
		"ray-x/go.nvim",
		dependencies = {  -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
			"mfussenegger/nvim-dap", 
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
		},
		opts = function()
			require("go").setup(opts)
			local dap = require("dap")
			dap.configurations.go = {
				{ type = "go", name = "Debug App (Main)", request = "launch", program = function() return vim.fn.input( 'Path to main: ', vim.fn.getcwd() .. '/cmd/main.go', 'file' ) end, },
			}
			require("dapui").setup()
			require("dap-go").setup()
			require("nvim-dap-virtual-text").setup()
			local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
			vim.keymap.set('n', '<leader>dc', function() require("dapui").close() end)
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					require('go.format').goimports()
				end,
				group = format_sync_grp,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "go",
				callback = function()
					vim.fn.sign_define('DapBreakpoint', { text='󰠭', texthl='DapBreakpointColor', linehl='DapBreakpointLine', numhl='DapBreakpointLine' })
					vim.fn.sign_define("DapStopped", {text="🖕", texthl="DiagnosticWarn", linehl="DapStoppedLine", numhl="DapStoppedLine"})
					vim.api.nvim_set_hl(0, 'DapBreakpointColor', { fg = '#ff0000' })
					vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = '#ba03fc' })
					vim.api.nvim_set_hl(0, 'DapBreakpointLine', { bg = "#3a2727" })
					vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e3b2e" })
				end,
			})

			vim.keymap.set("n", "<leader>gss", function()
				require("telescope.builtin").lsp_document_symbols({ symbols = { "struct" } })
			end, { desc = "Go Structs" })

			vim.keymap.set("n", "<leader>gsi", function()
				require("telescope.builtin").lsp_document_symbols({ symbols = { "interface" } })
			end, { desc = "Go Interfaces" })

			vim.keymap.set("n", "<leader>gsf", function()
				require("telescope.builtin").lsp_document_symbols({ symbols = { "method", "function" } })
			end, { desc = "Go Functions" })

			return {
				-- lsp_keymaps = false,
				-- other options
			}
		end,
		event = {"CmdlineEnter"},
		ft = {"go", 'gomod'},
		build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- abre/fecha automaticamente
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
		end,
	},
	{
		"maxandron/goplements.nvim", -- visualizar implementações de interfaces
		ft = "go",
		opts = {
			prefix = {
				interface = "implemented by: ",
				struct = "implements: ",
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim", tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			-- Disable entire built-in ftplugin mappings to avoid conflicts.
			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
			vim.g.no_plugin_maps = true

			-- Or, disable per filetype (add as you like)
			-- vim.g.no_python_maps = true
			-- vim.g.no_ruby_maps = true
			-- vim.g.no_rust_maps = true
			-- vim.g.no_go_maps = true
		end,
		config = function()
			-- put your config here
			require("nvim-treesitter-textobjects").setup({
				move = {
					set_jumps = true,
				},
			})

			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
			end)
		end,
	},
	{
		"rmagatti/goto-preview",
		dependencies = { "rmagatti/logger.nvim" },
		event = "BufEnter",
		config = function()
			require('goto-preview').setup()

			vim.keymap.set("n", "<leader>gd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {noremap=true})
			vim.keymap.set("n", "<leader>gD", "<cmd>lua require('goto-preview').close_all_win()<CR>", {noremap=true})
		end, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
	},
}
