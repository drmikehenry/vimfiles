" Plugin for modifying guifont size.

" Note that Neovim always returns false for `has('gui')`, but
" `has('gui_running')` returns true for Neovim GUIs (at least for
" `nvim-qt` and `neovide`).
if exists("loaded_fontsize") || !has('gui_running')
    finish
endif
let loaded_fontsize = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

if !hasmapto("<Plug>FontsizeBegin")
    nmap <silent> <Leader><Leader>=  <Plug>FontsizeBegin
endif

if !hasmapto("<Plug>FontsizeInc", "n")
    nmap <silent> <Leader><Leader>+  <Plug>FontsizeInc
endif

if !hasmapto("<Plug>FontsizeDec", "n")
    nmap <silent> <Leader><Leader>-  <Plug>FontsizeDec
endif

if !hasmapto("<Plug>FontsizeDefault", "n")
    nmap <silent> <Leader><Leader>0  <Plug>FontsizeDefault
endif

" "font size" mode mappings are inspired by the bufmru.vim plugin.
" The concept is to enter a "mode" via an initial mapping.  Once
" in this mode, some mode-specific keystrokes now behave as if they
" were mapped.  When time-outs are enabled (see g:fontsize_timeout), the
" new "mode" times out and the new "mappings" are effectively turned off.
"
" This emulation of a "mode" is accomplished via a clever technique
" wherein each operation terminates with a partial mapping to <SID>(fontsize).
" Each new keystroke completes a mapping that itself terminates with
" <SID>(fontsize), keeping an extensible chain of mappings going as long as
" they arrive before g:fontsize_timeoutlen milliseconds elapses between
" keystrokes.  The string "(fontsize)" is chosen to take the entire ten
" characters of space available for Vim's 'showcmd' option.  It provides better
" visual appearance than <SID>m_, which comes out looking something like
" 80>yR91_m_.

" Externally mappable mappings to internal mappings.
nmap <silent> <Plug>FontsizeBegin       <SID>begin<SID>(fontsize)
nmap <silent> <Plug>FontsizeInc         <SID>inc<SID>(fontsize)
nmap <silent> <Plug>FontsizeDec         <SID>dec<SID>(fontsize)
nmap <silent> <Plug>FontsizeDefault     <SID>default<SID>(fontsize)
nmap <silent> <Plug>FontsizeSetDefault  <SID>setDefault<SID>(fontsize)
nmap <silent> <Plug>FontsizeQuit        <SID>quit

" "Font size" mode mappings.  (fontsize)<KEY> maps <KEY> in "font size" mode.
nmap <silent> <SID>(fontsize)+        <SID>inc<SID>(fontsize)
nmap <silent> <SID>(fontsize)=        <SID>inc<SID>(fontsize)
nmap <silent> <SID>(fontsize)-        <SID>dec<SID>(fontsize)
nmap <silent> <SID>(fontsize)0        <SID>default<SID>(fontsize)
nmap <silent> <SID>(fontsize)!        <SID>setDefault<SID>(fontsize)
nmap <silent> <SID>(fontsize)q        <SID>quit
nmap <silent> <SID>(fontsize)<SPACE>  <SID>quit
nmap <silent> <SID>(fontsize)<CR>     <SID>quit
nmap <silent> <SID>(fontsize)         <SID>quit

" Action mappings.
nnoremap <silent> <SID>begin       :<C-u>call fontsize#begin()<CR>
nnoremap <silent> <SID>inc         :<C-u>call fontsize#inc()<CR>
nnoremap <silent> <SID>dec         :<C-u>call fontsize#dec()<CR>
nnoremap <silent> <SID>default     :<C-u>call fontsize#default()<CR>
nnoremap <silent> <SID>setDefault  :<C-u>call fontsize#setDefault()<CR>
nnoremap <silent> <SID>quit        :<C-u>call fontsize#quit()<CR>

function! Fontsize_cmd(size)
    let fontName = fontsize#getFontName()
    let oldSize = fontsize#getSize(fontName)
    if a:size == ''
        redraw
        echo 'Font size ' . oldSize
        return
    endif

    let float_vregex = '%(\d+%(\.\d*)?|\.\d+)'
    let regex = '\v^[-+]?' . float_vregex . '$'
    if a:size !~ regex
        echo 'Invalid size ' . a:size
        return
    endif

    let relative = (a:size =~ '\v^[-+]')
    if relative
        if has('float') && 0
            let delta = str2float(a:size)
        elseif a:size =~ '\.'
            echo 'No floating point feature for relative size ' . a:size
            return
        else
            let delta = str2nr(a:size)
        endif
        let newSize = fontsize#addSize(oldSize, delta)
    else
        let newSize = a:size
    endif
    call fontsize#setFontName(fontsize#setSize(fontName, newSize))
    call fontsize#setFontNameWide(fontsize#setSize(&guifontwide, newSize))
endfunction

if !exists('g:fontsize#defineFontsizeCommand')
    let g:fontsize#defineFontsizeCommand = 1
endif

if g:fontsize#defineFontsizeCommand
    command! -nargs=? Fontsize call Fontsize_cmd(<q-args>)
endif

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
