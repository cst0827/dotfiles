local M = {}
-- Toggle highlighting under cursor
M.Highlighting = function()
  local highlighting = vim.g.highlighting or 0
  local search_pat = vim.fn.expand('<cword>')
  local cur_pat = vim.fn.getreg('/')
  local word_pat = '\\<' .. search_pat .. '\\>'

  if highlighting == 1 and string.match(cur_pat, '^\\<' .. search_pat .. '\\>$') then
    vim.g.highlighting = 0
    vim.cmd("silent nohlsearch")
    return
  end

  vim.fn.setreg('/', word_pat)
  vim.g.highlighting = 1
  vim.cmd("silent set hlsearch")
end

-- Toggle tabstop between 4 and 8 spaces
M.Toggle_tabstop = function()
  if vim.opt.tabstop:get() == 4 then
    vim.opt.tabstop = 8
  else
    vim.opt.tabstop = 4
  end
  vim.notify("Change tabstop to " .. vim.o.tabstop, vim.log.levels.INFO)
end

-- Switch between visable tabs and spaces
M.Toggle_listchars = function()
  if vim.opt.listchars:get().tab == "→ " then
    vim.opt.listchars = { tab = "  ", trail = "`", nbsp = "·" }
  else
    vim.opt.listchars = { tab = "→ ", trail = "`", nbsp = "·" }
  end
  vim.notify("Toggle tab character", vim.log.levels.INFO)
end

-- Insert one character
M.Insert_one_char = function()
  vim.api.nvim_echo({{"Insert character:", "None"}}, false, {})
  local c = vim.fn.nr2char(vim.fn.getchar())
  vim.api.nvim_feedkeys("i" .. c .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

-- Compare contents in 2 registers
M.Compare_regs = function(r1, r2, opts)
  opts = opts or {}
  local show_result = opts.show_result
  if show_result == nil then
    show_result = true
  end

  local a = vim.fn.getreg(r1, 1, 1)
  local b = vim.fn.getreg(r2, 1, 1)
  local ok = vim.deep_equal(a, b)

  if show_result then
    if ok then
      vim.notify(
        string.format("Compare result: Identical"),
        vim.log.levels.INFO
      )
    else
      vim.notify(
        string.format("Compare result: Different"),
        vim.log.levels.INFO
      )
    end
  end

  return ok
end

-- Yank to register (for comparison)
M.Yank_reg = function(r)
  r = r or '"'
  local ok, err = pcall(vim.cmd, string.format([[silent normal! gv"%sy]], r))
  if not ok then
    vim.notify(string.format("Yank_reg failed for register %s: %s", r, err), vim.log.levels.WARN)
  end
end

return M
