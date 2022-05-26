#!/usr/bin/env python3

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

put(
    r"""
priority -5
"""
)

# 'if' snippets.
bsnip(
    "if",
    "if ... then ... end if;",
    r"""
if $1 then
    $0
end if;
""",
)

bsnip(
    "ifclk",
    "if clk'event and clk = '1' then ... end if;",
    r"""
if clk'event and clk = '1' then
    $0
end if;
""",
)

bsnip(
    "else",
    "else ...",
    r"""
else
    $0
""",
    aliases=["el"],
)

bsnip(
    "elsif",
    "elsif ... {...}",
    r"""
elsif $1
    $0
""",
    aliases=["ei"],
)

# Primitive types.
wabbr("slv", "STD_LOGIC_VECTOR ")
