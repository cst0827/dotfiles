return {
  "preservim/tagbar",
  config = function()
    local qtm_ctags = vim.env.HOME .. "/dotfiles/config/qtestman.ctags"

    vim.g.tagbar_autoclose = 1
    vim.g.tagbar_autofocus = 1
    vim.g.tagbar_show_data_type = 1
    vim.g.tagbar_width = math.max(30, vim.fn.winwidth(0) / 4)

    vim.g.tagbar_type_qtestman = {
      ctagstype = "QTestMan",
      ctagsbin = "ctags",
      ctagsargs = table.concat({
        "-f -",
        "--format=2",
        "--excmd=pattern",
        "--fields=nksSafet",
        "--sort=no",
        "--options=" .. qtm_ctags,
        "--language-force=QTestMan",
      }, " "),
      kinds = {
        "t:Test Items",
      },
      sort = 0,
    }

    vim.keymap.set('n', '<F2>', ':TagbarToggle j<CR>', { noremap = true, silent = true })
  end,
}
