let s:interval = 100
let s:range_pattern = '^\%(''<\|''>\|\d*\|%\)\%(,\%(''<\|''>\|\d\+\)\)\?'

function! reword#live#start() abort
  let cmdline = getcmdline()
  let cmdname = matchstr(cmdline, '\w\+$')
  if cmdline =~# s:range_pattern . cmdname
    return printf(
          \ "%scall %s()\<CR>",
          \ matchstr(cmdline, s:range_pattern),
          \ get(function('s:start'), 'name'),
          \)
  endif
  return cmdname
endfunction

function! s:start() abort range
  let range = [a:firstline, a:lastline]
  let prefix = reword#range(range)
  let modified = &modified
  let hlsearch = &hlsearch
  let undofile = tempname()
  let ns = {
        \ 'bufnr': bufnr('%'),
        \ 'range': range,
        \ 'content': getline(1, '$'),
        \ 'previous': '',
        \}
  try
    execute printf('wundo! %s', fnameescape(undofile))
    set hlsearch
    let timer = timer_start(
          \ s:interval,
          \ funcref('s:update', [ns]),
          \ { 'repeat': -1 },
          \)
    let expr = input(':' . prefix . 'Reword', '', 'command')
  finally
    call setline(1, ns.content)
    silent! call timer_stop(timer)
    silent! execute printf('rundo %s', fnameescape(undofile))
    let &hlsearch = hlsearch
    let &modified = modified
  endtry
  if s:apply(range, expr)
    call histadd('cmd', printf('%sReword%s', prefix, expr))
  endif
endfunction

function! s:update(ns, timer) abort
  if getcmdtype() !=# '@' || a:ns.bufnr isnot# bufnr('%')
    call timer_stop(a:timer)
    return
  endif
  let expr = getcmdline()
  if expr ==# a:ns.previous
    return
  endif
  let a:ns.previous = expr
  call setline(1, a:ns.content)
  call s:apply(a:ns.range, expr)
  redraw
endfunction

function! s:apply(range, expr) abort
  let [old, new, flags] = reword#parse(a:expr)
  if empty(old)
    nohlsearch
  elseif empty(new)
    silent! execute printf(
          \ '/\C\%%(%s\)/',
          \ s:build_pattern(a:range, old),
          \)
  else
    call reword#substitute(old, new, {
          \ 'range': a:range,
          \ 'flags': flags,
          \})
    return 1
  endif
endfunction

function! s:build_pattern(range, text) abort
  let es = []
  let rs = get(a:range, 0, v:null)
  let re = get(a:range, 1, v:null)
  if rs is# v:null && re is# v:null
    call add(es, a:text)
  else
    let pattern = printf('\%%(%s\)', join(uniq(sort([
          \ a:text,
          \ reword#lower_camel_case(a:text),
          \ reword#snake_case(a:text),
          \ reword#kebab_case(a:text),
          \ tolower(a:text),
          \ toupper(a:text),
          \])), '\|'))
    if rs isnot# v:null && re isnot# v:null
      call add(es, printf('\%%>%dl\%%<%dl%s', rs, re, pattern))
    endif
    if rs isnot# v:null
      call add(es, printf('\%%%dl%s', rs, pattern))
    endif
    if re isnot# v:null
      call add(es, printf('\%%%dl%s', re, pattern))
    endif
  endif
  return printf('\%%(%s\)', join(es, '\|'))
endfunction
