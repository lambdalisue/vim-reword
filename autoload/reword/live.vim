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
  let foldenable = &foldenable
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
    set nofoldenable
    let winfo = getwininfo(win_getid())[0]
    let preview_content = getline(winfo.topline, winfo.botline)
    %delete _
    call setline(1, preview_content)
    let timer = timer_start(
          \ s:interval,
          \ { t -> s:update(t, ns, preview_content) },
          \ { 'repeat': -1 },
          \)
    let expr = input(':' . prefix . 'Reword', '', 'command')
  finally
    call setline(1, ns.content)
    silent! call timer_stop(timer)
    silent! execute printf('rundo %s', fnameescape(undofile))
    let &hlsearch = hlsearch
    let &foldenable = foldenable
    let &modified = modified
    if exists('b:reword_m')
      silent! call matchdelete(b:reword_m)
    endif
  endtry
  if s:apply(range, expr)
    call histadd('cmd', printf('%sReword%s', prefix, expr))
  endif
endfunction

function! s:update(timer, ns, preview_content) abort
  if getcmdtype() !=# '@' || a:ns.bufnr isnot# bufnr('%')
    call timer_stop(a:timer)
    return
  endif
  let expr = getcmdline()
  if expr ==# a:ns.previous
    return
  endif
  let a:ns.previous = expr
  call setline(1, a:preview_content)
  call s:apply(a:ns.range, expr)
  redraw
endfunction

function! s:apply(range, expr) abort
  let [old, new, flags] = reword#parse(a:expr)
  if exists('b:reword_m')
    silent! call matchdelete(b:reword_m)
  endif
  if !empty(old) && !empty(new)
    call reword#substitute(old, new, {
          \ 'range': a:range,
          \ 'flags': flags,
          \})
    return 1
  elseif !empty(old)
    let b:reword_m = matchadd('Search', printf(
          \ '\C\%%(%s\)',
          \ s:build_pattern(a:range, old),
          \))
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
