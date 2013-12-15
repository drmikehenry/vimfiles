#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


# Templates

bsnip("template_python.snippets.py", "new snippet template", r"""
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

$0
""", flags="!")


bsnip("screrr", "ScriptError", r"""
class ScriptError(Exception):
    pass

$0
""", aliases=['se'])

wsnip("xrange", "xrange", r"""
xrange($1)$0
""", aliases = ['xr'])

bsnip("rre", "raise RuntimeError()", r"""
raise RuntimeError($1)$0
""")
