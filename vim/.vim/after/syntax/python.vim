" Update pythonStatement, keep return in red
syntax clear pythonStatement
syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement lambda nonlocal pass print with yield
syn keyword pythonStatement def skipwhite nextgroup=pythonFunctionImpl
syn keyword pythonStatement class nextgroup=pythonClass skipwhite
syn keyword Statement       return

" Color additional operators
syn match pythonExtraOperator "\%([~!^&|*/%+-]\|\%(class\s*\)\@<!<<\|<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<[^<]\@=\|===\|==\|=\~\|>>\|>=\|=\@<!>\|\*\*\|\.\.\.\|\.\.\|::\|=\)"
syn match pythonExtraPseudoOperator "\%(-=\|/=\|\*\*=\|\*=\|&&=\|&=\|&&\|||=\||=\|||\|%=\|+=\|!\~\|!=\)"

syn match pythonDecorator "@" display nextgroup=pythonFunction skipwhite

" Highlight differently my own functions
syn clear pythonFunction
syn match pythonFunctionImpl
      \ "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contains=pythonStatement nextgroup=pythonVars

" Color parameters in functions
syn region pythonVars start="(" end="):\(\s*\(#.*\)\?$\)\@=" contained contains=pythonParameters transparent keepend
syn match pythonParameters "[^,:]*" contained contains=pythonParam,pythonBrackets skipwhite
syn match pythonParam "=[^,]*" contained contains=pythonExtraOperator,pythonBuiltin,pythonConstant,pythonStatement,pythonNumber,pythonString skipwhite
syn match pythonBrackets "[(|)]" contained skipwhite
syn match pythonClass
      \ "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained nextgroup=pythonClassVars
syn region pythonClassVars start="(" end=")" contained contains=pythonClassParameters transparent keepend
syn match pythonClassParameters "[^,]*" contained contains=pythonBuiltin,pythonBrackets,pythonComment,pythonString skipwhite

" Escape sequences
syn match pythonEscape  +\\[abfnrtv'"\\]+ contained
syn match pythonEscape  "\\\o\{1,3}" contained
syn match pythonEscape  "\\x\x\{2}" contained
syn match pythonEscape  "\%(\\u\x\{4}\|\\U\x\{8}\)" contained
syn match pythonEscape  "\\N{\a\+\%(\s\a\+\)*}" contained
syn match pythonEscape  "\\$"

" Color constants as numbers
syn keyword pythonNumber	False None True

if version >= 508 || !exists("did_python_syn_inits")
  hi def link pythonConstant  Constant
  hi def link pythonStatement  Structure
  hi def link pythonInclude  Operator
  hi def link pythonFunctionImpl FunctionImpl
  hi def link pythonEscape    Special
  hi def link pythonExtraOperator Operator
  hi def link pythonExtraPseudoOperator Operator
  hi def link pythonClass Normal
  hi def link pythonParameters Identifier
  hi def link pythonParam Normal
  hi def link pythonBrackets Normal
  hi def link pythonClassParameters InheritUnderlined
endif

let b:current_syntax = "python"

