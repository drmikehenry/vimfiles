#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re
import setpypath

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr
from sniputil import put

put(r"""
priority -5

global !p
from sniputil import autoPeriod
endglobal
""")

bsnip("#!", "#!/usr/bin/env python...", r"""
#!/usr/bin/env python
# vim:set fileencoding=utf8: #

""")

# 'if' snippets.

bsnip("if", "if ...:<CR>", r"""
if $1:
    $0
""")

bsnip("else", "else:<CR>", r"""
else:
    $0
""", aliases=["el"])

bsnip("elif", "elif ...:<CR>", r"""
elif $1:
    $0
""", aliases = ["ei"])

babbr("im", "import ")
babbr("from", "from ${1:module} import $0")

bsnip("ifmain", "if __name__ == '__main__':...", r"""
if __name__ == '__main__':
    ${1:main()}
""")

## @todo Include arguments in docstring.
bsnip("def", "def func(...):...", r'''
def ${1:funcName}($2):
    """${3:Description of function $1}`!p snip.rv = autoPeriod(t[3])`"""
    ${4:pass}
''', aliases=["func"])

# @todo Consider other __xxx__ words for popup menu, or perhaps
# just one with "__$1{init}__".
wsnip("__", "__init__", "__${1:init}__")

# try/except/finally

bsnip("try", "try/except", r"""
try:
    ${1:pass}
except ${2:Exception}, e:
    ${3:raise e}
""", aliases=["trye"])

bsnip("tryf", "try/finally", r"""
try:
    ${1:pass}
finally:
    ${2:pass}
""")

bsnip("tryef", "try/except/finally", r"""
try:
    ${1:pass}
except ${2:Exception}, e:
    ${3:raise e}
finally:
    ${4:pass}
""")

bsnip("tryee", "try/except/else", r"""
try:
    ${1:pass}
except ${2:Exception}, e:
    ${3:raise e}
else:
    ${4:pass}
""")

bsnip("tryeef", "try/except/else/finally", r"""
try:
    ${1:pass}
except ${2:Exception}, e:
    ${3:raise e}
else:
    ${4:pass}
finally:
    ${5:pass}
""")

bsnip("except", "except", r"""
except ${1:Exception}, e:
    ${2:raise e}

""", aliases=["exc"])

bsnip("finally", "finally", r"""
finally:
    $0
""", aliases=["fin"])

bsnip("class", "class definition", r'''
class ${1:MyClass}(${2:object}):
    """${3:Docstring for $1}`!p snip.rv = autoPeriod(t[3])`"""

    def __init__(self${4/([^,])?(.*)/(?1:, )/}${4:arg}):
        """
        @todo Document $1.__init__ (along with arguments).
${4/.+/(?0:\\n)/}${4/(\A\s*,\s*\Z)|,?\s*([A-Za-z_][A-Za-z0-9_]*)\s*(=[^,]*)?(,\s*|$)/(?2:        $2 - @todo Document argument $2.\\n)/g}        """
${2/object$|(.+)/(?1:        $0.__init__\(self\)\\n\\n)/}${4/(\A\s*,\s*\Z)|,?\s*([A-Za-z_][A-Za-z0-9_]*)\s*(=[^,]*)?(,\s*|$)/(?2:        self._$2 = $2\\n)/g}
''', aliases=["cl"])

# @todo Consider "cm" for "classmethod(method)".

bsnip("for", "for i in ...", r"""
for ${1:i} in ${2:range(${3:10})}:
    ${4:pass}
""")

bsnip("while", "while expr:...", r"""
while ${1:True}:
    ${4:pass}
""", aliases=["wh"])


babbr("as", "assert $0")

bsnip("ae", "self.assertEqual(..., ...)", r"""
self.assertEqual(${1:first}, ${2:second})
""")

bsnip("at", "self.assertTrue(...)", r"""
self.assertTrue(${1:expression})
""")

bsnip("af", "self.assertFalse(...)", r"""
self.assertFalse(${1:expression})
""")

bsnip("aae", "self.assertAlmostEqual(..., ...)", r"""
self.assertAlmostEqual(${1:first}, ${2:second})
""")

bsnip("ar", "self.assertRaises(..., ...)", r"""
self.assertRaises(${1:exception}, ${2:func}${3/.+/, /}${3:arguments})
""")

bsnip("property", "property", r'''
def ${1:propName}():
    doc = """${2:Docstring for $1}`!p snip.rv = autoPeriod(t[2])`"""
    def fget(self):
        return self._$1
    def fset(self, value):
        self._$1 = value
    return locals()
$1 = property(**$1())

''', aliases=["@property", "prop", "@prop"])

bsnip("pdb", "pdb.set_trace()", r"""
import pdb; pdb.set_trace()
""")

# Template for a new .snippets.py file.
bsnip("template_python.snippets.py", "new snippet template", r"""
#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

$0
""")

# @todo Snippets for print, logging, formatting strings "%d,%d" % (a,b).
'''

exec "Snippet pr    print '".st."s".et."'".st."s:PyHashArgList(Count(@z, '%[^%]'))".et."<CR>".st.et

" Improve this to look backward at the previous string instead of having
" to type the % before the format string.
exec "Snippet % '".st."s".et."'".st."s:PyHashArgList(Count(@z, '%[^%]'))".et.st.et

exec "Snippet bc \"\"\"".st.et."<CR>\"\"\"<CR>".st.et
snippet . "self." i
self.
endsnippet

'''
