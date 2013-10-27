" Turn off GUI menu and scrollbars; keep these:
" - e: use GUI tab pages.
" - i: use an icon for the GUI.
set guioptions=ei

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
