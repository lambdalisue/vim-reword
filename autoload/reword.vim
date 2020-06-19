function! reword#substitute(pat, sub, ...) abort
  let range = reword#util#range(a:0 ? a:1 : [])
  try
    silent! execute printf('%ss/\C%s/%s/g',
          \ range,
          \ a:pat,
          \ a:sub,
          \)
    silent! execute printf('%ss/\c%s/%s/g',
          \ range,
          \ a:pat,
          \ tolower(a:sub),
          \)
  catch /^Vim\%((\a\+)\)\=:E486:/
    echohl ErrorMsg
    echo matchstr(v:exception, 'Vim(.*):\zs.*')
    echohl None
  endtry
endfunction

function! reword#command(qargs, range) abort
  let expr = reword#util#trim(a:qargs)
  let [pat, sub] = reword#util#parse(expr)
  call reword#substitute(pat, sub, a:range)
endfunction
