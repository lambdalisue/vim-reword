let s:interval = 100

function! reword#prompt#start(range) abort
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
    let prefix = s:range(a:range) . 's'
    execute printf(
          \ 'cnoremap <expr> <Plug>(reword-backspace) <SID>backspace("%s")',
          \ prefix,
          \)
    cmap <buffer> <Backspace> <Plug>(reword-backspace)
    cmap <buffer> <C-h> <Plug>(reword-backspace)
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

function! s:range(range) abort
  if a:range[0] is# a:range[1]
    return a:range[0] is# line('.')
          \ ? ''
          \ : a:range[0] . ''
  elseif a:range[0] is# 1 && a:range[1] is# line('$')
    return '%'
  endif
  return printf('%d,%d', a:range[0], a:range[1])
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
  let [pat, sub, flg] = reword#parser#parse(a:expr)
  if empty(pat)
    nohlsearch
  elseif empty(sub)
    let expr1 = printf('\%%>%dl\%%<%dl%s', a:range[0], a:range[1], pat)
    let expr2 = printf('\%%%dl%s', a:range[0], pat)
    let expr3 = printf('\%%%dl%s', a:range[1], pat)
    execute printf('/\c\%%(%s\)/', join([expr1, expr2, expr3], '\|'))
  else
    call reword#substitute(pat, sub, {
          \ 'flags': flg,
          \ 'range': s:range(a:range),
          \})
  endif
endfunction

function! s:backspace(prefix) abort
  return len(getcmdline()) <= 1
        \ ? printf("\<Esc>:%s", a:prefix)
        \ : "\<Backspace>"
endfunction

