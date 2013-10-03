**************************************************************
Extline - plugin for extending lines (e.g., underlined titles)
**************************************************************

When writing titles in a plain text document, a common convention is to use
repeated punctuation characters to draw lines under (and sometimes over) the
title text.  This plugin helps maintain those title lines more easily, and
it provides support for standalone horizontal lines as well.

Titles are marked up in a manner compatible with reStructuredText[1], and the
various heading levels are chosen to coincide with the Sphinx[2] project's
conventions as follows::

    ##############
    Part (level 9)
    ##############

    *****************
    Chapter (level 0)
    *****************

    Section (level 1)
    =================

    Subsection (level 2)
    --------------------

    Subsubsection (level 3)
    ^^^^^^^^^^^^^^^^^^^^^^^

    Paragraph (level 4)
    """""""""""""""""""

    Level-5 heading
    '''''''''''''''

Extline provides methods for adding these lines, adjusting them to fit as the
section names changes, and for converting one level to another.

[1]: http://docutils.sourceforge.net/rst.html
[2]: http://sphinx-doc.org/

See documentation in doc/extline.txt for installation, customization, and
usage instructions.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-extline
