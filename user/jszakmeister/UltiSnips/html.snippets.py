#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr

bsnip("pre", "pre", r"""
<pre>
$0
</pre>
""")

wsnip("code", "code", r"""
<code>$1</code>$0
""")
