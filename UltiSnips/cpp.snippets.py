#!/usr/bin/env python3

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

put(r"""
priority -5

global !p
from sniputil import betterVisual
endglobal
""")

put(r"""
extends c
""")

bsnip("str", r"""std::string""", r"""
std::string $0
""")

bsnip("vec", r"""std::vector<xxx> """, r"""
std::vector<$1> $0
""")

bsnip("cout", r"""std::cout << XXX << std::endl;""", r"""
std::cout << $0 << std::endl;
""")
