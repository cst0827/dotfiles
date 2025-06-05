" From https://github.com/pulkomandy/c.vim

" Matchs for types in variables and function declarations
syn match cJCTypeInDecl	"^\s*\(\(inline\|const\|restrict\|extern\|GLOBAL\|static\|register\|auto\|volatile\|virtual\|signed\|unsigned\|struct\)[ \t*]\+\)*\I\i*\([ \t*]\+\(const\|restrict\|volatile\)\)*[ \t*]" contained
syn match cJCDecl		"^\s*\(inline\s\+\)\=\(\I\i*[ \t*]\+\)\+\s*\I" contains=cJCTypeInDecl

" Override some standard C things because cJCDecl matches a bit too easily
syn match cStatement	"^\s*return\>."me=e-1
syn match cStatement	"^\s*goto\s\+\I"me=e-1
syn match cConditional	"^\s*case\>."me=e-1
syn match cConditional	":\s*$"

hi link cJCTypeInDecl	cType

