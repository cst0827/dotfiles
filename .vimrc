""""""
" Common settings
""""""
set t_Co=256
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set ai
set hlsearch
set cursorline
set wildmenu
set tabpagemax=30
" vim 7.3 does not support setting nu and rnu at the same time
set nu
set rnu
set incsearch
set splitright
set showcmd
set matchpairs=(:),{:},[:],<:>
set tags=./tags;
set completeopt=menuone,preview
let mapleader="`"
syntax on

""" Plugins
" Use Pathogen only if vim version is lower then 8.0 since vim8 has built-in plugin manager
if v:version < 800
    execute pathogen#infect()
endif
" gruvbox
if isdirectory($HOME."/.vim/pack/default/start/gruvbox")
    colorscheme gruvbox
    set background=dark
endif
" taglist
if isdirectory($HOME."/.vim/pack/default/start/taglist")
    let g:Tlist_GainFocus_On_ToggleOpen = 1
    nnoremap <F2> :TlistToggle<CR>
endif
" AutoPair
if isdirectory($HOME."/.vim/pack/default/start/auto-pairs")
    let g:AutoPairsMapCh = 0
    let g:AutoPairsMapSpace = 0
    let g:AutoPairsMultilineClose = 0
endif
" Cscove
if isdirectory($HOME."/.vim/pack/default/start/Cscove")
    " use localtion list for all cscope find
    set cscopequickfix =
    let g:cscope_open_location = 0
endif

""" always show status bar
set laststatus=2

""" set visible tabs and trailing white space
set list
set listchars=tab:→\ ,trail:˙,nbsp:·

""" set terminal title, ':help statusline' to see more about the format
set title
set titlestring=%t%(\ %m%)%(\ (%{expand(\"%:p:~:h:h:t\")}/%{expand(\"%:p:~:h:t\")})%)\ %<%=%l/%L-%P%Y

""" make background after 120 chars gray
let &colorcolumn=join(range(121,999),",")

""" abbreviates
iab phpdoc <Esc>:read $HOME/.vim/phpdoc.abbr<CR>kdd6==jA
iab iff <Esc>:read $HOME/.vim/phpif.abbr<CR>kdd2==lllli

""" enable indent based on filetype
filetype plugin indent on
" indent 'case' 'default' in php switch statement
let g:PHP_vintage_case_default_indent = 1
" Use tabstop 8 for .c and .h files.  Define g:c_syntax_for_h to claim that we
" want *.h to be filetype c, or it will be cpp by default.
let g:c_syntax_for_h = 1
au filetype c setlocal tabstop=8 noexpandtab

""" open help file in vertical split, left side
au filetype help wincmd L

""""""
" Functions
""""""
" highlight search / un-highlight word under cursor in normal mode
let g:highlighting = 0
function! Highlighting()
    if g:highlighting == 1 && @/ =~ '^\\<'.expand('<cword>').'\\>$'
        let g:highlighting = 0
        return ":silent nohlsearch\<CR>"
    endif
    let @/ = '\<'.expand('<cword>').'\>'
    let g:highlighting = 1
    return ":silent set hlsearch\<CR>"
endfunction

" trigger visible tabs (trailling space always visible)
let g:listchar = 1
function! SetListchar()
    if g:listchar == 1
        let g:listchar = 0
        return ":set listchars=tab:\\ \\ ,trail:`,nbsp:·\<CR>"
    endif
    let g:listchar = 1
    return ":set listchars=tab:→\\ ,trail:`,nbsp:·\<CR>"
endfunction

" Add tab index for tab line
" Modify from https://superuser.com/a/614424
function MyTabLine()
    let s = '' " complete tabline goes here
    " loop through each tab page
    for t in range(tabpagenr('$'))
        " set the tab page number (for mouse clicks)
        let s .= '%' . (t + 1) . 'T'
        " set a separate highlight for tab index
        let s .= '%#TabNum#'
        let s .= ' '
        " set page number string
        let s .= t + 1 . ' '
        " set highlight
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " get buffer names and statuses
        let n = ''      "temp string for buffer names while we loop and check buftype
        let m = 0       " &modified counter
        let bc = len(tabpagebuflist(t + 1))     "counter to avoid last ' '
        " loop through each buffer in a tab
        for b in tabpagebuflist(t + 1)
            " buffer types: quickfix gets a [Q], help gets [H]{base fname}
            " others get 1dir/2dir/3dir/fname shortened to 1/2/3/fname
            if getbufvar( b, "&buftype" ) == 'help'
                let n .= '[H]' . fnamemodify( bufname(b), ':t:s/.txt$//' )
            elseif getbufvar( b, "&buftype" ) == 'quickfix'
                let n .= '[Q]'
            else
                let n .= pathshorten(bufname(b))
            endif
            " check and ++ tab's &modified count
            if getbufvar( b, "&modified" )
                let m += 1
            endif
            " no final ' ' added...formatting looks better done later
            if bc > 1
                let n .= ' '
            endif
            let bc -= 1
        endfor
        " add modified label [n+] where n pages in tab are modified
        if m > 0
            let s .= '[' . m . '+]'
        endif
        let s .= ' '
        " select the highlighting for the buffer names
        " my default highlighting only underlines the active tab
        " buffer names.
        if t + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif
        " add buffer names
        if n == ''
            let s.= '[New]'
        else
            let s .= n
        endif
        " switch to no underlining and add final space to buffer list
        let s .= ' '
    endfor
    " after the last tab fill with TabLineFill and reset tab page nr
    let s .= '%#TabLineFill#%T'
    " right-align the label to close the current tab page
    if tabpagenr('$') > 1
        let s .= '%=%#TabLineFill#%999X'
    endif
    return s
endfunction

" Fix Meta key (<Alt->) for vim under gnome terminal, which send <Esc-> when
" <Alt-> is pressed.
function FixMeta()
    let c='a'
    while c <= 'z'
        exec "set <A-".c.">=\e".c
        exec "imap \e".c." <A-".c.">"
        let c = nr2char(1+char2nr(c))
    endw
endfunction

""""""
" Key mappings
""""""
" functions
nnoremap <silent> <expr> <CR> Highlighting()
nnoremap <S-Tab> :set expandtab!<CR>
""" <C-/> will input <C-_> in this terminal
nnoremap <expr> <C-_> SetListchar()
" screen scrolling and cursor movement
nnoremap <C-H> <Pagedown>
nnoremap <C-J> <C-E>
nnoremap <C-K> <C-Y>
nnoremap <C-L> <Pageup>
inoremap <C-H> <Left>
inoremap <C-J> <Down>
inoremap <C-K> <Up>
inoremap <C-L> <Right>
" arrow keys for screen scrolling
nnoremap <C-Up> <C-Y>
nnoremap <C-Down> <C-E>
inoremap <C-Up> <C-X><C-Y>
inoremap <C-Down> <C-X><C-E>
" open a new tab while goto tag
nnoremap <C-]> <C-W>]<C-w>T
nnoremap <C-\> :tab tselect <c-r>=expand("<cword>")<cr><CR>
" change the behavior of Enter when popup menu is visible (auto complete)
" so Enter will not insert line
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" press <SPACE> + character to insert a single character in normal mode
nnoremap <SPACE> :exec "normal i".nr2char(getchar())."\e"<CR>
" emulate copy to system clipboard
nnoremap <C-C> "*yiw"+yiw
vnoremap <C-C> "+y
if isdirectory($HOME."/.vim/pack/default/start/Cscove")
    nnoremap <leader>fc :vsp<CR><C-W><S-T> :call CscopeFind('c', expand('<cword>'))<CR>
    nnoremap <leader>fs :vsp<CR><C-W><S-T> :call CscopeFind('s', expand('<cword>'))<CR>
    nnoremap <Leader>l :call ToggleLocationList()<CR>
    nnoremap <Leader>n :lne<CR>
    nnoremap <Leader>p :lp<CR>
endif
call FixMeta()
set ttimeout ttimeoutlen=50
""""""
" Syntax
""""""
" modification for gruvbox, make current tab more visible
if isdirectory($HOME."/.vim/pack/default/start/gruvbox")
    highlight TabLineSel term=bold ctermfg=223 ctermbg=235 guifg=#ebdbb2 guibg=#282828
    highlight TabLineFill term=reverse ctermfg=232 ctermbg=243 guifg=#7c6f64 guibg=#3c3836
endif
" Tabline index for MyTabLine
highlight TabNum ctermbg=240 ctermfg=220
" Use MyTabLine as tab line style
set tabline=%!MyTabLine()
