" vim:tw=80:ts=4:sts=4:sw=4:et:ai

" On all terminals, have F1 through F12 and S-F3 through S-F8.

if $TERM =~ "^putty"

    " Default mode (ESC [n~).
    map <ESC>[11~ <F1>
    map <ESC>[12~ <F2>
    map <ESC>[13~ <F3>
    map <ESC>[14~ <F4>
    map <ESC>[15~ <F5>
    map <ESC>[17~ <F6>
    map <ESC>[18~ <F7>
    map <ESC>[19~ <F8>
    map <ESC>[20~ <F9>
    map <ESC>[21~ <F10>
    map <ESC>[23~ <F11>
    map <ESC>[24~ <F12>
    map! <ESC>[11~ <F1>
    map! <ESC>[12~ <F2>
    map! <ESC>[13~ <F3>
    map! <ESC>[14~ <F4>
    map! <ESC>[15~ <F5>
    map! <ESC>[17~ <F6>
    map! <ESC>[18~ <F7>
    map! <ESC>[19~ <F8>
    map! <ESC>[20~ <F9>
    map! <ESC>[21~ <F10>
    map! <ESC>[23~ <F11>
    map! <ESC>[24~ <F12>

    " For unfathomable reasons, <S-F1> and <S-F2> are the same as
    " <F11> and <S-F12>, so they are skipped.
    map <ESC>[25~ <S-F3>
    map <ESC>[26~ <S-F4>
    map <ESC>[28~ <S-F5>
    map <ESC>[29~ <S-F6>
    map <ESC>[31~ <S-F7>
    map <ESC>[32~ <S-F8>
    map <ESC>[33~ <S-F9>
    map <ESC>[34~ <S-F10>
    map! <ESC>[25~ <S-F3>
    map! <ESC>[26~ <S-F4>
    map! <ESC>[28~ <S-F5>
    map! <ESC>[29~ <S-F6>
    map! <ESC>[31~ <S-F7>
    map! <ESC>[32~ <S-F8>
    map! <ESC>[33~ <S-F9>
    map! <ESC>[34~ <S-F10>
endif

if $TERM == "linux"
    map <ESC>[[A <F1>
    map <ESC>[[B <F2>
    map <ESC>[[C <F3>
    map <ESC>[[D <F4>
    map <ESC>[[E <F5>
    map <ESC>[17~ <F6>
    map <ESC>[18~ <F7>
    map <ESC>[19~ <F8>
    map <ESC>[20~ <F9>
    map <ESC>[21~ <F10>
    map <ESC>[23~ <F11>
    map <ESC>[24~ <F12>
    map! <ESC>[[A <F1>
    map! <ESC>[[B <F2>
    map! <ESC>[[C <F3>
    map! <ESC>[[D <F4>
    map! <ESC>[[E <F5>
    map! <ESC>[17~ <F6>
    map! <ESC>[18~ <F7>
    map! <ESC>[19~ <F8>
    map! <ESC>[20~ <F9>
    map! <ESC>[21~ <F10>
    map! <ESC>[23~ <F11>
    map! <ESC>[24~ <F12>

    map <ESC>[25~ <S-F1>
    map <ESC>[26~ <S-F2>
    map <ESC>[28~ <S-F3>
    map <ESC>[29~ <S-F4>
    map <ESC>[31~ <S-F5>
    map <ESC>[32~ <S-F6>
    map <ESC>[33~ <S-F7>
    map <ESC>[34~ <S-F8>
    " The linux console doesn't provide <S-F9> through <S-F12>.
    map! <ESC>[25~ <S-F1>
    map! <ESC>[26~ <S-F2>
    map! <ESC>[28~ <S-F3>
    map! <ESC>[29~ <S-F4>
    map! <ESC>[31~ <S-F5>
    map! <ESC>[32~ <S-F6>
    map! <ESC>[33~ <S-F7>
    map! <ESC>[34~ <S-F8>
endif
