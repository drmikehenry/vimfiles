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


bsnip("ns", "(ns ...)", r"""
(ns ${1:package.name}
  ${2:(:require ${3:[some.package :as pkg]
                (some.package [subpkg1 :as p1]
                              [subpkg2 :as p2])})}${4:
  (:use ${5:[some.package :only [foo bar]]
            foo.bar})})

$0
""")
