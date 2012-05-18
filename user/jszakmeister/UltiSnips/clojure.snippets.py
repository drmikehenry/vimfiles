#!/usr/bin/env python
# vim:set fileencoding=utf8:

import os
import sys
import re

sys.path.append(
        os.path.join(os.path.dirname(__file__),
                     '..', '..', '..', 'UltiSnips'))

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


# Snippets are now cleared in "clearsnippets" directory.
#put("clearsnippets\n")

# 'if' snippets.
bsnip("ns", "(ns ...)", r"""
(ns ${1:package.name}
  ${2:(:require ${3:[some.package :as pkg]
                (some.package [subpkg1 :as p1]
                              [subpkg2 :as p2])})}${4:
  (:use ${5:[some.package :only [foo bar]]
            foo.bar})})

$0
""")
