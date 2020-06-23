let s:interval = 100

function! reword#preview#start(range) abort
  let modified = &modified
  let undofile = tempname()
  let ns = {
        \ 'bufnr': bufnr('%'),
        \ 'range': a:range,
        \ 'content': getline(1, '$'),
        \ 'previous': '',
        \}
  try
    execute printf('wundo! %s', fnameescape(undofile))
    call timer_start(
          \ s:interval,
          \ { t -> s:update(ns, t) },
          \ { 'repeat': -1 },
          \)
    cmap <buffer> <Backspace> <Plug>(reword-backspace)
    cmap <buffer> <C-h> <Plug>(reword-backspace)
    let prefix = reword#range(a:range) . 'Reword'
    let expr = input(':' . prefix, '', 'command')
  finally
    cunmap <buffer> <Backspace>
    cunmap <buffer> <C-h>
    call setline(1, ns.content)
    silent! execute printf('rundo %s', fnameescape(undofile))
    let &modified = modified
  endtry
  if s:apply(a:range, expr)
    call histadd('cmd', printf('%sReword%s', reword#range(a:range), expr))
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
  let [pat, sub, flags] = reword#parse(a:expr)
  if empty(pat)
    nohlsearch
  elseif empty(sub)
    let rs = get(a:range, 0, v:null)
    let re = get(a:range, 1, v:null)
    let exprs = []
    if rs is# v:null && re is# v:null
      call add(exprs, pat)
    else
      let pat = printf('\%%(%s\)', join([
            \ pat,
            \ reword#case#to_lower_camel(pat),
            \ reword#case#to_snake(pat),
            \ reword#case#to_kebab(pat),
            \], '\|'))
      if rs isnot# v:null && re isnot# v:null
        call add(exprs, printf('\%%>%dl\%%<%dl%s', rs, re, pat))
      endif
      if rs isnot# v:null
        call add(exprs, printf('\%%%dl%s', rs, pat))
      endif
      if re isnot# v:null
        call add(exprs, printf('\%%%dl%s', re, pat))
      endif
    endif
    execute printf('/\C\%%(%s\)/', join(exprs, '\|'))
  else
    call reword#substitute(pat, sub, {
          \ 'range': a:range,
          \ 'flags': flags,
          \})
    return 1
  endif
endfunction

function! s:backspace() abort
  return len(getcmdline()) <= 1
        \ ? "\<Esc>"
        \ : "\<Backspace>"
endfunction

cnoremap <expr> <Plug>(reword-backspace) <SID>backspace()
