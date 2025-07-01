vim.g.session_dir = '~/vim_session'
vim.keymap.set('n', '<Leader>ss', ':Obsession ' .. vim.g.session_dir .. '/*.vim<C-D><BS><BS><BS><BS><BS>', { noremap = true, silent = false })
vim.keymap.set('n', '<Leader>sr', ':so ' .. vim.g.session_dir .. '/*.vim<C-D><BS><BS><BS><BS><BS>', { noremap = true, silent = false })
vim.keymap.set('n', '<Leader>sp', ':Obsession<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<Leader>sd', ':Obsession!<CR>', { noremap = true, silent = false })
