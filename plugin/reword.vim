if exists('g:loaded_reword') || v:version < 800
  finish
endif
let g:loaded_reword = 1

command! -nargs=+ -range Reword call reword#command(<q-args>, [<line1>, <line2>])
command! -nargs=0 -range RewordPreview call reword#preview#start([<line1>, <line2>])

if get(g:, 'reword_enable_shortcut', 1)
  cnoreabbrev R RewordPreview<CR>
  cnoreabbrev %R %RewordPreview<CR>
endif
