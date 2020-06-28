function! reword#case#to_lower_camel(text) abort
  let t = s:escape_pattern(a:text)
  return substitute(t, '^\(\u\)', '\l\1', 'g')
endfunction

function! reword#case#to_snake(text) abort
  let t = s:escape_pattern(a:text)
  let t = substitute(t, '\(\l\)\(\u\)', '\1_\l\2', 'g')
  let t = substitute(t, '\(\u\)\(\u\)\(\l\)', '\1_\l\2\3', 'g')
  return tolower(t)
endfunction

function! reword#case#to_kebab(text) abort
  let t = s:escape_pattern(a:text)
  let t = substitute(t, '\(\l\)\(\u\)', '\1-\l\2', 'g')
  let t = substitute(t, '\(\u\)\(\u\)\(\l\)', '\1-\l\2\3', 'g')
  return tolower(t)
endfunction

function! s:escape_pattern(text) abort
  return escape(a:text, '^$~.*[]\')
endfunction
