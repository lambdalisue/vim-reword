if exists('g:loaded_reword') || v:version < 800
  finish
endif
let g:loaded_reword = 1

command! -nargs=+ -range Reword
      \ call reword#command([<line1>, <line2>], <q-args>)

if !get(g:, 'reword_disable_live', 0)
  cnoreabbrev <expr> Reword reword#live#start()
endif
