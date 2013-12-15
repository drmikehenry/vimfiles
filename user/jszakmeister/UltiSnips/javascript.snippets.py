#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

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
