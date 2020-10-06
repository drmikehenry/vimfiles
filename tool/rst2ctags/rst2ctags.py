#!/usr/bin/env python

# Copyright (C) 2013-2020 John Szakmeister <john@szakmeister.net>
# All rights reserved.
#
# This software is licensed as described in the file LICENSE.txt, which
# you should have received as part of this distribution.

from __future__ import absolute_import
from __future__ import print_function

import codecs
import errno
import io
import locale
import sys
import re


__version__ = "0.2.6"


class ScriptError(Exception):
    pass


def detect_encoding(filename):
    with open(filename, 'rb') as f:
        raw = f.read(4096)

    potential_bom = raw[:4]
    bom_encodings = [('utf-8-sig', codecs.BOM_UTF8),
                     ('utf-16', codecs.BOM_UTF16_LE),
                     ('utf-16', codecs.BOM_UTF16_BE),
                     ('utf-32', codecs.BOM_UTF32_LE),
                     ('utf-32', codecs.BOM_UTF32_BE)]
    for encoding, bom in bom_encodings:
        if potential_bom.startswith(bom):
            return encoding

    # No BOM found, let's try to detect encoding
    encoding = None
    try:
        import chardet

        result = chardet.detect(raw)

        # If we're not really confident about the encoding, then skip to
        # UTF-8 detection.
        if result['confidence'] >= 0.9:
            encoding = result['encoding']

        if encoding == 'ascii':
            encoding = 'utf-8'
    except ImportError:
        pass

    if encoding is None:
        try:
            raw.rsplit(b' ')[0].decode('utf-8')
            encoding = 'utf-8'
        except UnicodeDecodeError:
            pass

    return encoding or 'latin1'


def open_autoenc(filename, encoding=None):
    if encoding is None:
        encoding = detect_encoding(filename)
    return io.open(filename, encoding=encoding, newline='')


def ctag_name_escape(str):
    str = re.sub('[\t\r\n]+', ' ', str)
    str = re.sub(r'^\s*\\\((.)\)', r'(\1)', str)
    return str


def ctag_search_escape(str):
    str = str.replace('\\', r'\\')
    str = str.replace('\t', r'\t')
    str = str.replace('\r', r'\r')
    str = str.replace('\n', r'\n')
    for c in '[]*$.^':
        str = str.replace(c, '\\' + c)
    return str


class Tag(object):
    def __init__(self, tag_name, tag_file, tag_address):
        self.tag_name = tag_name
        self.tag_file = tag_file
        self.tag_address = tag_address
        self.fields = []

    def add_field(self, type, value=None):
        if type == 'kind':
            type = None
        self.fields.append((type, value or ""))

    def _format_fields(self):
        formatted_fields = []
        for name, value in self.fields:
            if name:
                s = '%s:%s' % (name, value or "")
            else:
                s = str(value)
            formatted_fields.append(s)
        return '\t'.join(formatted_fields)

    def render(self):
        return '%s\t%s\t%s;"\t%s' % (
            self.tag_name, self.tag_file, self.tag_address, self._format_fields())

    def __repr__(self):
        return "<Tag name:%s file:%s: addr:%s %s>" % (
            self.tag_name, self.tag_file, self.tag_address,
            self._format_fields().replace('\t', ' '))

    def _tuple(self):
        return (self.tag_name, self.tag_file, self.tag_address,
                self._format_fields())

    def __eq__(self, other):
        return self._tuple() == other._tuple()

    def __ne__(self, other):
        return self._tuple() != other._tuple()

    def __lt__(self, other):
        return self._tuple() < other._tuple()

    def __le__(self, other):
        return self._tuple() <= other._tuple()

    def __gt__(self, other):
        return self._tuple() > other._tuple()

    def __ge__(self, other):
        return self._tuple() >= other._tuple()

    @staticmethod
    def section(section, sro):
        tag_name = ctag_name_escape(section.name)
        tag_address = '/^%s$/' % ctag_search_escape(section.line)
        t = Tag(tag_name, section.filename, tag_address)
        t.add_field('kind', 's')
        t.add_field('line', section.line_number)

        parents = []
        p = section.parent
        while p is not None:
            parents.append(ctag_name_escape(p.name))
            p = p.parent
        parents.reverse()

        if parents:
            t.add_field('section', sro.join(parents))

        return t


class Section(object):
    def __init__(self, level, name, line, line_number, filename, parent=None):
        self.level = level
        self.name = name
        self.line = line
        self.line_number = line_number
        self.filename = filename
        self.parent = parent

    def __repr__(self):
        return '<Section %s %d %d>' % (self.name, self.level, self.line_number)


def pop_sections(sections, level):
    while sections:
        s = sections.pop()
        if s and s.level < level:
            sections.append(s)
            return


heading_re = re.compile(r'''^([-=~:^"#*._+`'])\1+$''')
subject_re = re.compile(r'^[^\s]+.*$')


def find_sections(filename, lines):
    sections = []

    previous_sections = []
    level_values = {}
    level = 0

    for i, line in enumerate(lines):
        if i == 0:
            continue

        if heading_re.match(line) and subject_re.match(lines[i - 1]):
            if i >= 2:
                top_line = lines[i-2]
            else:
                top_line = ''

            # If the heading line is to short, then docutils doesn't consider
            # it a heading.
            if len(line) < len(lines[i-1]):
                continue

            name = lines[i-1].strip()
            key = line[0]

            if heading_re.match(top_line):
                # If there is an overline, it must match the bottom line.
                if top_line != line:
                    # Not a heading.
                    continue
                # We have an overline, so double up.
                key = key + key

            if key not in level_values:
                level_values[key] = level + 1

            level = level_values[key]

            pop_sections(previous_sections, level)
            if previous_sections:
                parent = previous_sections[-1]
            else:
                parent = None
            line_number = i

            s = Section(level, name, lines[i-1], line_number,
                        filename, parent)
            previous_sections.append(s)
            sections.append(s)

            # Blank lines to help correctly detect:
            #    foo
            #    ===
            #    bar
            #    ===
            #
            # as two underline style headings.
            lines[i] = lines[i-1] = ''
            if top_line:
                lines[i-2] = ''

    return sections


def sections_to_tags(sections, sro):
    tags = []

    for section in sections:
        tags.append(Tag.section(section, sro))

    return tags


def gen_tags_header(output, sort):
    if sort == "yes":
        sorted_line = b'!_TAG_FILE_SORTED\t1\t//\n'
    elif sort == "foldcase":
        sorted_line = b'!_TAG_FILE_SORTED\t2\t//\n'
    else:
        sorted_line = b'!_TAG_FILE_SORTED\t0\t//\n'

    output.write(b'!_TAG_FILE_ENCODING\tutf-8\t//\n')
    output.write(b'!_TAG_FILE_FORMAT\t2\t//\n')
    output.write(sorted_line)


def gen_tags_content(output, sort, tags):
    if sort == "yes":
        tags = sorted(tags)
    elif sort == "foldcase":
        tags = sorted(tags, key=lambda x: str(x).lower())

    for t in tags:
        output.write(t.render().encode('utf-8'))
        output.write('\n'.encode('utf-8'))


def main():
    from optparse import OptionParser

    parser = OptionParser(usage="usage: %prog [options] file(s)",
                          version=__version__)
    parser.add_option(
        "-f", "--file", metavar="FILE", dest="tagfile",
        default="tags",
        help='Write tags into FILE (default: "tags").  Use "-" to write '
             'tags to stdout.')
    parser.add_option(
        "", "--encoding", metavar="ENCODING", dest="encoding",
        default=None,
        help='Skips auto detection and uses the specified encoding for the '
             'input files.  Encoding name should be one that Python would '
             'recognize.')
    parser.add_option(
        "", "--sort", metavar="[yes|foldcase|no]", dest="sort",
        choices=["yes", "no", "foldcase"],
        default="yes",
        help='Produce sorted output.  Acceptable values are "yes", '
             '"no", and "foldcase".  Default is "yes".')
    parser.add_option(
        "", "--sro", metavar="SEPARATOR", dest="sro",
        default="|", action="store",
        help=u'Use the specified string to scope nested headings.  The '
              'default is pipe symbol ("|"), but that can be an issue if your '
              'headings contain the pipe symbol.  It might be more useful to '
              'use a such as the UTF-8 chevron ("\u00bb").')

    options, args = parser.parse_args()

    if not args:
        raise ScriptError("No input files specified.")

    if sys.version_info[0] == 2:
        encoding = sys.stdin.encoding or locale.getpreferredencoding() or 'utf-8'
        options.sro = options.sro.decode(encoding)

    if options.tagfile == '-':
        if sys.version_info[0] == 2:
            output = sys.stdout
        else:
            output = sys.stdout.buffer
    else:
        output = open(options.tagfile, 'wb')

    gen_tags_header(output, options.sort)

    all_sections = []

    try:
        for filename in args:
            if sys.version_info[0] == 2:
                filename = filename.decode(sys.getfilesystemencoding())

            try:
                with open_autoenc(filename, encoding=options.encoding) as f:
                    buf = f.read()
            except IOError as e:
                if e.errno == errno.EPIPE:
                    raise
                print_warning(e)
                continue

            lines = buf.splitlines()
            del buf

            sections = find_sections(filename, lines)
            all_sections.extend(sections)
    finally:
        # We do this to match ctags behavior... even when a file is missing,
        # it'll write out the tags it has.
        gen_tags_content(output,
                         options.sort,
                         sections_to_tags(all_sections, options.sro))

    output.flush()
    output.close()


def print_warning(e):
    print("WARNING: %s" % str(e), file=sys.stderr)


def print_error(e):
    print("ERROR: %s" % str(e), file=sys.stderr)


def cli_main():
    try:
        main()
    except IOError as e:
        if e.errno == errno.EPIPE:
            # Exit saying we got SIGPIPE.
            sys.exit(141)
        print_error(e)
        sys.exit(1)
    except ScriptError as e:
        print_error(e)
        sys.exit(1)


if __name__ == '__main__':
    cli_main()
