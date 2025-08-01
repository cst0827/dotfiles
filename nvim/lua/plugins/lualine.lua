return {
  "nvim-lualine/lualine.nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local get_cwd = function()
      return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
    end
    local get_location = function()
      local line = vim.fn.line(".")
      local col = vim.fn.col(".")
      local virtcol = vim.fn.virtcol(".")
      return string.format("%d %d 󰇘%d", line, col, virtcol)
    end
    require("lualine").setup({
      sections = {
        lualine_a = {'mode', 'searchcount'},
        lualine_c = {'filename', get_cwd},
        lualine_z = {get_location},
      },
    })
  end
}
