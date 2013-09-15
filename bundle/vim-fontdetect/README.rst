***********************************
fontdetect - detect installed fonts
***********************************

fontdetect helps Vim detect which fonts are installed on the system.
It works around limitations in Vim's getfontname() function.

For example (using GTK2 GUI)::

    if fontdetect#hasFontFamily("DejaVu Sans Mono")
        let &guifont = "DejaVu Sans Mono 14"
    endif

At present, the following platforms are supported:

- Linux (using GTK2 GUI)
- Windows
- Mac OS X

See documentation in doc/fontdetect.txt for installation instructions.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-fontdetect
