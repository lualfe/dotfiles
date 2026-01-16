return {
  -- the colorscheme should be available when starting Neovim
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "ellisonleao/gruvbox.nvim", priority = 1000 },
  { "ribru17/bamboo.nvim", priority = 1000 },
  { 
	  "dracula/vim", 
	  priority = 1000, 
	  config = true, 
	  opts = ..., 
	  on_highlights = function(highlights, colors)
		  highlights.AlphaHeader = { fg = "#ff4000" }
	  end,
	  config = function() 
		  vim.cmd("colorscheme dracula") 
	  end,
  },
  { "danilo-augusto/vim-afterglow", priority = 1000 },
  {
	  "nyoom-engineering/oxocarbon.nvim",
	  config = function()
		  -- vim.opt.background = "light" 
	  end,
  },
}
