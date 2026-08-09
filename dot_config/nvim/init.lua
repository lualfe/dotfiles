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

vim.opt.autoread = true

vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  command = "checktime",
})

local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

local swap_dir = vim.fn.expand("~/.local/share/nvim/swap//")
local backup_dir = vim.fn.expand("~/.local/share/nvim/backup//")
local undo_dir = vim.fn.expand("~/.local/share/nvim/undo//")

ensure_dir(swap_dir)
ensure_dir(backup_dir)
ensure_dir(undo_dir)

vim.opt.directory = swap_dir
vim.opt.backupdir = backup_dir
vim.opt.undodir = undo_dir
vim.opt.undofile = true
