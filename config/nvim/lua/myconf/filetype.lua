--- Some language specific settings ----
-- Enable indent based on filetype
vim.cmd('filetype plugin indent on')
-- PHP switch statement indent
vim.g.PHP_vintage_case_default_indent = 1
-- Use tabstop 8 for .c and .h files, treat *.h as C
vim.g.c_syntax_for_h = 1
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c',
  command = 'setlocal tabstop=8 noexpandtab',
})
-- Use tab for Golang indentation
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = 'setlocal tabstop=4 noexpandtab formatoptions+=ro',
})
-- Use 2 spaces for indentation in Lua files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab',
})
-- Open help file in vertical split, left side, size 80, no foldcolumn
vim.api.nvim_create_autocmd({'WinEnter', 'BufWinEnter'}, {
  callback = function()
    if vim.bo.filetype == 'help' then
      vim.schedule(function()
        vim.cmd('setlocal foldcolumn=0')
        vim.cmd('wincmd L')
        vim.cmd('vertical resize 80')
      end)
    end
  end,
})
