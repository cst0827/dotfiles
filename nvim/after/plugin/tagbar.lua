vim.g.tagbar_autoclose = 1
vim.g.tagbar_autofocus = 1
vim.g.tagbar_show_data_type = 1
vim.g.tagbar_width = math.max(30, vim.fn.winwidth(0) / 4)
vim.keymap.set('n', '<F2>', ':TagbarToggle j<CR>', { noremap = true, silent = true })
