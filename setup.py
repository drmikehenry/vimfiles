#!/usr/bin/env python3


import os
import re
import subprocess


class RunError(Exception):
    pass


def run_args_out_err(args):
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    return out, err


def run_args(args):
    out, err = run_args_out_err(args)
    if err:
        raise RunError("%s" % str(args))
    return out


def join_lines(lines):
    return "".join([line + "\n" for line in lines])


def read_lines(path):
    f = open(path)
    lines = f.read().splitlines()
    f.close()
    return lines


def write_lines(path, lines):
    f = open(path, "w")
    f.write(join_lines(lines))
    f.close()


def main():
    home_path = os.path.expanduser("~")
    vimrc_path = os.path.join(home_path, ".vimrc")
    if os.path.isfile(vimrc_path):
        vimrc_lines = read_lines(vimrc_path)
    else:
        vimrc_lines = []
    runtime_line = "runtime vimrc"
    for line in vimrc_lines:
        if re.match(r'(\s*"\s*)?' + re.escape(runtime_line) + r"\s*$", line):
            break
    else:
        vimrc_lines.insert(0, runtime_line)
        write_lines(vimrc_path, vimrc_lines)


if __name__ == "__main__":
    main()
