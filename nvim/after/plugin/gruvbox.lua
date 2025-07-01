-- make current tab more visible
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")
vim.api.nvim_set_hl(0, "TabLineSel", { bold = true, ctermfg = 223, ctermbg = 235, fg = "#ebdbb2", bg = "#282828" })
vim.api.nvim_set_hl(0, "TabLineFill", { reverse = true, ctermfg = 232, ctermbg = 243, fg = "#7c6f64", bg = "#3c3836" })
