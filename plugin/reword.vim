if exists('g:loaded_reword') || v:version < 800
  finish
endif
let g:loaded_reword = 1

command! -nargs=+ -range Reword
      \ call reword#command([<line1>, <line2>], <q-args>)

command! -nargs=0 -range RewordPreview
      \ call reword#preview#start([<line1>, <line2>])

function! RewordSeamless() abort
  let pattern = '^\%(''<\|\|''>\|\d\+\)\%(,\%(''<\|\|''>\|\d\+\)\)\?'
  let cmdline = getcmdline()
  let keyword = matchstr(cmdline, '\w\+$')
  if cmdline ==# keyword
    return 'RewordPreview' . "\<CR>"
  elseif cmdline =~# '^%' . keyword
    return '%RewordPreview' . "\<CR>"
  elseif cmdline =~# pattern . keyword
    return matchstr(cmdline, pattern) . 'RewordPreview' . "\<CR>"
  endif
  return keyword
endfunction

if get(g:, 'reword_seamless_preview', 1)
  cnoreabbrev <expr> Reword RewordSeamless()
endif
