function! Sunmap(...)
    for k in a:000
        for b in ["", "<buffer> "]
            try
                exec "sunmap " . b . escape(k, '|')
            catch /^Vim(.*):E31:/
            endtry
        endfor
    endfor
endfunction

function! SmapShow()
    let oldA = @a
    redir @a
    silent smap
    redir END
    let result = @a
    let @a = oldA
    for line in split(result, "\n")
        let s = substitute(line, '^...\(\S\+\).*', '\1', '')
        if match(s, '^\c<plug>') == -1
            echo s
        endif
    endfor
endfunction

function! VmapShow()
    let oldA = @a
    redir @a
    silent verbose smap
    redir END
    let result = @a
    let @a = oldA
    let matched = 0
    for line in split(result, "\n")
        if matched
            let matched = 0
            echo line
        elseif match(line, '^v') != -1
            let s = substitute(line, '^...\(\S\+\).*', '\1', '')
            if match(s, '^\c<plug>') == -1
                echo s
                let matched = 1
            endif
        endif
    endfor
endfunction

function! SunmapAll()
    Sunmap %
    Sunmap //
    Sunmap ??
    Sunmap [%
    Sunmap \be
    Sunmap \bs
    Sunmap \bv
    Sunmap \c
    Sunmap \n
    Sunmap \p
    Sunmap \rh
    Sunmap \rv
    Sunmap \rwp
    Sunmap \swp
    Sunmap \x
    Sunmap ]%
    Sunmap a%
    Sunmap ai
    Sunmap aI
    Sunmap g%
    Sunmap ii
    Sunmap iI
    Sunmap ["
    Sunmap [[
    Sunmap []
    Sunmap ]"
    Sunmap ][
    Sunmap ]]
endfunction

command! -nargs=+ Sunmap call Sunmap(<f-args>)
command! -nargs=0 SmapShow call SmapShow()
command! -nargs=0 VmapShow call VmapShow()
command! -nargs=0 SunmapAll call SunmapAll()

SunmapAll
