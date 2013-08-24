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
bsnip("sect", "Section", r"""
------------------------------------------------------------------------------
${1:NAME}`!p snip.rv = (57-len(t[1]))*' '+'*notes_'+t[1].lower()+'*'`
  ${2:Short description}`!p snip.rv = (55-len(t[2]))*' '`|${3:doc-ref}|

${0:Information goes here.}

Version ${4:version} from ${5:url}

Installation:
- Follow bundle installation instructions (|bundle_installation|).

""")
