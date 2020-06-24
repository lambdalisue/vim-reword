function! reword#substitute(pat, sub, ...) abort
  let options = extend({
        \ 'range': [],
        \ 'flags': g:reword#default_flags,
        \}, a:0 ? a:1 : {},
        \)
  let range = reword#range(options.range)
  let flags = substitute(options.flags, '[lsk]', '', 'g')
  try
    if options.flags !~# 'l'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#case#to_lower_camel(a:pat),
            \ reword#case#to_lower_camel(a:sub),
            \ flags,
            \)
    endif
    if options.flags !~# 's'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#case#to_snake(a:pat),
            \ reword#case#to_snake(a:sub),
            \ flags,
            \)
    endif
    if options.flags !~# 'k'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#case#to_kebab(a:pat),
            \ reword#case#to_kebab(a:sub),
            \ flags,
            \)
    endif
    silent! execute printf('%ss/\C%s/%s/%s',
          \ range,
          \ a:pat,
          \ a:sub,
          \ flags,
          \)
  catch /^Vim\%((\a\+)\)\=:E486:/
    echohl ErrorMsg
    echo matchstr(v:exception, 'Vim(.*):\zs.*')
    echohl None
  endtry
endfunction

function! reword#parse(expr) abort
  let pat = ''
  let sub = ''
  let flags = g:reword#default_flags
  if empty(a:expr)
    return [pat, sub, flags]
  endif
  let sep = a:expr[0]
  let i1 = match(a:expr, printf('[^\\]%s', sep), 1)
  if i1 is# -1
    let pat = a:expr[1:]
    return [pat, sub, flags]
  endif
  let pat = a:expr[1:i1]
  let i2 = match(a:expr, printf('[^\\]%s', sep), i1 + 1)
  if i2 is# -1
    let sub = a:expr[i1 + 2:]
    return [pat, sub, flags]
  endif
  let sub = a:expr[i1 + 2:i2]
  let flags = a:expr[i2 + 2:]
  return [pat, sub, flags]
endfunction

function! reword#range(range) abort
  let rs = get(a:range, 0, v:null)
  let re = get(a:range, 1, v:null)
  if rs is# v:null
    return ''
  elseif rs is# re
    return rs is# line('.') ? '' : (rs . '')
  elseif rs is# 1 && re is# line('$')
    return '%'
  endif
  return printf(
        \ '%s,%s',
        \ rs is# line("'<") ? "'<" : rs,
        \ re is# line("'>") ? "'>" : re,
        \)
endfunction

function! reword#command(range, qargs) abort
  let expr = substitute(a:qargs, '^\s\+\|\s\+$', '', 'g')
  let [pat, sub, flags] = reword#parse(expr)
  call reword#substitute(pat, sub, {
        \ 'range': a:range,
        \ 'flags': flags,
        \})
endfunction

let g:reword#default_flags = get(g:, 'reword#default_flags', '')
