#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr
from sniputil import put

# Snippets are now cleared in "clearsnippets" directory.
#put("clearsnippets\n")

# Title snippets.

def tsnip(trigger, desc, char, withOverline=False, flags="b", aliases=[],
        trimBody=True):
    """Title snippet."""

    line = "`!p snip.rv = len(t[1]) * %r`\n" % char

    body = ""
    if withOverline:
        body = body + line
    body = body + "${1:" + desc + "}\n" + line + "\n$0\n"

    snip(trigger, desc, body, flags, aliases=aliases, trimBody=trimBody)


tsnip("part",       "Part title",        "#", withOverline=True)
tsnip("chap",       "Chapter title",     "*", withOverline=True)
tsnip("sect",       "Section",           "=")
tsnip("subsec",     "Subsection",        "-")
tsnip("subsubsec",  "Sub-subsection",    "^")
tsnip("para",       "Paragraph",         '"')


# Directives.

bsnip("centered", "centered:: ...", r"""
.. centered:: ${1:line of text}

$0
""")

bsnip("code", "code block", r"""
.. code-block:: ${1:python}

   ${2:code goes here}

$0
""")

# Admonitions.

bsnip("warn", "Warning Admonition", r"""
.. warning::
   ${1:text goes here}

$0
""")

bsnip("note", "Note Admonition", r"""
.. note::
   ${1:text goes here}

$0
""")

# Markup.

wsnip("f", "File markup", r"""
:file:\`${1:path}\`$0
""")

