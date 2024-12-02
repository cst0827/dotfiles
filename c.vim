" from https://raw.githubusercontent.com/pulkomandy/c.vim/refs/heads/main/c.vim

" Matchs for types in variables and function declarations
syn match	cJCTypeInDecl	"^\s*\(\(inline\|const\|restrict\|extern\|GLOBAL\|static\|register\|auto\|volatile\|virtual\|signed\|unsigned\|struct\)[ \t*]\+\)*\I\i*\([ \t*]\+\(const\|restrict\|volatile\)\)*[ \t*]*" contained
syn match	cJCDecl		"^\s*\(inline\s\+\)\=\(\I\i*[ \t*]\+\)\+\s*\I" contains=cJCTypeInDecl
