# vim7 with Pathogen
#mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
#git clone https://github.com/morhetz/gruvbox.git ~/.vim/bundle/gruvbox

# vim8 or newer
[ -d ~/.vim/pack ] || mkdir ~/.vim/pack
[ -d ~/.vim/after/syntax ] || mkdir -p ~/.vim/after/syntax

git clone https://github.com/morhetz/gruvbox.git ~/.vim/pack/default/start/gruvbox
git clone https://github.com/brookhong/cscope.vim.git ~/.vim/pack/default/start/Cscove
git clone https://github.com/preservim/tagbar.git ~/.vim/pack/default/start/tagbar
git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/default/start/vim-airline
git clone https://github.com/tpope/vim-obsession.git ~/.vim/pack/default/start/obsession

patch -p 1 -d ~/.vim/pack/default/start/vim-airline/ <./patch/airline-obsession.patch

cp ./vim/.vimrc ~/.vimrc
cp ./vim/phpdoc.abbr ~/.vim/phpdoc.abbr
cp ./vim/phpif.abbr ~/.vim/phpif.abbr
cp ./vim/c.vim ~/.vim/after/syntax/c.vim
cp ./vim/ifdef.vim ~/.vim/after/syntax/ifdef.vim

# deprecated
#git clone https://github.com/yegappan/taglist.git ~/.vim/pack/default/start/taglist
# not that useful
#git clone https://github.com/jiangmiao/auto-pairs.git ~/.vim/pack/default/start/auto-pairs

# this minimap has some issue with tabs
#if which code-minimap; then
#    git clone https://github.com/wfxr/minimap.vim.git ~/.vim/pack/default/start/minimap
#fi

