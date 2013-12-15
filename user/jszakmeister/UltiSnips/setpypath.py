#!/usr/bin/env python
# vim:set fileencoding=utf8: #

import sys
import os

# Augment sys.path with top-level pylib.
thisDir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.abspath(thisDir + "/../../../pylib"))
