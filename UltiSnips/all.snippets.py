#!/usr/bin/env python3

import sys
import re
import setpypath

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr
from sniputil import put

put(
    r"""
priority -5

global !p
from sniputil import betterVisual
endglobal
"""
)

wsnip("date", "today's date YYYY-MM-DD", r"""`!v strftime("%Y-%m-%d")`""")
wsnip("datem", "today's date YYYY-MM", r"""`!v strftime("%Y-%m")`""")
