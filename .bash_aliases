# enable alias for non-interactive shell (used for vim)
shopt -s expand_aliases

# general
alias ll='ls -l'
alias la='ls -al'

# custom
alias :q='exit'
alias vim='vim -p'
alias grepp="grep -Irnw --exclude-dir='.svn' --exclude='tags' --exclude='*.cmd'"
alias grepx="grep -Irn --exclude-dir='.svn' --exclude='tags' --exclude='*.cmd'"
alias svnstp='svn st | grep "^[^\\?]"'
alias svnstpall="for d in ./*/ ; do (cd \"\$d\" && echo -e \"\\033[1;34m\$d\\033[0m\"&& svnstp); done"
alias svnupall="svn up; for d in ./*/ ; do (cd \"\$d\" && echo -e \"\\033[1;34m\$d\\033[0m\"&& svn up); done"
alias svnmylog="svn log | sed -n '/peter/,/-----\$/ p'"
alias viewdiff="svn diff | vim -"
alias svnstpall='svnstp; for d in ./*/ ; do (cd "$d" && echo -e "\033[1;34m$d\033[0m"&& svnstp); done'
alias genctags='ctags -R --languages=c --langmap=c:+.h -h +.h ./'
alias genphptags='ctags -R --languages=php ./'
alias genpytags='ctags -R --languages=python ./'
alias gengotags='tail -n +4 go.work | head -n -1 | ctags -R --languages=go -L -'
alias ..='cdup'
alias ..2='cdup 2'
alias ..3='cdup 3'
alias ..4='cdup 4'
alias gitstp="git status -uno"
alias gitlog="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%cd%C(reset) %C(bold green)(%cr)%C(reset)%C(auto)%d%C(reset) %C(dim white)- %an %C(dim blue)(%ad)%C(reset)%n''          %C(white)%s%C(reset)'"
