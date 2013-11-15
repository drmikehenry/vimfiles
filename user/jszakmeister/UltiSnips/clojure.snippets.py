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


# bsnip("ns", "(ns ...)", r"""
# (ns ${1:package.name}
#   ${2:(:require ${3:[some.package :as pkg]
#                 (some.package [subpkg1 :as p1]
#                               [subpkg2 :as p2])})}${4:
#   (:use ${5:[some.package :only [foo bar]]
#             foo.bar})})

# $0
# """)

bsnip("c", "comment", r"""
(comment
  $0
  )
""")

wsnip("condp", "condp", r"""
(condp ${1:pred} ${2:expr}
  $0)
""")

bsnip("defm", "defmethod", r"""
(defmethod ${1:name} ${2:match}
  [${3:args}]
  $0)
""")

bsnip("defmm", "defmulti", r"""
(defmulti ${1:name} ${2:dispatch-fn})
$0
""")

bsnip("defn", "defn", r"""
(defn ${1:name} ${2:
  "${3:doc-string}"
  }[${4:arg-list}]
  $0)
""")

bsnip("defp", "defprotocol", r"""
(defprotocol ${1:Name}
  $0)
""")

bsnip("defr", "defrecord", r"""
(defrecord ${1:Name} [${2:fields}]
  ${3:Protocol}
  $0)
""")

bsnip("deft", "deftype", r"""
(deftype ${1:Name} [${2:fields}]
  ${3:Protocol}
  $0)
""")

wsnip("f", "fresh", r"""
(fresh [${1:vars}]
  $0)
""")

wsnip("fn", "fn", r"""
(fn [${1:arg-list}] $0)
""")

wsnip("if", "if", r"""
(if ${1:test-expr}
  ${2:then-expr}
  ${3:else-expr})
$0
""")

bsnip("import", "import", r"""
(:import [${1:package}])
$0
""")

wsnip("kwargs", "keyword args", r"""
& {:keys [${1:keys}] :or {${2:defaults}}}
$0
""")

wsnip("let", "let", r"""
(let [$0])
""")

wsnip("letfn", "letfn", r"""
(letfn [(${1:name) [${2:args}]
          $0)])
""")

wsnip("m", "method", r"""
(${1:name} [${2:this} ${3:args}]
  $0)
""")

# TODO:compute the expected namespace.
bsnip("ns", "ns", r"""
(ns ${1:namespace}
  $0)
""")

bsnip("perf", "perf", r"""
(dotimes [_ 10]
  (time
    (dotimes [_ ${1:times}]
      $0)))
""")

bsnip("pm", "protocol method", r"""
(${1:name} [${2:this} ${3:args}])
$0
""")

wsnip("refer", "refer", r"""
(:refer-clojure :exclude [$0])
""")

wsnip("require", "require", r"""
(:require [${1:namespace} :as [$0]])
""")

wsnip("rn", "run n", r"""
(run ${1:n} [q]
  $0)
""")

wsnip("rstar", "run*", r"""
(run* [q]
  $0)
""")

wsnip("use", "use", r"""
(:use [${1:namespace} :only [$0]])
""")

wsnip("doseq", "doseq", r"""
(doseq [${1:vars}]
  $0)
""")

wsnip("dotimes", "dotimes ", r"""
(dotimes [${1:vars}]
  $0)
""")

bsnip("main", "-main", r"""
(defn -main
  "The application's main function"
  [& args]
  $0)
""")

wsnip("prs", "pr-str", r"""
(pr-str $0)
""")

wsnip("pl", "println", r"""
(println $1)$0
""")

# ClojureScript snippets

wsnip("jslog", "(.log js/console ...)", r"""
(.log js/console $0)
""")
