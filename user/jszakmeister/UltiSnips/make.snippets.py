#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

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
