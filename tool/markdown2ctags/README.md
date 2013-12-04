# markdown2ctags

This application generates ctags-compatible output for the sections of a
Markdown document.

The motivation was to have a tool fast enough to use with the
[TagBar](https://github.com/majutsushi/tagbar) plugin in Vim.

## Using with TagBar

To use this tool with TagBar, add the following into your `~/.vimrc`:

    " Add support for markdown files in tagbar.
    let g:tagbar_type_markdown = {
        \ 'ctagstype': 'markdown',
        \ 'ctagsbin' : '/path/to/markdown2ctags.py',
        \ 'ctagsargs' : '-f - --sort=yes',
        \ 'kinds' : [
            \ 's:sections',
            \ 'i:images'
        \ ],
        \ 'sro' : '|',
        \ 'kind2scope' : {
            \ 's' : 'section',
        \ },
        \ 'sort': 0,
    \ }

You'll need to have the TagBar plugin installed for this to work.  Also, you
make need to call the variable `g:tagbar_type_mkd` and change `ctagstype` to
`'mkd'` if you're Ben William's Markdown syntax highlighting script.  It sets
the file type to `mkd` whereas Tim Pope's sets it to `markdown`.

## License

This tool is licensed under a Simplified BSD license.  See ``LICENSE.txt`` for
details.
