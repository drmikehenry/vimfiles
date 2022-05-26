#!/usr/bin/env python3

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

put(r"""
priority -5
""")

wsnip("ca", "$(call ","""
$(call $0
""", aliases=["call"])

wsnip("cs", "$(call S.","""
$(call S.$0
""", aliases=[])

wsnip("v", "$(","""
$($0
""", aliases=[])

wsnip("vs", "$(S.","""
$(S.$0
""", aliases=[])

wsnip("fi", "$(filter ","""
$(filter $0
""", aliases=[])

wsnip("fo", "$(filter-out ","""
$(filter-out $0
""", aliases=[])


bsnip("def", "define ...endef","""
define $0
endef
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

wsnip("if", "$(if ","""
$(if $0
""", aliases=[])

wsnip("ie", "ifeq '$1' $'2' ... endif","""
ifeq '$1' '$2'
  $0
endif
""", aliases=["ifeq"])

wsnip("eie", "else ifeq '$1' $'2'","""
else ifeq '$1' '$2'
  $0
""", aliases=[])

wsnip("ine", "ifneq '$1' $'2' ... endif","""
ifneq '$1' '$2'
  $0
endif
""", aliases=["ifneq"])

wsnip("eine", "else ifenq '$1' $'2'","""
else ifneq '$1' '$2'
  $0
""", aliases=[])

wsnip("i", "_if ... endif","""
_if $0
endif
""", aliases=[])

wsnip("ei", "else _if","""
else _if $0
""", aliases=[])

wsnip("in", "_ifNot ... endif","""
_ifNot $0
endif
""", aliases=[])

wsnip("ein", "else _ifNot","""
else _ifNot $0
""", aliases=[])

wsnip("ib", "_ifBool ... endif","""
_ifBool $0
endif
""", aliases=[])

wsnip("eib", "else _ifBool","""
else _ifBool $0
""", aliases=[])

wsnip("inb", "_ifNotBool ... endif","""
_ifNotBool $0
endif
""", aliases=[])

wsnip("einb", "else _ifNotBool","""
else _ifNotBool $0
""", aliases=[])

wabbr("t","$(true)")
wabbr("f","$(false)")
wabbr("e","$(empty)")
