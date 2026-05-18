return {
  "MeanderingProgrammer/render-markdown.nvim",
  version = "*",
  lazy = false,
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>md", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    enabled = false,
  },
  ---ft = { "markdown", "codecompanion" },
  ft = {},
}
