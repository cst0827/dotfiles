local M = {}

function M.setup()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local builtin = require("telescope.builtin")

  local function open_multiple_files_in_tabs(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local multi_selections = picker:get_multi_selection()

    if vim.tbl_isempty(multi_selections) then
      table.insert(multi_selections, action_state.get_selected_entry())
    end

    actions.close(prompt_bufnr)

    for _, entry in ipairs(multi_selections) do
      if entry.path ~= nil then
        local lnum = entry.lnum or 1
        local col = (entry.col and entry.col > 0) and (entry.col - 1) or 0
        vim.cmd(string.format("tabnew %s", vim.fn.fnameescape(entry.path)))
        local win = vim.api.nvim_get_current_win()
        vim.schedule(function()
          pcall(vim.api.nvim_win_set_cursor, win, { lnum, col })
        end)
      end
    end
  end

  require("telescope").setup({
    defaults = {
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<CR>"] = open_multiple_files_in_tabs,
          ["<C-Up>"] = actions.preview_scrolling_up,
          ["<C-Down>"] = actions.preview_scrolling_down,
        },
        n = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<CR>"] = open_multiple_files_in_tabs,
          ["<C-Up>"] = actions.preview_scrolling_up,
          ["<C-Down>"] = actions.preview_scrolling_down,
        },
      },
    },
  })

  -- 可選：定義常用快捷鍵
  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Old Files" })
  vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Grep word under cursor" })
end

return M
