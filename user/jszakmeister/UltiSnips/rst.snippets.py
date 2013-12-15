#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


# Status template
bsnip("status", "status template", r"""
`!v strftime("%d %b")` - `!v strftime("%d %b", localtime()+604800)`
===============


Accomplishments
---------------

* $0


Pending
^^^^^^^


Future
------


Issues
------

* None.


Time Off
--------

* None.
""")

# Backlog template
bsnip("backlog", "backlog template", r"""
Backlog
=======

Priorities
----------

* $0


Recently Finished
-----------------


Under Development
-----------------


Follow-up On
------------


Follow-up On (previously discussed)
-----------------------------------


Future Work
-----------


Not Ready to Act On
-------------------


Not Fully Determined
^^^^^^^^^^^^^^^^^^^^


Other Issues
------------
""")

bsnip("sh", "sh code block", r"""
.. code-block:: sh

    $0
""", flags="!")

bsnip("text", "text code block", r"""
.. code-block:: text

    $0
""", flags="!")

bsnip("math", "math block", r"""
.. math::

    $0
""")

bsnip("foot", "footnote description", r"""
.. [${1:label}] $0
""")

bsnip("img", "image", r"""
.. image:: ${1:path.*}

$0
""")

bsnip("cimg", "centered image", r"""
.. image:: ${1:path.*}
    :align: center

$0
""")

# Markup

wsnip("lit", "literal (code) markup", r"""
\`\`${1:`!p betterVisual(snip)`}\`\`$0
""")

wsnip("m", "inline math", r"""
:math:\`$1\`$0
""")

wsnip("sup", "superscript", r"""
:sup:\`$1\`$0
""")

# Handy helpers (for me).

wsnip("done", "[DONE]", r"""
\`\`[DONE]\`\` $0
""")

wsnip("res", "[RESOLVED]", r"""
\`\`[RESOLVED]\`\` $0
""")

wsnip("start", "started <date>", r"""
\`\`[started ${1:`!v strftime("%Y-%m-%d")`}]\`\` $0
""")
