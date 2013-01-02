#!/usr/bin/env python

import os
import re
import sys
from subprocess import Popen, PIPE, STDOUT

class RunError(Exception):
    pass

def runArgsOutErr(args):
    p = Popen(args, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    return out, err

def runArgs(args):
    out, err = runArgsOutErr(args)
    if err:
        raise RunError("%s" % str(args))
    return out

def joinLines(lines):
    return "".join([line + "\n" for line in lines])

def readLines(path):
    f = open(path, "r")
    lines = f.read().splitlines()
    f.close()
    return lines

def writeLines(path, lines):
    f = open(path, "w")
    f.write(joinLines(lines))
    f.close()

def main():
    homePath = os.path.expanduser("~")
    vimrcPath = os.path.join(homePath, ".vimrc")
    if os.path.isfile(vimrcPath):
        vimrcLines = readLines(vimrcPath)
    else:
        vimrcLines = []
    runtimeLine = "runtime vimrc"
    for line in vimrcLines:
        if re.match(r'(\s*"\s*)?' + re.escape(runtimeLine) + r"\s*$", line):
            break
    else:
        vimrcLines.insert(0, runtimeLine)
        writeLines(vimrcPath, vimrcLines)

if __name__ == '__main__':
    main()
