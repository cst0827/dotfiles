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

return M
