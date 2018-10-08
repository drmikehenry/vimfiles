*********
rst2ctags
*********

This application generates ctags-compatible output for the sections of a
reStructuredText document.  It does *not* use the docutils engine since docutils
is far too slow for my needs.

The motivation was to have a tool fast enough to use with the `TagBar
<https://github.com/majutsushi/tagbar>`_ plugin in Vim.

Using with TagBar
=================

To use this tool with TagBar, add the following into your ``~/.vimrc``::

    " Add support for reStructuredText files in tagbar.
    let g:tagbar_type_rst = {
        \ 'ctagstype': 'rst',
        \ 'ctagsbin' : '/path/to/rst2ctags.py',
        \ 'ctagsargs' : '-f - --sort=yes --sro=»',
        \ 'kinds' : [
            \ 's:sections',
            \ 'i:images'
        \ ],
        \ 'sro' : '»',
        \ 'kind2scope' : {
            \ 's' : 'section',
        \ },
        \ 'sort': 0,
    \ }

License
=======

This tool is licensed under a Simplified BSD license.  See ``LICENSE.txt`` for
details.
