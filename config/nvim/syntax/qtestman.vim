" Vim syntax file
" Language: QTestMan Script
" Maintainer: Codex

if exists("b:current_syntax")
  finish
endif

syn case match

syn keyword qtmInclude include
syn keyword qtmConditional if
syn keyword qtmRepeat repeat
syn keyword qtmFlow break
syn keyword qtmResult matched unmatched throughput iops
syn keyword qtmAtom true false on off enter esc space tab up down right left ctrl+c

syn keyword qtmCommand
      \ cs cs_nb exec exec_nb scp login logout
      \ io_host io_host_nb io_host_dc io_host_dc_nb io_local io_local_nb
      \ io_host_multi io_local_multi io_rate iocomp_nb
      \ msgbox msgbox_yn msgbox_input ui_recorder sendkey
      \ finject verify delay date wait_until poll poll_boot random
      \ errstop failstop run stop end fail echo report chart_line
      \ disk_del disk_rescan nic_up nic_down smb_login smb_logout
      \ nfs_mount nfs_umount iscsi_login iscsi_login_chap iscsi_logout
      \ pd_init pd_online pd_rescan

syn region qtmString start=+"+ skip=+\\\\\|\\"+ end=+"+ keepend contains=qtmVarRef,qtmMacroRef
syn region qtmString start=+'+ skip=+\\\\\|\\'+ end=+'+ keepend contains=qtmVarRef,qtmMacroRef
syn match qtmComment "\%(^\|[^:]\)\zs//.*$"
syn match qtmOperator "\%(==\|!=\|>=\|<=\|+=\|-=\|++\|--\|=\|>\|<\)"
syn match qtmNumber "\<[0-9]\+\%(\.[0-9]\+\)\?\>"
syn match qtmDelimiter "[{}()]"

syn match qtmMacroRef "%([^)]\+)"
syn match qtmMacroDecl "^\s*%\S\+\ze\s*="
syn match qtmVarRef "$([^)]\+)"
syn match qtmVar "\$[\w-]\+"

syn match qtmTestItemMarker "^\s*#\+" contained
syn match qtmTestItemLoop "\[x[0-9]\+\]" contained
syn match qtmTestItemTitle "^\s*#\+\s*\%(\[x[0-9]\+\]\)\?\s*.*$" contains=qtmTestItemMarker,qtmTestItemLoop,qtmComment

syn match qtmCommandLine "^\s*\zs\%(cs\|cs_nb\|exec\|exec_nb\|scp\|login\|logout\|io_host\|io_host_nb\|io_host_dc\|io_host_dc_nb\|io_local\|io_local_nb\|io_host_multi\|io_local_multi\|io_rate\|iocomp_nb\|msgbox\|msgbox_yn\|msgbox_input\|ui_recorder\|sendkey\|finject\|verify\|delay\|date\|wait_until\|poll\|poll_boot\|random\|errstop\|failstop\|run\|stop\|end\|fail\|echo\|report\|chart_line\|disk_del\|disk_rescan\|nic_up\|nic_down\|smb_login\|smb_logout\|nfs_mount\|nfs_umount\|iscsi_login\|iscsi_login_chap\|iscsi_logout\|pd_init\|pd_online\|pd_rescan\)\>" contains=qtmCommand
syn match qtmIncludeLine "^\s*include\>" contains=qtmInclude

hi def link qtmInclude Include
hi def link qtmConditional Conditional
hi def link qtmRepeat Repeat
hi def link qtmFlow Statement
hi def link qtmResult Constant
hi def link qtmAtom Constant
hi def link qtmCommand Keyword
hi def link qtmString String
hi def link qtmComment Comment
hi def link qtmOperator Operator
hi def link qtmNumber Number
hi def link qtmDelimiter Delimiter
hi def link qtmMacroRef Macro
hi def link qtmMacroDecl Identifier
hi def link qtmVarRef Identifier
hi def link qtmVar Identifier
hi def link qtmTestItemMarker Special
hi def link qtmTestItemLoop Number
hi def link qtmTestItemTitle Special

let b:current_syntax = "qtestman"
