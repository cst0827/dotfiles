return {
  "MeanderingProgrammer/render-markdown.nvim",
  version = "*",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>md", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
  ---ft = { "markdown", "codecompanion" },
  ft = {},
}
