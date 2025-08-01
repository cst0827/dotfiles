require("myconf.filetype")

---- 一般設定 ----
vim.g.mapleader = "`"
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.mouse = ""
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 0
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.cursorline = true
vim.opt.wildmenu = true
vim.opt.tabpagemax = 30
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.incsearch = true
vim.opt.splitright = true
vim.opt.showcmd = true
vim.opt.foldcolumn = "2"
vim.opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
vim.opt.tags = "./tags;"
vim.opt.completeopt = { "menuone", "preview" }
vim.env.BASH_ENV = vim.fn.expand("$HOME/.bash_aliases")
vim.opt.diffopt = { "internal", "filler", "closeoff", "algorithm:minimal", "vertical" }
vim.cmd("syntax on")
---- 狀態列, 標題, buffer顯示 ----
vim.opt.laststatus = 2
vim.opt.shortmess:append("S") -- 顯示 Search hit TOP / BOTTOM warning
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "˙", nbsp = "·" }
vim.opt.title = true
vim.opt.titlestring = "%t%(%m%)%((%{expand('%:p:~:h:h:t')}/%{expand('%:p:~:h:t')})%) %<%=%l/%L-%P%Y"
vim.opt.colorcolumn = "81," .. table.concat(vim.fn.range(121, 999), ",")
vim.g.highlighting = 0

---- Abbreviations (Insert mode)
vim.cmd [[iabbrev phpdoc <Esc>:read $HOME/.vim/phpdoc.abbr<CR>kdd6==jA]]
vim.cmd [[iabbrev godoc <Esc>:read $HOME/.vim/phpdoc.abbr<CR>kdd6==j<C-v>4jI<Space><Esc>A]]
vim.cmd [[iabbrev iff <Esc>:read $HOME/.vim/phpif.abbr<CR>kdd2==4li]]

-- move to left after tab close instead of right
vim.api.nvim_create_autocmd("TabClosed", {
  callback = function(args)
    local closed_tab = tonumber(args.match)  -- closed tabnr
    local tabonleft = closed_tab - 1

    if tabonleft >= 1 then
      vim.cmd(tabonleft .. "tabnext")
    end
  end,
})
-- git diff in a new tab
vim.keymap.set("n", "<Leader>gg", function()
  vim.cmd("tabnew")
  vim.cmd("read !git diff")
  vim.cmd("1delete _")
  vim.bo.filetype = "diff"
  vim.bo.buftype = "nofile"
  vim.cmd("file Git\\ diff")
end, { desc = "Git diff in new tab" })
-- git diff --cached in a new tab
vim.keymap.set("n", "<Leader>gc", function()
  vim.cmd("tabnew")
  vim.cmd("read !git diff --cached")
  vim.cmd("1delete _")
  vim.bo.filetype = "diff"
  vim.bo.buftype = "nofile"
  vim.cmd("file Git\\ diff\\ cached")
end, { desc = "Git cached diff in new tab" })


---- functions ----
local funcs = require('myconf.functions')
_G.Highlighting = funcs.Highlighting
_G.Toggle_tabstop = funcs.Toggle_tabstop
_G.Toggle_listchars = funcs.Toggle_listchars
_G.Insert_one_char = funcs.Insert_one_char
---- Key mappings ----
local keymaps = {
  { "n", "<C-T>", ":vsp<CR><C-W>T", { noremap = true, silent = true } },
  { "n", "<S-Tab>", ":set expandtab!<CR>", { noremap = true } },
  -- <C-/> will input <C-_> in this terminal
  { "n", "<CR>", ":lua Highlighting()<CR>", { noremap = true, silent = true } },
  { "n", "<Leader><Tab>", ":lua Toggle_tabstop()<CR>", { noremap = true, silent = true } },
  { "n", "<C-_>", ":lua Toggle_listchars()<CR>", { noremap = true, silent = true } },
  { "n", "<SPACE>", ":lua Insert_one_char()<CR>", { noremap = true, silent = true } },
  -- screen scrolling and cursor movement
  { "n", "<C-H>", "<Pagedown>", { noremap = true } },
  { "n", "<C-J>", "<C-E>", { noremap = true } },
  { "n", "<C-K>", "<C-Y>", { noremap = true } },
  { "n", "<C-L>", "<Pageup>", { noremap = true } },
  { "i", "<C-H>", "<Left>", { noremap = true } },
  { "i", "<C-J>", "<Down>", { noremap = true } },
  { "i", "<C-K>", "<Up>", { noremap = true } },
  { "i", "<C-L>", "<Right>", { noremap = true } },
  { "n", "<C-Up>", "<C-Y>", { noremap = true } },
  { "n", "<C-Down>", "<C-E>", { noremap = true } },
  { "i", "<C-Up>", "<C-X><C-Y>", { noremap = true } },
  { "i", "<C-Down>", "<C-X><C-E>", { noremap = true } },
  -- open a new tab while goto tag
  { "n", "<C-]>", "<C-W>]<C-w>T", { noremap = true } },
  { "n", "<C-\\>", [[:tab tselect <C-R>=expand("<cword>")<CR><CR>]], { noremap = true} },
  -- change the behavior of Enter when popup menu is visible (auto complete) so Enter will not insert line
  { "i", "<CR>", 'pumvisible() ? "\\<C-y>" : "\\<C-g>u\\<CR>"', { noremap = true, expr = true } },
  -- copy word under cursor to clipboard
  { "n", "<C-C>", '"*yiw"+yiw', { noremap = true } },
  { "v", "<C-C>", '"+y', { noremap = true } },
}
for _, map in ipairs(keymaps) do
  vim.api.nvim_set_keymap(map[1], map[2], map[3], map[4])
end

require('config.lazy')
