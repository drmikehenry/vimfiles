#!/usr/bin/env python3

import sys
import os

# Augment sys.path with top-level pythonx.
thisDir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.abspath(thisDir + "/../pythonx"))
