local M = {}

M._terminal_list_buf = nil
M._terminal_list_win = nil

--- keymaps for toggleterm buffers only
local terminal_keymap = {
  -- <C-q> to toggle off terminal in terminal mode
  {mode = "n", lhs = "<C-q>", rhs = function()vim.cmd("ToggleTerm") end},
  {mode = "t", lhs = "<C-q>", rhs = function()vim.cmd("ToggleTerm") end},
  -- <ESC><ESC> to exit terminal mode
  {mode = "t", lhs = "<ESC><ESC>", rhs = [[<C-\><C-n>]]},
}

--- Toggle a terminal, put it in terminal mode if terminal is opened
function M.Toggle(id)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    id = id,
    direction = "float",
    dir = "git_dir",
    size = 40,
    name = "Term" .. id,
    display_name = "Term" .. id,
    on_open = function(term)
      for _, map in ipairs(terminal_keymap) do
        vim.keymap.set(map.mode, map.lhs, map.rhs, { buffer = term.bufnr, noremap = true, silent = true })
      end
    end
  })

  term:toggle()
  if term:is_open() then
    term:set_mode("i")
  end
end

--- Rename current terminal if a terminal is open, or specify terminal number and name to rename
function M.Rename_terminal(id)
  local terminal = require("toggleterm.terminal")
  local term_id = id or (function()
    local cur_win = vim.api.nvim_get_current_win()
    local cur_buf = vim.api.nvim_win_get_buf(cur_win)

    -- return term id if current buffer is a toggleterm terminal buffer
    for _, term in ipairs(terminal.get_all()) do
      if term.bufnr == cur_buf then
        return term.id
      end
    end

    return nil
  end)()

  -- input terminal id if not provided
  vim.ui.input({ prompt = "Terminal id to rename: "}, function(input)
    if input and input ~= "" then
      term_id = tonumber(input)
    end
  end)
  if not term_id then
    vim.notify("Terminal id nil", vim.log.levels.WARN)
    return
  end
  if not terminal.get(term_id) then
    vim.notify("Invalid terminal id " .. term_id, vim.log.levels.WARN)
    return
  end
  -- rename terminal id 
  vim.ui.input({ prompt = "New name for Terminal " .. term_id .. ": " }, function(input)
    if input and input ~= "" then
      local term = terminal.get(term_id)
      term.display_name = input
    end
  end)
end

--- Show all existing terminals in a buffer
function M.List_floating_terminals()
  local terminal = require("toggleterm.terminal")
  local Terminal = terminal.Terminal
  -- Create or reuse the buffer for the terminal list
  if not M._terminal_list_buf or not vim.api.nvim_buf_is_valid(M._terminal_list_buf) then
    M._terminal_list_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = M._terminal_list_buf })
  end

  -- Gather terminal info
  local terms = terminal.get_all()
  local lines = { "Opened Terminals:" }
  for _, term in pairs(terms) do
    local display_name = term:_display_name() or term.name or "Term " .. term.id
    table.insert(lines, string.format("Terminal %d: %s", term.id, display_name))
  end
  if #lines == 1 then
    table.insert(lines, "(none)")
  end
  vim.api.nvim_set_option_value('modifiable', true, { buf = M._terminal_list_buf })
  vim.api.nvim_buf_set_lines(M._terminal_list_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = M._terminal_list_buf })

  -- Calculate floating window size and position
  local width = math.floor(vim.o.columns * 0.5)
  local height = math.min(10, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Close the previous floating terminal window (if exists)
  for _, term in pairs(terms) do
    if term:is_open() then
      term:close()
    end
  end

  -- Open the terminal list window if does not exist
  if not (M._terminal_list_win and vim.api.nvim_win_is_valid(M._terminal_list_win)) then
    local win = vim.api.nvim_open_win(M._terminal_list_buf, true, {
      relative = 'editor',
      row = row,
      col = col,
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
    })
    M._terminal_list_win = win
  end
  vim.api.nvim_win_set_cursor(0, {2, 0})

  -- Setup keymap for switching terminal from list
  vim.keymap.set('n', '<CR>', function()
    require('myconf.toggleterm')._switch_from_list()
  end, { noremap = true, silent = true, buffer = M._terminal_list_buf})
  vim.keymap.set('n', '<C-q>', '<Cmd>q<CR>', { noremap = true, silent = true, buffer = M._terminal_list_buf})
  vim.api.nvim_set_option_value('modifiable', false, { buf = M._terminal_list_buf })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M._terminal_list_buf })
  vim.api.nvim_set_option_value('filetype', 'floating_terminal_list', { buf = M._terminal_list_buf })
end

--- Helper: Switch terminal from list buffer by cursor line
function M._switch_from_list()
  local line = vim.api.nvim_get_current_line()
  local id = line:match("^Terminal%s+(%d+)")
  if id then
    -- turn off term list window
    if M._terminal_list_win and vim.api.nvim_win_is_valid(M._terminal_list_win) then
      vim.api.nvim_win_close(M._terminal_list_win, true)
    end
    M.Toggle(tonumber(id))
  end
end

--- keymaps
--- For keymaps works only in terminal see terminal_keymap
function M.Get_keys()
  local keys = {}

  -- <Leader>1 ~ <Leader>9 to open / switch to Terminal 1 ~ 9
  for i = 1, 9 do
    table.insert(keys, {
      "<M-" .. i .. ">",
      function()
        require("myconf.toggleterm").Toggle(i)
      end,
      mode = "t",
      desc = "ToggleTerm " .. i,
    })
  end
  for i = 1, 9 do
    table.insert(keys, {
      "<Leader>" .. i,
      function()
        require("myconf.toggleterm").Toggle(i)
      end,
      mode = "n",
      desc = "ToggleTerm " .. i,
    })
  end

  local tr_keys = {}
  -- <Leader>tt to open terminal list
  for _, m in ipairs({
    { mode = "n", lhs = "<Leader>tt" },
    { mode = "t", lhs = "<C-t>" }, }) do
    table.insert(tr_keys, {
      m.lhs,
      function()
        require("myconf.toggleterm").List_floating_terminals()
      end,
      mode = m.mode,
      desc = "Open terminal list",
      noremap = true,
      silent = true,
    })
  end
  -- <Leader>tr <C-r> to rename terminal
  for _, m in ipairs({
    { mode = "n", lhs = "<Leader>tr" },
    { mode = "t", lhs = "<C-r>" }, }) do
    table.insert(tr_keys, {
      m.lhs,
      function()
        require("myconf.toggleterm").Rename_terminal()
      end,
      mode = m.mode,
      desc = "Rename terminal",
      noremap = true,
      silent = true,
    })
  end
  vim.list_extend(keys, tr_keys)

  return keys
end

return M
