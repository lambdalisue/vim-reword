function! reword#substitute(old, new, ...) abort
  let options = extend({
        \ 'range': [],
        \ 'flags': g:reword#default_flags,
        \}, a:0 ? a:1 : {},
        \)
  let range = reword#range(options.range)
  let flags = substitute(options.flags, '[lski]', '', 'g')
  try
    if options.flags !~# 'l'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#lower_camel_case(a:old),
            \ reword#lower_camel_case(a:new),
            \ flags,
            \)
    endif
    if options.flags !~# 's'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#snake_case(a:old),
            \ reword#snake_case(a:new),
            \ flags,
            \)
    endif
    if options.flags !~# 'k'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ reword#kebab_case(a:old),
            \ reword#kebab_case(a:new),
            \ flags,
            \)
    endif
    silent! execute printf('%ss/\C%s/%s/%s',
          \ range,
          \ a:old,
          \ a:new,
          \ flags,
          \)
    if options.flags !~# 'i'
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ tolower(a:old),
            \ tolower(a:new),
            \ flags,
            \)
      silent! execute printf('%ss/\C%s/%s/%s',
            \ range,
            \ toupper(a:old),
            \ toupper(a:new),
            \ flags,
            \)
    endif
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
  let [old, new, flags] = reword#parse(expr)
  call reword#substitute(old, new, {
        \ 'range': a:range,
        \ 'flags': flags,
        \})
endfunction

function! reword#lower_camel_case(text) abort
  let t = s:escape_pattern(a:text)
  return substitute(t, '^\(\u\)', '\l\1', 'g')
endfunction

function! reword#snake_case(text) abort
  let t = s:escape_pattern(a:text)
  let t = substitute(t, '\(\l\)\(\u\)', '\1_\l\2', 'g')
  let t = substitute(t, '\(\u\)\(\u\)\(\l\)', '\1_\l\2\3', 'g')
  return tolower(t)
endfunction

function! reword#kebab_case(text) abort
  let t = s:escape_pattern(a:text)
  let t = substitute(t, '\(\l\)\(\u\)', '\1-\l\2', 'g')
  let t = substitute(t, '\(\u\)\(\u\)\(\l\)', '\1-\l\2\3', 'g')
  return tolower(t)
endfunction

function! s:escape_pattern(text) abort
  return escape(a:text, '^$~.*[]\')
endfunction

let g:reword#default_flags = get(g:, 'reword#default_flags', '')
