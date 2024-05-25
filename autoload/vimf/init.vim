" Init-time functions.

function! vimf#init#setupTitle()
    " Calculate the "instance" to use based on `v:servername`. On Vim, this is
    " the registered |client-server-name|, which can be overridden with the
    " |--servername| argument.  On Neovim, it is usually the named pipe created
    " by Nvim at |startup| or given by the |--listen| argument.
    let name = fnamemodify(v:servername, ":t")
    if name == ''
        if has('nvim')
            let name = 'NVIM'
        elseif has('gui_running')
            let name = 'GVIM'
        else
            let name = 'VIM'
        endif
    endif
    let &titlestring='%t%( %M%)%( (%{expand("%:~:h")})%)%a - ' . name
endfunction
