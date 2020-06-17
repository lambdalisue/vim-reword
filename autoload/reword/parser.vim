function! reword#parser#parse(expr) abort
  if empty(a:expr)
    return ['', '', '']
  endif
  let sep = a:expr[0]
  let pat = match(a:expr, printf('[^\\]%s', sep), 1)
  if pat is# -1
    return [a:expr[1:], '', '']
  endif
  let sub = match(a:expr, printf('[^\\]%s', sep), pat + 1)
  if sub is# -1
    return [a:expr[1 : pat], a:expr[pat + 2 : ], '']
  endif
  return [a:expr[1 : pat], a:expr[pat + 2 : sub], a:expr[sub + 2 : ]]
endfunction
