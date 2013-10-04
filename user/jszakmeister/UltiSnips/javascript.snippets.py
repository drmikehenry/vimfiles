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

bsnip("foreach", "for (var i in VAR)", r"""
for (var ${1:i} in ${2:VAR}) {
    $0
}""")

bsnip("func", "function func()", r"""
function ${1:name}($2) {
    $0
}""")

wsnip("anon", "anonymous fn", r"""
function(${1:args}) {
    $0
}""", aliases=["fn"])

bsnip("var", "var VAR = EXPR", r"""
var ${1:name} = $0
""")

wsnip("emfn", "empty function", r"""
function(${1:args}) {};
""")
