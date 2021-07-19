# general
alias ll='ls -l'
alias la='ls -al'

# custom
alias :q='exit'
alias vim='vim -p'
alias grepp="grep -Irnw --exclude-dir='.svn' --exclude='tags'"
alias grepx="grep -Irn --exclude-dir='.svn' --exclude='tags'"
alias svnstp='svn st | grep "^[^\\?]"'
alias svnstpall="for d in ./*/ ; do (cd \"\$d\" && echo -e \"\\033[1;34m\$d\\033[0m\"&& svnstp); done"
alias svnupall="svn up; for d in ./*/ ; do (cd \"\$d\" && echo -e \"\\033[1;34m\$d\\033[0m\"&& svn up); done"
alias svnmylog="svn log | sed -n '/peter/,/-----\$/ p'"
alias viewdiff="svn diff | vim -"
alias svnstpall='svnstp; for d in ./*/ ; do (cd "$d" && echo -e "\033[1;34m$d\033[0m"&& svnstp); done'
alias genctags='ctags -R --languages=c --langmap=c:+.h -h +.h ./'
alias genphptags='ctags -R --languages=php ./'
alias ..='cd ..'
alias ..2='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'
