if exists('g:loaded_reword') || v:version < 800
  finish
endif
let g:loaded_reword = 1

command! -nargs=0 -range RewordStart call reword#prompt#start([<line1>, <line2>])

if get(g:, 'reword_hijack_builtins', 1)
  cnoreabbrev s RewordStart<CR>
  cnoreabbrev %s %RewordStart<CR>
endif
