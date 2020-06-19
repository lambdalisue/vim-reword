function! reword#util#trim(text) abort
  return substitute(a:text, '^\s\+\|\s\+$', '', 'g')
endfunction

function! reword#util#parse(expr) abort
  if empty(a:expr)
    return ['', '']
  endif
  let sep = a:expr[0]
  let idx = match(a:expr, printf('[^\\]%s', sep), 1)
  return idx is# -1
        \ ? [a:expr[1:], '']
        \ : [a:expr[1:idx], a:expr[idx+2:]]
endfunction

function! reword#util#range(range) abort
  let rs = get(a:range, 0, v:null)
  let re = get(a:range, 1, v:null)
  if rs is# v:null
    return ''
  elseif rs is# re
    return rs is# line('.') ? '' : rs . ''
  elseif rs is# 1 && re is# line('$')
    return '%'
  endif
  let rs = rs is# line("'<") ? "'<" : rs
  let re = re is# line("'>") ? "'>" : re
  return printf('%d,%d', rs, re)
endfunction
