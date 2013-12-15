#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


# Section heading
bsnip("sect", "section heading (===)", r"""
" =============================================================
" ${1:Section Heading}
" =============================================================

$0
""")

# Subsection heading
bsnip("subsec", "subsection heading (---)", r"""
" -------------------------------------------------------------
" ${1:Subsection Heading}
" -------------------------------------------------------------

$0
""")

bsnip("func", "function()", r"""
function! ${1:name}($2)
    $0
endfunction
""")
