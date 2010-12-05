" Routines for embedding a syntax highlighting group into the current
" syntax highlighting in effect.

function! SyntaxInclude(group, syntaxType)
    " Executes the following commands:
    "   syntax include @<group> syntax/<syntaxType>.vim
    "   syntax include @<group> after/syntax/<syntaxType>.vim
    " Preserves existing b:current_syntax.

    if exists('b:current_syntax')
        let savedSyntax = b:current_syntax
        unlet b:current_syntax
    endif

    let cmd = 'syntax include @' . a:group
    let syntaxName = a:syntaxType . '.vim'

    execute cmd . ' syntax/' . syntaxName
    try
        execute cmd . ' after/syntax/' . syntaxName
    catch
    endtry
    if exists('savedSyntax')
        let b:current_syntax = savedSyntax
    else
        unlet b:current_syntax
    endif
endfunction
