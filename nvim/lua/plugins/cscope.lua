-- Cscope mappings using leader key (Cscope is not in nvim, maybe install later)
return {
  "brookhong/cscope.vim",
  enabled = false,
  config = function()
    vim.keymap.set('n', '<Leader>fc', ':vsp<CR><C-W><S-T> :call CscopeFind("c", expand("<cword>"))<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<Leader>fs', ':vsp<CR><C-W><S-T> :call CscopeFind("s", expand("<cword>"))<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<Leader>l', ':call ToggleLocationList()<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<Leader>n', ':lne<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<Leader>p', ':lp<CR>', { noremap = true, silent = true })
  end,
}
