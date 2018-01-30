" Add coloration for functions
syn match cCustomCDstrImpl    "^\(\S\+\)\s*::\s*\~\?\1\s*(\@=" contains=cType,cCustomScope
syn match cCustomParen        "?=(" contains=cParen,cCppParen,cppCast
syn match cCustomFunc         "\w\+\s*(\@=" contains=cCustomParen
syn match cCustomScope        "::"
syn match cCustomClass        "\s\+\w\+\s*::" contains=cCustomScope

" Add color for the operators, without disabling comments, ->
syn match cExtraOperator "\%(\(/\*\|//\)\@![~!^&|*/%+]\|[=-]\@<!>\|\%(class\s*\)\@<!<<\|<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<[^<]\@=\|==\|=\~\|>>\|>=\|[=-]\@<!>\|\*\|\.\.\.\|\.\.\|=\)"
syn match cExtraPseudoOperator "\%(++\|--\|-=\|/=\|\*\*=\|\*=\|&&=\|&=\|&&\|||=\||=\|||\|%=\|+=\|!\~\|!=\)"


" Add color for these new classes
hi def link cCustomCDstrImpl FunctionImpl
hi def link cCustomFunc Function
hi def link cCustomClass FunctionImpl
hi def link cExtraOperator Operator
hi def link cExtraPseudoOperator Operator

