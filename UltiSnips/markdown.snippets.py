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
from sniputil import betterVisual
endglobal
""")

bsnip("code", "code block", r"""
\`\`\`${1:python}
$0
\`\`\`
""")

bsnip("bash", "bash code block", r"""
\`\`\`bash
$0
\`\`\`
""")

bsnip("sh", "sh code block", r"""
\`\`\`sh
$0
\`\`\`
""")

bsnip("python", "python code block", r"""
\`\`\`python
$0
\`\`\`
""", aliases=['py'])

bsnip("ruby", "ruby code block", r"""
\`\`\`ruby
$0
\`\`\`
""")

bsnip("rust", "rust code block", r"""
\`\`\`rust
$0
\`\`\`
""")

bsnip("text", "text code block", r"""
\`\`\`
$0
\`\`\`
""")
