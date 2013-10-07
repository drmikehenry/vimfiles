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

bsnip("docstring", "docstring for func or type", r"""
/**
 *  ${1:Brief description.}
 *
 *  ${0:Full description.}
 */
""", flags="b!", aliases=["doc", "/**"])

# Javadoc.
wabbr("@param",     "@param ${1:inParam}  ${0:@todo Description of $1.}",
        aliases=["@p", "@pi", "@po", "@pio"])
wabbr("@return",    "@return ", aliases=["@re", "@ret", "@retval", "@rv"])
wabbr("todo",  "/** @todo ${1:Description of what's TO DO.} */")
wabbr("bug",   "/** @bug ${1:Description of BUG.} */")
