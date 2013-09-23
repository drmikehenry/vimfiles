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

bsnip("ab", "Acked-by: ...", r"""
Acked-by: John Szakmeister <john@szakmeister.net>
""")

bsnip("sob", "Signed-off-by: ...", r"""
Signed-off-by: John Szakmeister <john@szakmeister.net>
""")

bsnip("rb", "Reviewed-by: ...", r"""
Reviewed-by: John Szakmeister <john@szakmeister.net>
""")
