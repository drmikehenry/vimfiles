#!/usr/bin/env python

import sys
import re

##############################################################################
# Helpers for defining snippets.

def put(s):
    sys.stdout.write(s)

def bodyToDesc(body):
    desc = body
    desc = re.sub('"', "'", desc)
    desc = re.sub("\n", r"\\n", desc)
    desc = re.sub(r"\$0", "", desc)
    desc = re.sub(r"\$\{\d+\}|\$\d+", "...", desc)
    desc = re.sub(r"\$\{\d+:([^}]+)\}", lambda m: m.group(1), desc)
    return desc

def snip(trigger, desc, body, flags="", aliases=[], trimBody=True):
    if trimBody and body.startswith("\n"):
        body = body[1:]
    if trimBody and body.endswith("\n"):
        body = body[:-1]
    if "" in body.splitlines() and "m" not in flags:
        # If body contains an empty line, use the "m" flag to keep that
        # line empty after indentation.
        flags = flags + "m"
    for t in [trigger] + aliases:
        put("# DO NOT EDIT - file generated by corresponding .py file\n")
        put("""snippet {} "{}" {}\n{}\nendsnippet\n""".format(
            t, re.sub('"', '\\"', desc), flags, body))

def bsnip(trigger, desc, body, flags="", aliases=[], trimBody=True):
    """Beginning-of-line only."""
    snip(trigger, desc, body, flags="b" + flags.replace("b", ""),
            aliases=aliases, trimBody=trimBody)

def wsnip(trigger, desc, body, flags="", aliases=[], trimBody=True):
    """Word boundary."""
    snip(trigger, desc, body, flags="w" + flags.replace("w", ""),
            aliases=aliases, trimBody=trimBody)

def abbr(trigger, value, flags="", aliases=[]):
    desc = bodyToDesc(value)
    snip(trigger, desc, value, flags=flags, aliases=aliases)

def babbr(trigger, value, flags="", aliases=[]):
    """Beginning-of-line only."""
    abbr(trigger, value, flags="b" + flags.replace("b", ""), aliases=aliases)

def wabbr(trigger, value, flags="", aliases=[]):
    """Word boundary."""
    abbr(trigger, value, flags="w" + flags.replace("w", ""), aliases=aliases)

##############################################################################
# Helpers for use in snippets themselves.

def betterVisual(snip, contIndentLevel=1, default=''):
    import textwrap

    text = textwrap.dedent(snip.v.text or default)
    for i, line in enumerate(text.splitlines()):
        if i == 0:
            snip.rv = snip.mkline(line)
            snip.shift(contIndentLevel)
        elif line.strip():
            snip += line
        else:
            # Avoid indentation for empty lines.
            snip.rv += "\n"


def autoPeriod(paragraph):
    # Only consider the final line in a paragraph; if empty or just contains
    # whitespace, no final punctuation is needed.
    if paragraph.endswith('\n'):
        last_line = ''
    else:
        last_line = ('\n' + paragraph).splitlines()[-1].rstrip()
    if last_line.endswith(tuple(". ! ?".split())) or not last_line:
        period = ''
    else:
        period = '.'
    return period
