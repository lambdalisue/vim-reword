function! reword#substitute(pat, sub, ...) abort
  let options = extend({
        \ 'flags': '',
        \ 'range': '',
        \}, a:0 ? a:1 : {},
        \)
  try
    silent! execute printf('%ss/\C%s/%s/%s',
          \ options.range,
          \ a:pat,
          \ a:sub,
          \ options.flags,
          \)
    silent! execute printf('%ss/\c%s/%s/%s',
          \ options.range,
          \ a:pat,
          \ tolower(a:sub),
          \ options.flags,
          \)
  catch /^Vim\%((\a\+)\)\=:E486:/
    echohl ErrorMsg
    echo matchstr(v:exception, 'Vim(.*):\zs.*')
    echohl None
  endtry
endfunction
