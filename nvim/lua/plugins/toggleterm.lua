return {
  'akinsho/toggleterm.nvim',
  version = "v2.13.1",
  keys = require("myconf.toggleterm").Get_keys(),
  config = function()
    require("toggleterm").setup {
    }
  end,
}
