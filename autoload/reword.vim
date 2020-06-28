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
  let sep = a:expr[:0]
  let terms = split(a:expr, printf('\\\@<!%s', sep))
  let lhs = substitute(get(terms, 0, ''), '\\\([^\\]\)', '\1', 'g')
  let rhs = substitute(get(terms, 1, ''), '\\\([^\\]\)', '\1', 'g')
  let flg = get(terms, 2, g:reword#default_flags)
  return [lhs, rhs, flg]
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
