vim.o.showtabline = 2

---- 一般設定 ----
vim.g.mapleader = "`"
vim.opt.termguicolors = true
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
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "˙", nbsp = "·" }
vim.opt.title = true
vim.opt.titlestring = "%t%(%m%)%((%{expand('%:p:~:h:h:t')}/%{expand('%:p:~:h:t')})%) %<%=%l/%L-%P%Y"
vim.opt.colorcolumn = "81," .. table.concat(vim.fn.range(121, 999), ",")
vim.g.highlighting = 0

---- Some language specific settings ----
-- Abbreviations (Insert mode)
vim.cmd [[iabbrev phpdoc <Esc>:read $HOME/.vim/phpdoc.abbr<CR>kdd6==jA]]
vim.cmd [[iabbrev godoc <Esc>:read $HOME/.vim/phpdoc.abbr<CR>kdd6==j<C-v>4jI<Space><Esc>A]]
vim.cmd [[iabbrev iff <Esc>:read $HOME/.vim/phpif.abbr<CR>kdd2==4li]]
-- Enable indent based on filetype
vim.cmd('filetype plugin indent on')
-- PHP switch statement indent
vim.g.PHP_vintage_case_default_indent = 1
-- Use tabstop 8 for .c and .h files, treat *.h as C
vim.g.c_syntax_for_h = 1
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'c',
  command = 'setlocal tabstop=8 noexpandtab',
})
-- Use tab for Golang indentation
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  command = 'setlocal tabstop=4 noexpandtab formatoptions+=ro',
})
-- Use 2 spaces for indentation in Lua files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  command = 'setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab',
})
-- Open help file in vertical split, left side, size 80, no foldcolumn
vim.api.nvim_create_autocmd({'WinEnter', 'BufWinEnter'}, {
  callback = function()
    if vim.bo.filetype == 'help' then
      vim.schedule(function()
        vim.cmd('setlocal foldcolumn=0')
        vim.cmd('wincmd L')
        vim.cmd('vertical resize 80')
      end)
    end
  end,
})

---- functions ----
local funcs = require('functions')
local floating_term = require('floating_terminal')
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
