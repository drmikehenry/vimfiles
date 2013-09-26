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

bsnip("ifeq", "ifeq (...) / endif", r"""
ifeq ($1,$2)
    $0
endif
""", flags="!")

bsnip("ifneq", "ifneq (...) / endif", r"""
ifneq ($1,$2)
    $0
endif
""", flags="!")

bsnip("ifdef", "ifdef var / endif", r"""
ifdef $1
    $0
endif
""", flags="!")

bsnip("ifndef", "ifndef var / endif", r"""
ifndef $1
    $0
endif
""", flags="!")

bsnip("ifempty", "ifeq ($(VAR),) / endif", r"""
ifeq ($($1),)
    $0
endif
""", aliases=["ifem"], flags="!")
