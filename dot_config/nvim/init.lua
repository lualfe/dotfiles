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

vim.opt.relativenumber = true
vim.opt.cursorline = true

