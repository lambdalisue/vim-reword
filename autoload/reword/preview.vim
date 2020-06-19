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
    execute printf('wundo %s', fnameescape(undofile))
    call timer_start(
          \ s:interval,
          \ { t -> s:update(ns, t) },
          \ { 'repeat': -1 },
          \)
    cmap <buffer> <Backspace> <Plug>(reword-backspace)
    cmap <buffer> <C-h> <Plug>(reword-backspace)
    let prefix = reword#util#range(a:range) . 'Reword'
    let expr = input(':' . prefix, '', 'command')
  finally
    cunmap <buffer> <Backspace>
    cunmap <buffer> <C-h>
    call setline(1, ns.content)
    execute printf('rundo %s', fnameescape(undofile))
    let &modified = modified
  endtry
  call s:apply(a:range, expr)
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
  let [pat, sub] = reword#util#parse(a:expr)
  if empty(pat)
    nohlsearch
  elseif empty(sub)
    let rs = get(a:range, 0, v:null)
    let re = get(a:range, 1, v:null)
    let exprs = []
    if rs is# v:null && re is# v:null
      call add(exprs, pat)
    else
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
    execute printf('/\c\%%(%s\)/', join(exprs, '\|'))
  else
    call reword#substitute(pat, sub, a:range)
  endif
endfunction

function! s:backspace() abort
  return len(getcmdline()) <= 1
        \ ? "\<Esc>"
        \ : "\<Backspace>"
endfunction

cnoremap <expr> <Plug>(reword-backspace) <SID>backspace()
