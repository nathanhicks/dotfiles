" Behavior
setlocal cindent
setlocal cinoptions=h1,l1,g1,t0,i4,+4,(0,w1,W4
setlocal indentexpr=GoogleCppIndent()

" uses cppman for man pages (pip3 install cppman)
command! -nargs=+ Cppman silent! call system("tmux split-window cppman " . expand(<q-args>))
nnoremap <silent><buffer> K <Esc>:Cppman <cword><CR>

" Shortcuts - Normal Mode
nnoremap <buffer> K    K<CR>
nnoremap <buffer> <F2> :wa\|!clear;make<CR>
nnoremap <buffer> <F3> :wa\|!clear; ./

" Shortcuts - Insert mode
inoremap <buffer> <F2> <ESC>:wa\|!clear;make<CR>
inoremap <buffer> <F3> <ESC>:wa\|!clear; ./

" Indentation - Google Style
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

function! GoogleCppIndent()
  let l:cline_num = line('.')
  let l:orig_indent = cindent(l:cline_num)

  if l:orig_indent == 0 | return 0 | endif

  let l:pline_num = prevnonblank(l:cline_num - 1)
  let l:pline = getline(l:pline_num)
  if l:pline =~# '^\s*template' | return l:pline_indent | endif

  "attempt for:
  " namespace test {
  " void
  " ....<-- invalid cindent pos
  "
  " void test() {
  " }
  "
  " void
  " <-- cindent pos
  if l:pline =~# '^\S\+$' | return l:pline_indent | endif

  if l:orig_indent != &shiftwidth | return l:orig_indent | endif

  let l:in_comment = 0
  let l:pline_num = prevnonblank(l:cline_num - 1)
  while l:pline_num > -1
    let l:pline = getline(l:pline_num)
    let l:pline_indent = indent(l:pline_num)

    if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
      let l:in_comment = 1
    elseif l:in_comment == 1
      if l:pline =~ '/\*\(.\{-}\*/\)\@!'
        let l:in_comment = 0
      endif
    elseif l:pline_indent == 0
      if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
        if l:pline =~# '^\s*namespace.*'
          return 0
        else
          return l:orig_indent
        endif
      elseif l:pline =~# '\\$'
        return l:orig_indent
      endif
    else
      return l:orig_indent
    endif

    let l:pline_num = prevnonblank(l:pline_num - 1)
  endwhile

  return l:orig_indent
endfunction

