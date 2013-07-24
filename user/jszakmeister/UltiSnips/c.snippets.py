#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re

sys.path.append(
        os.path.join(os.path.dirname(__file__),
                     '..', '..', '..', 'UltiSnips'))

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


bsnip("com", "/* comment */", r"""
/* $1 */
""", flags="b!")
