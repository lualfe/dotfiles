require("config.lazy")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf", -- Tipo de arquivo da Quickfix List
  callback = function()
    -- No buffer da Quickfix, ao apertar Enter:
    -- 1. Executa o Enter original (vai para o arquivo)
    -- 2. Executa :cclose (fecha a lista)
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
  end,
})

require("telescope").setup { extensions = { file_browser = { theme = "dropdown", hijack_netrw = true } } }
require("telescope").load_extension("file_browser")
vim.keymap.set("n", "<leader>fc", function() require("telescope").extensions.file_browser.file_browser() end, { desc = "Abrir File Browser" })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Telescope oldfiles' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Ir para definição" })

vim.keymap.set('n', '<leader>dc', function() require("dapui").close() end)

vim.opt.relativenumber = true
vim.opt.cursorline = true

