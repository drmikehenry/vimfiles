" Python virtual environment-related functions.

function! vimf#venv#binPath(venv)
    if has('win32')
        let binPath = a:venv . '\Scripts'
    else
        let binPath = a:venv . '/bin'
    endif
    return binPath
endfunction

function! vimf#venv#isValid(venv)
    let activatePath = vimf#path#absolute(a:venv . '/pyvenv.cfg')
    return filereadable(activatePath)
endfunction

function! vimf#venv#info()
    if $VIRTUAL_ENV != ''
        echo 'venv at ' . $VIRTUAL_ENV
    else
        echo 'venv inactive'
    endif
endfunction

function! vimf#venv#stopLsp()
    if exists(':LspRestart')
        " Neovim-only:
        LspRestart
    else
        " Vim-only:
        LspStop
    endif
endfunction

function! vimf#venv#deactivate()
    let venv=$VIRTUAL_ENV
    if venv != ''
        let $PATH = vimf#mpath#remove($PATH, vimf#venv#binPath(venv))
        unlet $VIRTUAL_ENV
        call vimf#venv#stopLsp()
        echo 'deactivated ' . venv
    else
        echo 'no active venv'
    endif
endfunction

" Probe at `dir` for a valid Python virtual environment.
" - Returned path is '' if no venv found; absolute path of venv otherwise.
" Will probe first for `.venv` and `venv` subdirectories of `dir` and use them
" if they are valid.
function! vimf#venv#probe(dir)
    let venv = ''
    let subdirs = ['.venv', 'venv', '.']
    while len(subdirs) > 0
        let subdir = remove(subdirs, 0)
        let p = vimf#path#absolute(a:dir . '/' . subdir)
        if vimf#venv#isValid(p)
            let venv = p
            break
        endif
    endwhile
    return venv
endfunction

function! vimf#venv#activate(venv)
    let root = a:venv
    if root == ''
        let root = fnamemodify(vimf#path#absolute(expand('%')), ':h')
        while 1
            let venv = vimf#venv#probe(root)
            if venv != ''
                break
            endif
            let oldRoot = root
            let root = vimf#path#parent(root)
            if root == oldRoot
                break
            endif
        endwhile
    else
        let venv = vimf#venv#probe(vimf#path#absolute(root))
    endif

    if venv == ''
        if a:venv
            echo 'venv invalid: ' . a:venv
        else
            echo 'venv not found'
        endif
        return
    endif

    " `venv` is an absolute path of a Python virtual environment.

    call vimf#venv#stopLsp()
    if $VIRTUAL_ENV != ''
        let $PATH = vimf#mpath#remove($PATH, vimf#venv#binPath($VIRTUAL_ENV))
    endif
    let $VIRTUAL_ENV = venv
    let binPath = vimf#venv#binPath(venv)
    let $PATH = vimf#mpath#join([binPath, $PATH])
    echo 'activated ' . venv
endfunction
