#!/usr/bin/env python3

import sys
import re
import setpypath

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr
from sniputil import put

put(
    r"""
priority -5

global !p
from sniputil import betterVisual
endglobal
"""
)

# Title snippets.


def tsnip(
    trigger, desc, char, withOverline=False, flags="b", aliases=[], trimBody=True
):
    """Title snippet."""

    # Dynamic overline or underline, based on the length of the title.
    dyn_line = "`!p snip.rv = len(t[1]) * %r`\n" % char

    body = "${1:`!p betterVisual(snip, default='" + desc + "')`}\n"

    if withOverline:
        overline = dyn_line
    else:
        overline = ""

    body = overline + body + dyn_line + "\n$0\n"

    snip(trigger, desc, body, flags, aliases=aliases, trimBody=trimBody)


tsnip("part", "Part title", "#", aliases=["h9"], withOverline=True)
tsnip("chap", "Chapter title", "*", aliases=["h0"], withOverline=True)
tsnip("sect", "Section", "=", aliases=["h1"])
tsnip("subsec", "Subsection", "-", aliases=["h2"])
tsnip("subsubsec", "Sub-subsection", "^", aliases=["h3"])
tsnip("para", "Paragraph", '"', aliases=["h4"])


# Directives.

bsnip(
    "centered",
    "centered:: ...",
    r"""
.. centered:: ${1:line of text}

$0
""",
)

bsnip(
    "code",
    "code block",
    r"""
.. code-block:: ${1:python}

  $0
""",
)

bsnip(
    "bash",
    "bash code block",
    r"""
.. code-block:: bash

  $0
""",
)

bsnip(
    "sh",
    "sh code block",
    r"""
.. code-block:: sh

  $0
""",
)

bsnip(
    "python",
    "python code block",
    r"""
.. code-block:: python

  $0
""",
    aliases=["py"],
)

bsnip(
    "ruby",
    "ruby code block",
    r"""
.. code-block:: ruby

  $0
""",
)

bsnip(
    "rust",
    "rust code block",
    r"""
.. code-block:: rust

  $0
""",
)

bsnip(
    "text",
    "text code block",
    r"""
.. code-block:: text

  $0
""",
)

bsnip(
    "l",
    "reference label",
    r"""
.. _${1:label}:
$0
""",
)

bsnip(
    "math",
    "math block",
    r"""
.. math::

  $0
""",
)

put(
    r"""
global !p
def snip_rst_footnoteAutoNumber(s):
    if s.isdigit() or s == "*":
        return ""
    return "#"

endglobal
"""
)

"""
For ``foot`` below:

The ``label_num_star_or_backspace`` will be selected.  Type desired footnote
label, overwriting the selection.  If the label is ``*`` or a decimal number,
the ``#`` will be removed; if the label is any other non-empty value (or if
the label is deleted by pressing Backspace), the ``#`` will be kept.  For
example::

.. [#text] After typing ``text`` and <Tab>.

.. [1234] After typing ``1234`` and <Tab>.

.. [*] After typing ``*`` and <Tab>.

.. [#] After typing <Backspace> and <Tab>.
"""

bsnip(
    "foot",
    "footnote description",
    r"""
.. [`!p snip.rv = snip_rst_footnoteAutoNumber(t[1])`""" +
    """${1:`!p betterVisual(snip, default='label_num_star_or_backspace')`}] $0
""",
)

bsnip(
    "img",
    "image",
    r"""
.. image:: ${1:`!p betterVisual(snip, default='path.*')`}

$0
""",
)

bsnip(
    "cimg",
    "centered image",
    r"""
.. image:: ${1:`!p betterVisual(snip, default='path.*')`}
    :align: center

$0
""",
)

# Admonitions.

bsnip(
    "warn",
    "Warning Admonition",
    r"""
.. warning::

  $0
""",
)

bsnip(
    "note",
    "Note Admonition",
    r"""
.. note::

  $0
""",
)

# Markup.

wsnip(
    "f",
    "File markup",
    r"""
:file:\`${1:`!p betterVisual(snip, default='filename')`}\`$0
""",
)

wsnip(
    "r",
    "Ref markup",
    r"""
:ref:\`${1:`!p betterVisual(snip, default='label')`}\`$0
""",
)

wsnip(
    "cmd",
    "Command markup",
    r"""
:command:\`${1:`!p betterVisual(snip, default='command')`}\`$0
""",
)

wsnip(
    "lit",
    "literal (code) markup",
    r"""
\`\`${1:`!p betterVisual(snip)`}\`\`$0
""",
)

snip(
    "`",
    "literal (code) markup",
    r"""
\`\`${1:`!p betterVisual(snip)`}\`\`$0
""",
    aliases=["``"],
)

wsnip(
    "m",
    "inline math",
    r"""
:math:\`${1:`!p betterVisual(snip)`}\`$0
""",
)

wsnip(
    "sub",
    "subscript",
    r"""
:sub:\`${1:`!p betterVisual(snip, default='subscript')`}\`$0
""",
)

wsnip(
    "sup",
    "superscript",
    r"""
:sup:\`${1:`!p betterVisual(snip, default='superscript')`}\`$0
""",
)

wsnip(
    "link",
    "link markup",
    r"""
\`${1:text} <${2:`!p betterVisual(snip, default='url')`}>\`_$0
""",
)

wsnip(
    "title",
    "title reference",
    r"""
:title:\`${1:`!p betterVisual(snip, default='title')`}\`$0
""",
)
