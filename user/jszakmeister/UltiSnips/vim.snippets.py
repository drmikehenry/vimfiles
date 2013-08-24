#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re

def addSnipUtilDir():
    prevPath = None
    path = os.path.abspath(os.path.dirname(__file__))

    while path != prevPath:
        snipUtilPath = os.path.join(path, 'UltiSnips/sniputil.py')
        if os.path.exists(snipUtilPath):
            sys.path.insert(0, os.path.dirname(snipUtilPath))
            break

        prevPath = path
        path = os.path.dirname(path)

addSnipUtilDir()


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
