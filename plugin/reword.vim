if exists('g:loaded_reword') || v:version < 800
  finish
endif
let g:loaded_reword = 1

command! -nargs=+ -range Reword
      \ call reword#command([<line1>, <line2>], <q-args>)

command! -nargs=0 -range RewordPreview
      \ call reword#preview#start([<line1>, <line2>])

if !get(g:, 'reword_disable_seamless_preview', 0)
  cnoreabbrev <expr> Reword reword#preview#seamless()
endif
