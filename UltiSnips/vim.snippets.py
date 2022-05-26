#!/usr/bin/env python

import os
import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip
from sniputil import abbr, babbr, wabbr


bsnip("template_vim..syntastic_c_config", "syntastic c config template", r"""
let s:include_dirs = [$0]
let g:syntastic_c_include_dirs =
            \ map(s:include_dirs, 'expand("<sfile>:p:h") . "/" . v:val'
""")
