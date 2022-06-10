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

" Execute linehash on current file into ~/tmp/linehash.out, automatically
" reloading that file.  Preserves the window layout.
function Linehash()
    let savePos=winsaveview()
    wall
    silent !linehash % > ~/tmp/linehash.out
    checktime
    call winrestview(savePos)
endfunction

nnoremap <f8> :silent call Linehash()<CR>
imap <f8> <esc><f8>

" Mapping for reviewing code in a Markdown document.
xnoremap q y:call CreateReviewEntry()<CR>
function! CreateReviewEntry()
    let text = '    ' . expand('%') . ':' . line('.') . "::\n\n"
    let text .= '```' . &filetype . "\n" . getreg('0') . "```\n\n\n"
    call setreg('"', text, 'V')
    call setreg('0', text, 'V')
    call setreg('+', text, 'V')
    call setreg('*', text, 'V')
endfunction

" Experiment with 'splitright'.
set splitright

" Experimental overwin-based mappings.
nmap     <Space>jj          <Plug>(easymotion-overwin-f)
nmap     <Space>jJ          <Plug>(easymotion-overwin-f2)
nmap     <Space>jl          <Plug>(easymotion-overwin-line)

" Replicate <Space>jJ onto <Space>jk (easier to type).
Noxmap   <Space>jk          <Plug>(easymotion-s2)
nmap     <Space>jk          <Plug>(easymotion-overwin-f2)
