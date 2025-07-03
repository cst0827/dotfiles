return{ -- copilot
  "github/copilot.vim",
  config = function()
    vim.g.copilot_node_command = vim.fn.expand('~/.nvm/versions/node/v20.19.3/bin/node')
    vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
    vim.g.copilot_no_tab_map = true
    vim.cmd('Copilot disable')
  end,
}
