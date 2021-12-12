if !exists('g:VimfilesFiletypeReady')
    finish
endif
" The highlight group pythonDot applies to a dot in a Python dotted name (e.g.,
" sys.stdout).  By default, this is mapped to the group Normal.  When Gvim is
" using a dark background, making a :hardcopy ends up using a dark background
" color when printing the dot character.  This is a general problem with using
" a screen colorscheme for printing on paper.  The general solution appears to
" be to create a hardcopy colorscheme, set it temporarily just while printing,
" then restore the old colorscheme; however, since this problem occurs only for
" the dot in Python, it's easier to simply unlink pythonDot from the Normal
" group, since an unlinked group still inherits the right colors on-screen.
hi link pythonDot NONE
