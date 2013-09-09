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

# Markup

wsnip("lit", "literal (code) markup", r"""
\`\`${1:literal}\`\`$0
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
