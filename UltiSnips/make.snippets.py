#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

wsnip("call", "$(call )","""
$(call $0)
""", aliases=["c"])

wsnip("v", "$()","""
$($0)
""", aliases=[])

bsnip("def", "define funcName...endef $(call S.def,funcName)","""
define $1
  $0
endef
$(call S.def,$1)
""", aliases=[])

put(r"""
global !p
def makeParamComments(nameAndArgs):
    numArgs = len(nameAndArgs.split(",")) - 1

    s = ""
    for i in range(numArgs):
        s += "\n#   $%d - " % (i + 1)

    return s
endglobal
""")

bsnip("func", "$(call S.func,funcName,...)... $(call S.endFunc)","""
$(call S.func,$1)
# $2`!p snip.rv = makeParamComments(t[1])`
define ${1/,.*//}
  $0
endef
$(call S.endFunc)
""", aliases=[])

wsnip("if", "$(if $1,$0)","""
$(if $1,$0)
""", aliases=[])

bsnip("ife", "ifeq '$1' $'2' ... endif","""
ifeq '$1' '$2'
  $0
endif
""", aliases=["ifeq"])

bsnip("ifn", "ifneq '$1' $'2' ... endif","""
ifneq '$1' '$2'
  $0
endif
""", aliases=["ifne", "ifneq"])

bsnip("ei", "else ifeq '$1' $'2' ... endif","""
else ifeq '$1' '$2'
  $0
""", aliases=["eie", "eieq"])

bsnip("ein", "else ifenq '$1' $'2' ... endif","""
else ifneq '$1' '$2'
  $0
""", aliases=["eine", "eineq"])

wabbr("t","$(true)")
wabbr("f","$(false)")
wabbr("e","$(empty)")
