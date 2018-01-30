" Behavior

" Macros - LaTex
let @i='i\textit{ea}'
let @o='i\textit{Ea}'
let @t='i\texttt{ea}'
let @y='i\texttt{Ea}'
let @v='df{f}x'

" Shortcuts - Normal Mode
nnoremap <buffer> <F2> :wa\|!pdflatex -output-directory="%:p:h/" "%:p:h/main.tex";open "%:p:h/main.pdf" -g<CR> 
nnoremap <buffer> <F3> :wa\|!pdflatex -output-directory="%:p:h" "%:p";open "%:p:r.pdf" -g<CR> 
nnoremap <buffer> <F4> :wa\|!biber "%:p:h/main"<CR> 

" Shortcuts - Insert mode
inoremap <buffer> <F2> <ESC> :wa\|!pdflatex -output-directory="%:p:h/" "%:p:h/main.tex";open "%:p:h/main.pdf" -g<CR> 
inoremap <buffer> <F3> <ESC> :wa\|!pdflatex -output-directory="%:p:h" "%:p";open "%:p:r.pdf" -g<CR> 
inoremap <buffer> <F3> <ESC> :wa\|!biber "%:p:h/main"<CR> 

