#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


put(r"""
priority -5

extends c
""")
