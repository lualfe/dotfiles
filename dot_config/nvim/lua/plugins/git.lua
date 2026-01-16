return {
	{
		'tpope/vim-fugitive',
	},
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup({
				-- Configuração básica (você pode personalizar aqui)
				signs = {
					add          = { text = '┃' },
					change       = { text = '┃' },
					delete       = { text = '_' },
					topdelete    = { text = '‾' },
					changedelete = { text = '~' },
					untracked    = { text = '┆' },
				},
			})
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('lualine').setup()
		end
	},
	{
		'github/copilot.vim',
	},
}

