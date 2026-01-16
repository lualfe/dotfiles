return {
	{
		'nvim-telescope/telescope.nvim', tag = 'v0.2.1',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
			-- optional but recommended
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		},
		config = function()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
			vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope oldfiles' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Ir para definição" })
			vim.keymap.set("n", "<leader>fc", function() require("telescope").extensions.file_browser.file_browser() end, { desc = "Abrir File Browser" })

			require('telescope').setup{
				pickers = {
					find_files = {
						hidden = true,
						no_ignore = true,
						file_ignore_patterns = { ".git/" },
					},
				},
				extensions = {
					file_browser = {
						hidden = true,
						no_ignore = true,
						file_ignore_patterns = { ".git/" },
					},
					fzf = {
						fuzzy = true,                    -- false will only do exact matching
						override_generic_sorter = true,  -- override the generic sorter
						override_file_sorter = true,     -- override the file sorter
						case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
					},
					file_browser = {
						theme = "dropdown",
						hijack_netrw = true,
					},
				},
			}

			require('telescope').load_extension('file_browser')
			require('telescope').load_extension('fzf')
		end,
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
	},
	{
		'goolord/alpha-nvim',
		config = function ()
			vim.api.nvim_set_hl(0, "AlphaButton", { fg = "#ff5555" })
			-- Dracula theme colors gradient (purple -> pink -> cyan)
			vim.api.nvim_set_hl(0, "GreyComment", { fg = "#6272a4" }) -- comment
			vim.api.nvim_set_hl(0, "Pink_1", { fg = "#ff79c6" }) -- pink

			local alpha = require('alpha')
			local dashboard = require('alpha.themes.dashboard')

			dashboard.section.buttons.val = {
				dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
				dashboard.button( "SPC f f", "󰈞  Find file" , ":Telescope find_files<CR>"),
				dashboard.button( "SPC f c", "󱝩  Browse files" , ":Telescope file_browser<CR>"),
				dashboard.button( "SPC f r", "  Recently opened files" , ":Telescope oldfiles<CR>"),
				dashboard.button( "SPC f g", "󰭷  Text search" , ":Telescope live_grep<CR>"),
				dashboard.button('u', '󱐥  Update plugins', '<cmd>Lazy update<CR>'),
				dashboard.button( "q", "󰈆  Quit NVIM" , ":qa<CR>"),
			}

			local logo = [[





 ▗▄▖ ▗▄▄▖  ▗▄▖ ▗▖  ▗▖▗▄▄▄  ▗▄▖ ▗▖  ▗▖     ▗▄▖ ▗▖   ▗▖       ▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▄▖    
▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▛▚▖▐▌▐▌  █▐▌ ▐▌▐▛▚▖▐▌    ▐▌ ▐▌▐▌   ▐▌       ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌       
▐▛▀▜▌▐▛▀▚▖▐▛▀▜▌▐▌ ▝▜▌▐▌  █▐▌ ▐▌▐▌ ▝▜▌    ▐▛▀▜▌▐▌   ▐▌       ▐▛▀▜▌▐▌ ▐▌▐▛▀▘ ▐▛▀▀▘    
▐▌ ▐▌▐▙▄▞▘▐▌ ▐▌▐▌  ▐▌▐▙▄▄▀▝▚▄▞▘▐▌  ▐▌    ▐▌ ▐▌▐▙▄▄▖▐▙▄▄▖    ▐▌ ▐▌▝▚▄▞▘▐▌   ▐▙▄▄▖    
                                                                                    
                                                                                    
                                                                                    
        ▗▖  ▗▖▗▄▄▄▖    ▗▖ ▗▖▗▖ ▗▖ ▗▄▖     ▗▖  ▗▖ ▗▄▄▖ ▗▄▄▖ ▗▄▖ ▗▄▄▄ ▗▄▄▄▖           
         ▝▚▞▘ ▐▌       ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌    ▐▌  ▐▌▐▌   ▐▌   ▐▌ ▐▌▐▌  █▐▌              
          ▐▌  ▐▛▀▀▘    ▐▌ ▐▌▐▛▀▜▌▐▌ ▐▌    ▐▌  ▐▌ ▝▀▚▖▐▌   ▐▌ ▐▌▐▌  █▐▛▀▀▘           
          ▐▌  ▐▙▄▄▖    ▐▙█▟▌▐▌ ▐▌▝▚▄▞▘     ▝▚▞▘ ▗▄▄▞▘▝▚▄▄▖▝▚▄▞▘▐▙▄▄▀▐▙▄▄▖           

                      ]]

		      local userName = 'Lazy'
		      local marginBottom = 0


		      -- Highlight groups configuration for each segment
		      local header_hl = {
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },              -- Empty lines
			      {
				      { "GreyComment", 1,  60 },
				      { "Pink_1", 60, 90 },
			      }, -- Line 10
			      {                                 -- Line 11
				      { "GreyComment", 0,  60 },
				      { "Pink_1", 60, 90 },
			      },
			      { -- Line 12
				      { "GreyComment", 0,  60 },
				      { "Pink_1", 60, 90 },
			      },
			      { -- Line 13
				      { "GreyComment", 0,  60 },
				      { "Pink_1", 60, 90 },
			      },
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },
			      { { "Red", 1, 1 } },              -- Empty lines
			      { -- Line 14
				      { "GreyComment", 8,  39 },
				      { "Pink_1", 39, 90 },
			      },
			      { -- Line 15
				      { "GreyComment", 9,  39 },
				      { "Pink_1", 39, 90 },
			      },
			      { -- Line 16
				      { "GreyComment", 9,  39 },
				      { "Pink_1", 39, 90 },
			      },
			      { -- Line 17
				      { "GreyComment", 9,  39 },
				      { "Pink_1", 39, 90 },
			      },
		      }

		      local utils = require('alpha.utils')

		      local header_val = vim.split(logo, '\n')
		      header_hl = utils.charhl_to_bytehl(header_hl, header_val, false)

		      dashboard.section.header.opts.hl = header_hl
		      dashboard.section.header.val = header_val

		      vim.api.nvim_create_autocmd('User', {
			      pattern = 'LazyVimStarted',
			      desc = 'Add Alpha dashboard footer',
			      once = true,
			      callback = function()
				      local stats = require('lazy').stats()
				      local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
				      dashboard.section.footer.val = {
					      ' ', ' ', ' ', ' Loaded ' .. stats.count .. ' plugins  in ' .. ms .. ' ms ', ' ', ' ', ' ', ' ', ' ', ' ',
					      ' ', ' ', ' ', ' ', ' ', ' ', ' ',
				      }
				      pcall(vim.cmd.AlphaRedraw)
			      end,
		      })
		      dashboard.opts.opts.noautocmd = true
			alpha.setup(dashboard.opts)
		end
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- Fonte para o LSP
			"hrsh7th/cmp-buffer",   -- Fonte para texto no buffer
			"hrsh7th/cmp-path",     -- Fonte para caminhos de arquivos
			"L3MON4D3/LuaSnip",    -- Snippet engine (obrigatório para cmp)
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- Aqui é onde o gopls enviará as sugestões
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				})
			})
		end,
	},
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = true
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"tpope/vim-eunuch",
		lazy = false, -- Carrega no início para que os comandos estejam sempre disponíveis
	},
	{
		"rmagatti/auto-session",
		lazy = false,

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = 'debug',
		},
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup()
		end
	},
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},
	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	{
		'kristijanhusak/vim-dadbod-ui',
		dependencies = {
			{ 'tpope/vim-dadbod', lazy = true },
			{ 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
		},
		keys = {
			{
				"<leader>dq",
				function()
					-- 1. Fecha a interface do Dadbod (a barra lateral)
					vim.cmd("silent! DBUIFindBuffer") -- Garante foco ou checagem

					-- Regex/Pattern para: qualquer-coisa-List-ano-mes-dia-hora-minutos
					-- %d representa um dígito, %- representa o hífen literal
					local pattern = "%-%d%d%d%d%-%d%d%-%d%d%-%d%d%-%d%d%-%d%d"

					-- 2. Itera sobre todos os buffers para fechar resultados e queries
					local bufs = vim.api.nvim_list_bufs()
					for _, buf in ipairs(bufs) do
						if vim.api.nvim_buf_is_valid(buf) then
							local ft = vim.bo[buf].filetype
							local name = vim.api.nvim_buf_get_name(buf)

							-- Filtra buffers de resultado (dbout) ou de interface (dbui)
							if ft == "dbout" or name:find("dbui") or ft == "dbui" or string.match(name, pattern) then
								vim.api.nvim_buf_delete(buf, { force = true })
							end
						end
					end

					print("Buffers do Dadbod fechados!")
				end,
				desc = "Fechar tudo do Dadbod (Interface e Resultados)",
			},
		},
		cmd = {
			'DBUI',
			'DBUIToggle',
			'DBUIAddConnection',
			'DBUIFindBuffer',
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_winwidth = 50
		end,
	},
	{
		'akinsho/bufferline.nvim', 
		version = "*", 
		dependencies = 'nvim-tree/nvim-web-devicons',
		config = function()
			vim.opt.termguicolors = true
			require("bufferline").setup{}
		end
	},
}
