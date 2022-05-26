"""Chain program execution through Python for better argument parsing.

Simply turns around and invokes a subprocess call on the passed-in
arguments directly.  E.g., this invocation::

    python3 execargs.py perl somePerlScript.pl arg1 arg2

is logically equivalent to this one, but with better quote handling::

    perl somePerlScript.pl arg1 arg2
"""

import sys
import subprocess

# for i, arg in enumerate(sys.argv):
#     print("arg[%d] = %s" % (i, repr(arg)))
# sys.stdout.flush()

subprocess.call(sys.argv[1:])
