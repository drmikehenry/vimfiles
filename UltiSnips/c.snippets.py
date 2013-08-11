#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


# Snippets are now cleared in "clearsnippets" directory.
#put("clearsnippets\n")

put(r"""
global !p
def better_visual(snip):
    import textwrap, vim

    n = vim.current.window.cursor[1] / int(vim.eval('&shiftwidth'), 10)
    text = textwrap.dedent(snip.v.text)

    lines = []
    for i, line in enumerate(text.splitlines()):
        lines.append(snip.mkline(line))
        if i == 0:
            snip >> n
    return '\n'.join(lines)
endglobal
""")

# 'if' snippets.
bsnip("if", "if (...) {...}", r"""
if ($1)
{
    `!p snip.rv = better_visual(snip)`$0
}
""")

bsnip("else", "else {...}", r"""
else
{
    `!p snip.rv = better_visual(snip)`$0
}
""", aliases=["el"])

bsnip("elif", "else if (...) {...}", r"""
else if ($1)
{
    `!p snip.rv = better_visual(snip)`$0
}
""", aliases = ["ei"])

# Loop snippets.

bsnip("while", "while (...) {...}", r"""
while ($1)
{
    `!p snip.rv = better_visual(snip)`$0
}
""", aliases=["wh"])

bsnip("fore", "for (;;) {...}", r"""
for (;;)
{
    `!p snip.rv = better_visual(snip)`$0
}
""", aliases=["forever"])

"""
Features of the "for" snippet:
- In first tab stop, can press "=" to change 
  initializer or ";" to remove initializer;
- In second tab stop, can press different comparison
  (e.g, < <= > >= != ==) to override the default "<". When
  choosing "<", the third field defaults to var--; 

More ideas:

- In first and second fields, can behave differently if ";" is pressed.
- A leading space in fields two and three can suppress pre-supplied text.

For expr1:
    "...=..." ==> suppress " = 0"
    "...;..." ==> suppress final ";"
    "" ==> empty

For expr2:
    "[<>!=]..." ==> override "< ", change default "++"
    " ..." ==> remove "expr1 < "
    "[.]..." ==> override " < "

For expr3:
    " ..." ==> remove " expr1"

With these ideas, typing:
    for<tab>expr1;<tab> expr2; expr3
pressing ";" terminates
"""

bsnip("for", "for (i = 0; i < N; i++) {...}", (
r"""for (${1:i}""" +
r"""${1/(.*;.*)|(.*=.*)|(.+)|.*/(?1::(?2:;:(?3: = 0;:;)))/} """ +
r"""${1/\s*[=;].*//}""" +
r"""${2/(.*;.*)|(^[<>!=].*)|.*/(?1::(?2: : < ))/}""" +
r"""${2:N}""" +
r"""${2/(.*;.*)|.*/(?1::;)/} """ +
r"""${1/\s*[=;].*//}""" +
r"""${3:${2/(^>.*)|.*/(?1:--:++)/}}""" +
r""")
{
    `!p snip.rv = better_visual(snip)`$0
}
"""))

# @todo Is there a good way to support a general for (expr; expr; expr)
# using the same "for" trigger?  It's hard to detect the general case
# and remove the defaults in the "for" snippet above.
bsnip("forr", "for (...) {...}", r"""
for (${1:})
{
    `!p snip.rv = better_visual(snip)`$0
}
""")


bsnip("switch", "switch (...) { ... }", r"""
switch (${1:var})
{
case ${2:val}:
    $0
    break;

default:
    break;
}
""", aliases=["sw"])

bsnip("case", "case ...: break;", r"""
case ${1:val}:
    $0
    break;
""")

bsnip("re", "return ", r"""return """)

bsnip("main", "main(...)", r"""
/** @brief Main program entry point.
    @param[in] argc  Number of arguments in @c argv.
    @param[in] argv  Command-line arguments.
    @retval 0
        Success.
*/
int
main(int argc, char *argv[])
{
    $0
    return 0;
}
""")

# @todo Is the hard-wired \n OK?
put(r"""
snippet fprintf "fprintf(..., '...', ...);" w!
fprintf(${1:stderr}, "${2:%s}\n"${2/([^%]|%%)*(%.)?.*/(?2:, :\);)/}$3${2/([^%]|%%)*(%.)?.*/(?2:\);)/}
endsnippet

snippet printf "printf('...', ...);" w!
printf("${1:%s}\n"${1/([^%]|%%)*(%.)?.*/(?2:, :\);)/}$2${1/([^%]|%%)*(%.)?.*/(?2:\);)/}
endsnippet

""")

bsnip("func", "type func(...) {...}", r"""
/*******************************************************************************
    [docimport ${1:funcName}]
*//**
    @brief ${2:Description.}
*******************************************************************************/
${3:void}
$1(${4:void})
{
    `!p snip.rv = better_visual(snip)`$0
}
""", aliases=["def"])

# @todo Create static function definitions with "sfunc", "static".
# Type-related snippets.
bsnip("struct", "typedef struct name {...} name;", r"""
/** @brief ${2:@todo Description of $1.}
*/
typedef struct ${1:name}
{
    $0
} $1;
""")

# Pre-processor.
bsnip("inc", r"""#include 'Header.h'""", r"""
#include "${1:`!p res=re.sub(r'\.[^.]+$', '', fn)+'.h'`}"
""")

bsnip("Inc", "#include <Header.h>", r"""
#include <${1:.h}>
""")

# Doxygen.
babbr("@param",     "@param[in] ${1:inParam}  ${0:@todo Description of $1.}", 
        aliases=["@p", "@pi"])
babbr("@po",   "@param[out] ${1:outParam}  ${0:@todo Description of $1.}")
babbr("@pio",  "@param[in,out] ${1:inOutParam}  ${0:@todo Description of $1.}")
babbr("@b",         "@brief ${0:Description.}")
babbr("@return",    "@return ", aliases=["@re", "@ret"])
bsnip("@retval",    "@retval value, Description", r"""
@retval ${1:returnValue}
    ${0:Reason to return $1.}
""", aliases=["@rv"])
babbr("/**",   "/** @brief ${1:Brief description with period.} */")
babbr("todo",  "/** @todo ${1:Description of what's TO DO.} */")
babbr("bug",   "/** @bug ${1:Description of BUG.} */")

