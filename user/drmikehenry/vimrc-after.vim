function! CustomSetupMake()
    call SetupMake()

    " Expand tabs by default, since indentation in function bodies is by far
    " more common than creating a new recipe which demands a leading tab.  This
    " is experimental for now, but it's very helpful to avoid putting tabs into
    " function bodies and ending up with mixed tabs and spaces (which will
    " promote a tab damage problem if others use ts != 8).
    " To insert a real tab character, type <C-V><Tab>.
    setlocal et sw=2 sts=2
endfunction
command! -bar SetupMake call CustomSetupMake()

" Use cpsm matcher for CtrlP.
let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
let g:cpsm_query_inverting_delimiter = ' '

" Experiment with 'splitright'.
set splitright

nmap <Space>gd <Plug>(ale_go_to_definition)

" Symbol edit (rename).
nnoremap <Space>se :ALERename<CR>
" Show symbol information.
nmap <Space>si <Plug>(ale_hover)


" Experimental overwin-based mappings.
nmap     <Space>jj          <Plug>(easymotion-overwin-f)
nmap     <Space>jJ          <Plug>(easymotion-overwin-f2)
nmap     <Space>jl          <Plug>(easymotion-overwin-line)

" Replicate <Space>jJ onto <Space>jk (easier to type).
Noxmap   <Space>jk          <Plug>(easymotion-s2)
nmap     <Space>jk          <Plug>(easymotion-overwin-f2)
