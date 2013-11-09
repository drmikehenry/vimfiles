fun! cssswapit#CssSwapComplete(direction)

    let column = col(".")
    let line = getline(".")

    let keyword = &iskeyword
    setlocal iskeyword+=-
    let cur_word = expand('<cword>')
    if match (getline("."),"[0-9A-Za-z_-]\+\s*:\s*[0-9A-Za-z_-]\+")
        let temp_reg = @s
        let matches = csscomplete#CompleteCSS(0, substitute(strpart(getline('.'),0, col('.')),':[^:]*$'," : ",""))

        if index(matches,cur_word) != -1
            let word_index = index(matches, cur_word)

            if a:direction == 'forward'
                let word_index = (word_index + 1) % len(matches)
            else
                let word_index = (word_index - 1) % len(matches)
            endif

            if match (matches[word_index],'[^0-9A-Za-z_-]') != -1 "This is to stop url(
                return 0
            endif
            let @s = matches[word_index]

            exec 'norm viw"sp'
            exec "setlocal iskeyword=". keyword

            return 1
        endif

        let @s = temp_reg

    endif
    return 0
endfun

" modeline: {{{
" vim: expandtab softtabstop=4 shiftwidth=4 foldmethod=marker
