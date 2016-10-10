#!/usr/bin/env python2

# Copyright (C) 2013 John Szakmeister <john@szakmeister.net>
# All rights reserved.
#
# This software is licensed as described in the file LICENSE.txt, which
# you should have received as part of this distribution.

import sys
import re


__version__ = '0.1.5'


class ScriptError(Exception):
    pass


def ctagNameEscape(str):
    str = re.sub('[\t\r\n]+', ' ', str)
    str = re.sub(r'^\s*\\\((.)\)', r'(\1)', str)
    return str


def ctagSearchEscape(str):
    str = str.replace('\t', r'\t')
    str = str.replace('\r', r'\r')
    str = str.replace('\n', r'\n')
    str = str.replace('\\', r'\\')
    return str


class Tag(object):
    def __init__(self, tagName, tagFile, tagAddress):
        self.tagName = tagName
        self.tagFile = tagFile
        self.tagAddress = tagAddress
        self.fields = []

    def addField(self, type, value=None):
        if type == 'kind':
            type = None
        self.fields.append((type, value or ""))

    def _formatFields(self):
        formattedFields = []
        for name, value in self.fields:
            if name:
                s = '%s:%s' % (name, value or "")
            else:
                s = str(value)
            formattedFields.append(s)
        return '\t'.join(formattedFields)

    def __str__(self):
        tag = '%s\t%s\t%s;"\t%s' % (
            self.tagName, self.tagFile, self.tagAddress,
            self._formatFields())
        if isinstance(tag, unicode):
            return tag.encode('utf-8')
        else:
            return tag

    def __cmp__(self, other):
        return cmp(str(self), str(other))

    @staticmethod
    def section(section):
        tagName = ctagNameEscape(section.name)
        tagAddress = '/^%s$/' % ctagSearchEscape(section.line)
        t = Tag(tagName, section.filename, tagAddress)
        t.addField('kind', 's')
        t.addField('line', section.lineNumber)

        parents = []
        p = section.parent
        while p is not None:
            parents.append(ctagNameEscape(p.name))
            p = p.parent
        parents.reverse()

        if parents:
            t.addField('section', '|'.join(parents))

        return t


class Section(object):
    def __init__(self, level, name, line, lineNumber, filename, parent=None):
        self.level = level
        self.name = name
        self.line = line
        self.lineNumber = lineNumber
        self.filename = filename
        self.parent = parent

    def __repr__(self):
        return '<Section %s %d %d>' % (self.name, self.level, self.lineNumber)


headingRe = re.compile(r'''^([-=~:^"#*._+`'])\1+$''')
subjectRe = re.compile(r'^[^\s]+.*$')

def findSections(filename, lines):
    sections = []
    headingOrder = {}
    orderSeen = 1
    previousSections = []

    for i, line in enumerate(lines):
        if i == 0:
            continue

        if headingRe.match(line) and subjectRe.match(lines[i-1]):
            if i >= 2:
                topLine = lines[i-2]
            else:
                topLine = ''

            # If the heading line is to short, then docutils doesn't consider it
            # a heading.
            if len(line) < len(lines[i-1]):
                continue

            key = line[0]

            if headingRe.match(topLine):
                # If there is an overline, it must match the bottom line.
                if topLine != line:
                    # Not a heading.
                    continue
                # We have an overline, so double up.
                key = key + key

            if key not in headingOrder:
                headingOrder[key] = orderSeen
                orderSeen += 1

            name = lines[i-1].strip()
            level = headingOrder[key]
            previousSections = previousSections[:level-1]
            if previousSections:
                parent = previousSections[-1]
            else:
                parent = None
            lineNumber = i

            s = Section(level, name, lines[i-1], lineNumber, filename, parent)
            previousSections.append(s)
            sections.append(s)

            # Blank lines to help correctly detect:
            #    foo
            #    ===
            #    bar
            #    ===
            #
            # as two underline style headings.
            lines[i] = lines[i-1] = ''
            if topLine:
                lines[i-2] = ''

    return sections


def sectionsToTags(sections):
    tags = []

    for section in sections:
        tags.append(Tag.section(section))

    return tags


def genTagsFile(output, tags, sort):
    if sort == "yes":
        tags = sorted(tags)
        sortedLine = '!_TAG_FILE_SORTED\t1\n'
    elif sort == "foldcase":
        tags = sorted(tags, key=lambda x: str(x).lower())
        sortedLine = '!_TAG_FILE_SORTED\t2\n'
    else:
        sortedLine = '!_TAG_FILE_SORTED\t0\n'

    output.write('!_TAG_FILE_FORMAT\t2\n')
    output.write(sortedLine)

    for t in tags:
        output.write(str(t))
        output.write('\n')


def main():
    from optparse import OptionParser

    parser = OptionParser(usage = "usage: %prog [options] file(s)",
                          version = __version__)
    parser.add_option(
            "-f", "--file", metavar = "FILE", dest = "tagfile",
            default = "tags",
            help = 'Write tags into FILE (default: "tags").  Use "-" to write '
                   'tags to stdout.')
    parser.add_option(
            "", "--sort", metavar="[yes|foldcase|no]", dest = "sort",
            choices = ["yes", "no", "foldcase"],
            default = "yes",
            help = 'Produce sorted output.  Acceptable values are "yes", '
                   '"no", and "foldcase".  Default is "yes".')

    options, args = parser.parse_args()

    if options.tagfile == '-':
        output = sys.stdout
    else:
        output = open(options.tagfile, 'wb')

    for filename in args:
        f = open(filename, 'rb')
        buf = f.read()

        try:
            buf = buf.decode('utf-8')
        except UnicodeDecodeError:
            pass

        lines = buf.splitlines()

        f.close()
        del buf

        sections = findSections(filename, lines)

        genTagsFile(output, sectionsToTags(sections), sort=options.sort)

    output.flush()
    output.close()

if __name__ == '__main__':
    try:
        main()
    except IOError as e:
        import errno
        if e.errno == errno.EPIPE:
            # Exit saying we got SIGPIPE.
            sys.exit(141)
        raise
    except ScriptError as e:
        print >>sys.stderr, "ERROR: %s" % str(e)
        sys.exit(1)
