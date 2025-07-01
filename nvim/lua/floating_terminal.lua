local M = {}

-- Floating terminal state
M._floating_terminals = M._floating_terminals or {}
M._current_floating_term = nil
M._terminal_list_buf = nil

-- Open a new floating terminal, close the previous one
M.Floating_terminal = function(term_name)
  -- Find the minimal reusable index
  local term_idx = nil
  for i = 1, math.max(1, #M._floating_terminals + 1) do
    if not M._floating_terminals[i] or (M._floating_terminals[i] and not vim.api.nvim_buf_is_valid(M._floating_terminals[i].buf)) then
      term_idx = i
      break
    end
  end

  -- Close the previous floating terminal window (if exists)
  if M._current_floating_term and vim.api.nvim_win_is_valid(M._current_floating_term.win) then
    vim.api.nvim_win_close(M._current_floating_term.win, true)
    if M._current_floating_term.title_win and vim.api.nvim_win_is_valid(M._current_floating_term.title_win) then
      vim.api.nvim_win_close(M._current_floating_term.title_win, true)
    end
  end

  -- Create a new terminal buffer
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'hide')

  -- Calculate floating window size and position
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Add terminal index title
  local name = term_name or ("Terminal " .. term_idx)
  local title = string.format("Terminal %d: %s", term_idx, name)
  local title_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title })
  vim.api.nvim_buf_set_option(title_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(title_buf, 'bufhidden', 'wipe')

  -- Open title window (height 1)
  local title_win = vim.api.nvim_open_win(title_buf, false, {
    relative = 'editor',
    row = row - 2,
    col = col,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })

  -- Open floating terminal window
  local win = vim.api.nvim_open_win(term_buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
  })

  -- Start terminal in buffer
  vim.fn.termopen(os.getenv("SHELL") or "bash")

  -- Enter terminal mode
  vim.cmd('startinsert')

  -- Record terminal info
  local term_info = { buf = term_buf, win = win, title_win = title_win, idx = term_idx, name = name }
  M._floating_terminals[term_idx] = term_info
  M._current_floating_term = term_info
end

-- Show all existing floating terminals in a buffer (not part of _floating_terminals)
M.List_floating_terminals = function()
  -- Create or reuse the buffer for the terminal list
  if not M._terminal_list_buf or not vim.api.nvim_buf_is_valid(M._terminal_list_buf) then
    M._terminal_list_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M._terminal_list_buf, 'bufhidden', 'hide')
  end

  -- Gather terminal info
  local lines = { "Opened Terminals:" }
  for idx, term in pairs(M._floating_terminals) do
    if term and vim.api.nvim_buf_is_valid(term.buf) then
      local display_name = term.name or ("Terminal " .. idx)
      table.insert(lines, string.format("Terminal %d: %s", idx, display_name))
    end
  end
  if #lines == 1 then
    table.insert(lines, "(none)")
  end
  vim.api.nvim_buf_set_option(M._terminal_list_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(M._terminal_list_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(M._terminal_list_buf, 'modifiable', false)

  -- Calculate floating window size and position
  local width = math.floor(vim.o.columns * 0.5)
  local height = math.min(10, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Close the previous floating terminal window (if exists)
  if M._current_floating_term and vim.api.nvim_win_is_valid(M._current_floating_term.win) then
    vim.api.nvim_win_close(M._current_floating_term.win, true)
    if M._current_floating_term.title_win and vim.api.nvim_win_is_valid(M._current_floating_term.title_win) then
      vim.api.nvim_win_close(M._current_floating_term.title_win, true)
    end
  end

  -- Add title
  local title = "Terminal List"
  local title_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title })
  vim.api.nvim_buf_set_option(title_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(title_buf, 'bufhidden', 'wipe')

  local title_win = vim.api.nvim_open_win(title_buf, false, {
    relative = 'editor',
    row = row - 2,
    col = col,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })

  local win = vim.api.nvim_open_win(M._terminal_list_buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
  })

  -- Update window info
  M._current_floating_term = { buf = M._terminal_list_buf, win = win, title_win = title_win, idx = "list" }

  -- Setup keymap for switching terminal from list
  vim.api.nvim_buf_set_keymap(M._terminal_list_buf, 'n', '<CR>', [[:lua require('floating_terminal')._switch_from_list()<CR>]], { noremap = true, silent = true })
  vim.api.nvim_set_option_value('modifiable', false, { buf = M._terminal_list_buf })
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = M._terminal_list_buf })
  vim.api.nvim_set_option_value('filetype', 'floating_terminal_list', { buf = M._terminal_list_buf })
end

-- Switch to an existing floating terminal by index
M.Switch_floating_terminal = function(idx)
  -- Validate index and terminal existence
  local term_info = M._floating_terminals[idx]
  if not term_info or not vim.api.nvim_buf_is_valid(term_info.buf) then
    print("No such floating terminal: " .. idx)
    return
  end

  -- Close current floating terminal window (if exists)
  if M._current_floating_term then
    if M._current_floating_term.win and vim.api.nvim_win_is_valid(M._current_floating_term.win) then
      vim.api.nvim_win_close(M._current_floating_term.win, true)
    end
    if M._current_floating_term.title_win and vim.api.nvim_win_is_valid(M._current_floating_term.title_win) then
      vim.api.nvim_win_close(M._current_floating_term.title_win, true)
    end
  end

  -- Calculate floating window size and position
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Add terminal index title
  local name = term_info.name or ("Terminal " .. idx)
  local title = string.format("Terminal %d: %s", idx, name)
  local title_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title })
  vim.api.nvim_buf_set_option(title_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(title_buf, 'bufhidden', 'wipe')

  -- Open title window (height 1)
  local title_win = vim.api.nvim_open_win(title_buf, false, {
    relative = 'editor',
    row = row - 2,
    col = col,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })

  -- Open floating terminal window
  local win = vim.api.nvim_open_win(term_info.buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
  })

  -- Enter terminal mode
  vim.cmd('startinsert')

  -- Update window info
  term_info.win = win
  term_info.title_win = title_win
  M._current_floating_term = term_info
end

-- Rename an existing floating terminal by index
M.Rename_floating_terminal = function(idx, new_name)
  local term_info = M._floating_terminals[idx]
  if not term_info or not vim.api.nvim_buf_is_valid(term_info.buf) then
    print("No such floating terminal: " .. idx)
    return
  end
  term_info.name = new_name or ("Terminal " .. idx)
  -- If this terminal is currently open, update the title window
  if M._current_floating_term and M._current_floating_term.idx == idx then
    -- Recreate the title buffer
    local width = math.floor(vim.o.columns * 0.85)
    local row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.85)) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    local title = string.format("Terminal %d: %s", idx, term_info.name)
    local title_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { title })
    vim.api.nvim_buf_set_option(title_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(title_buf, 'bufhidden', 'wipe')
    -- Close old title window
    if term_info.title_win and vim.api.nvim_win_is_valid(term_info.title_win) then
      vim.api.nvim_win_close(term_info.title_win, true)
    end
    -- Open new title window
    local title_win = vim.api.nvim_open_win(title_buf, false, {
      relative = 'editor',
      row = row - 2,
      col = col,
      width = width,
      height = 1,
      style = 'minimal',
      border = 'rounded',
      focusable = false,
      noautocmd = true,
    })
    term_info.title_win = title_win
    M._current_floating_term.title_win = title_win
  end
end

-- Close floating terminal window (only window, not wiping buffer)
M.Close_floating_terminal = function()
  if not M._current_floating_term then return end
  if M._current_floating_term.win and vim.api.nvim_win_is_valid(M._current_floating_term.win) then
    vim.api.nvim_win_close(M._current_floating_term.win, true)
  end
  if M._current_floating_term.title_win and vim.api.nvim_win_is_valid(M._current_floating_term.title_win) then
    vim.api.nvim_win_close(M._current_floating_term.title_win, true)
  end
end

-- Prompt to rename current floating terminal
function M._prompt_rename_current_terminal()
  if not M._current_floating_term or not M._current_floating_term.idx or M._current_floating_term.idx == "list" then
    print("No terminal to rename.")
    return
  end
  vim.ui.input({ prompt = "Rename terminal: ", default = "" }, function(input)
    if input and input ~= "" then
      M.Rename_floating_terminal(M._current_floating_term.idx, input)
    end
  end)
end

-- Auto close title window when terminal buffer is wiped or hidden
vim.api.nvim_create_autocmd({ "BufWipeout", "BufWinLeave" }, {
  pattern = "*",
  callback = function(args)
    if args.buf == M._terminal_list_buf then
      if M._current_floating_term.title_win and vim.api.nvim_win_is_valid(M._current_floating_term.title_win) then
        vim.api.nvim_win_close(M._current_floating_term.title_win, true)
      end
      return
    end
    for idx, term in pairs(M._floating_terminals or {}) do
      if term and term.buf == args.buf then
        -- Close title window if still open
        if term.title_win and vim.api.nvim_win_is_valid(term.title_win) then
          vim.api.nvim_win_close(term.title_win, true)
        end
        -- Release index only when buffer is wiped
        if args.event == "BufWipeout" then
          M._floating_terminals[idx] = nil
          -- If current terminal, clear it as well
          if M._current_floating_term and M._current_floating_term.buf == args.buf then
            M._current_floating_term = nil
          end
        end
        break
      end
    end
  end,
})

local floating_term_keymaps = {
  { "n", "<Leader>tt", ":lua require('floating_terminal').Floating_terminal()<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>tl", ":lua require('floating_terminal').List_floating_terminals()<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>1", ":lua require('floating_terminal').Switch_floating_terminal(1)<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>2", ":lua require('floating_terminal').Switch_floating_terminal(2)<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>3", ":lua require('floating_terminal').Switch_floating_terminal(3)<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>4", ":lua require('floating_terminal').Switch_floating_terminal(4)<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>5", ":lua require('floating_terminal').Switch_floating_terminal(5)<CR>", { noremap = true, silent = true } },
  { "n", "<Leader>tr", ":lua require('floating_terminal')._prompt_rename_current_terminal()<CR>", { noremap = true, silent = true } },
  { "t", "<ESC><ESC>", "<C-\\><C-n>", { noremap = true, silent = true } },
  { "t", "<ESC>q", [[<C-\><C-n>:lua require('floating_terminal').Close_floating_terminal()<CR>]], { noremap = true, silent = true } },
}

for _, map in ipairs(floating_term_keymaps) do
  vim.api.nvim_set_keymap(map[1], map[2], map[3], map[4])
end

-- Helper: Switch terminal from list buffer by cursor line
function M._switch_from_list()
  local line = vim.api.nvim_get_current_line()
  local idx = line:match("^Terminal%s+(%d+):")
  if idx then
    M.Switch_floating_terminal(tonumber(idx))
  end
end

return M
