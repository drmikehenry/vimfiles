#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re

sys.path.append(
        os.path.join(os.path.dirname(__file__),
                     '..', '..', '..', '..', 'UltiSnips'))

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


bsnip("defn", "public func decl", r"""
/**
    ${2:brief description}

    full description.
*/
${4:void}
${1:func_name}(${5:void});$0
""", flags="b!", aliases=["def"])

bsnip("func", "type func(...) {...}", r"""
${3:void}
${1:func_name}(${4:void})
{
    $0
}
""", flags="b!")

bsnip("switch", "switch (...) { ... }", r"""
switch (${1:var})
{
    case ${2:val}:
        $0
        break;

    default:
        break;
}
""", flags="b!", aliases=["sw"])

bsnip("main", "main(...)", r"""
/**
    Main program entry point.

    @param[in] argc
        Number of arguments in @c argv.
    @param[in] argv
        Command-line arguments.

    @returns 0 on success, nonzero on failure.
*/
int
main(int argc, const char *argv[])
{
    $0
    return 0;
}
""", flags="b!")

babbr("todo", "/* ### ${1:Description of what's TO DO.} */", flags="b!")
babbr("bug", "/* ### ${1:Description of BUG.} */", flags="b!")

babbr("@param", r"""
@param[in] ${1:inParam}
    ${0:@todo Description of $1.}
""", flags="b!", aliases=["@p", "@pi"])

babbr("@po", r"""
@param[out] ${1:outParam}
    ${0:@todo Description of $1.}
""", flags="b!")

babbr("@pio",r"""
@param[in,out] ${1:inOutParam}
    ${0:@todo Description of $1.}
""", flags="b!")

bsnip("guard", "include guard", r"""
#ifndef ${1:INCLUDED_${2:`!v toupper(expand('%<'))`}}
#define $1

#ifdef __cplusplus
extern "C" {
#endif

$0

#ifdef __cplusplus
}
#endif

#endif /* $1 */
""", flags="b!")

bsnip("tf", "typedef (*func)", r"""
typedef ${2:void} (*${1:func_type_name})(${3:void});
""", flags="b!")

bsnip("docstring", "docstring for func or type", r"""
/**
    ${1:Brief description.}

    ${0:Full description.}
*/
""", flags="b!", aliases=["doc"])

babbr("/**", "/** ${1:Brief description with period.} */", flags="b!")

