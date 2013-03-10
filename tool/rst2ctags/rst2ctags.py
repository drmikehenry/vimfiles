#! /usr/bin/env python

"""
Copyright 2009-2011 Bernhard Leiner <bleiner@gmail.com>

This software may be used and distributed according to the terms of the
MIT license, incorporated herein by reference.
"""

import os
import sys
from optparse import OptionParser

from docutils import nodes
from docutils.core import publish_doctree

__version__ = "1.0"

class Tag(object):

    SRO = "|"  # scope resolution operator

    def __init__(self, tagid, tagfile, tagaddress, tagtype, linenr,
                 level = 0, parent = None):
        self.tagid = tagid
        self.tagfile = tagfile
        self.tagaddress = tagaddress
        self.tagtype = tagtype
        self.linenr = linenr
        self.level = level
        if level == 0:
            self.scope = None
        elif level == 1:
            self.scope = parent.tagid if parent else None
        elif level > 1:
            self.scope = (Tag.SRO.join((parent.scope, parent.tagid)) 
                          if (parent and parent.scope and parent.tagid)
                          else None)
        self.parent = parent

    def __str__(self):
        base_info = "{0}\t{1}\t{2}\t{3}".format \
                    (self.tagid, self.tagfile, self.tagaddress, self.tagtype)
        # add line info
        line_info = "\tline:{0:d}".format(self.linenr)
        # add full scope information
        scope_info = ("\tsection:{0}".format(self.scope) if self.scope
                       else "")

        return base_info + line_info + scope_info + "\n"


class CTagsWriter(object):
    """rst2ctags specific docutils writer class.
    """

    URL = "http://bernh.net/rst2ctags"
    VERSION = "rst2ctags v{0}".format(__version__)

    metadata = \
            ("!_TAG_FILE_FORMAT\t2\t/extended format/\n"
             "!_TAG_FILE_SORTED\t{sort}\t/0=unsorted, 1=sorted, 2=foldcase/\n"
             "!_TAG_PROGRAM_NAME\trst2ctags\t//\n"
             "!_TAG_PROGRAM_AUTHOR\tBernhard Leiner\t/bleiner@gmail.com/\n"
             "!_TAG_PROGRAM_URL\t{url}\t//\n"
             "!_TAG_PROGRAM_VERSION\t{version}\t//\n")

    def __init__(self):
        self.tags = []

    def nodewalker(self, node, level, parent):
        """Translates the doctree into a list of tags and appends it to
           :attr:`tags`.
        """
        tag = None
        new_parent = False
        if isinstance(node, nodes.section):
            tagtype = "s"
            tagfile = os.path.relpath(node.source)
            tagid = \
                str(node.astext().partition(node.child_text_separator)[0])
            tagaddress = '/^{0}$/;"'.format(tagid)
            taglinenr = node.line - 1
            # increase level for next found section
            level += 1
            new_parent = True
            tag = Tag(tagid, tagfile, tagaddress, tagtype, taglinenr, level, parent)
        elif (isinstance(node, nodes.image) or
              isinstance(node, nodes.figure)):
            tagtype = "i"
            tagfile = os.path.relpath(node.source) if node.source \
                      else os.path.relpath(node.parent.source)
            taglinenr = node.line - 1 if node.line else node.parent.line - 1
            if isinstance(node, nodes.image):
                tagid = node.attributes['uri'] 
                tagaddress = '/^{0}$/;"'.format(node.rawsource.split('\n')[0])
            if isinstance(node, nodes.figure):
                tagid = node.children[0].attributes['uri'] 
                tagaddress = '/^{0}$/;"'.format(node.children[0].rawsource.split('\n')[0])
            tag = Tag(tagid, tagfile, tagaddress, tagtype, taglinenr, level)

        if tag:
            self.tags.append(tag)

        if new_parent:
            parent = tag

        if len(node.children) and not isinstance(node, nodes.figure):
            for child in node:
                self.nodewalker(child, level, parent)


    def write(self, f, sort, metadata):
        if sort == "yes":   # sort by tag name
            self.tags.sort(key = lambda t: t.tagid)
        else:               # sort by file and line number
            self.tags.sort(key = lambda t: (t.tagfile, t.linenr))

        if metadata:
            sort = "1" if sort == "yes" else "0"
            f.write(self.metadata.format(sort=sort, url = CTagsWriter.URL, 
                                         version = CTagsWriter.VERSION))
        for tag in self.tags:
            f.write(str(tag))


def get_rst_files(source_args, recurse):
    """Return an iterable containing all source files.
    """

    rst_ext = ".rst"
    source_files = []

    def is_rst_file(f):
        return os.path.splitext(f)[1] == rst_ext

    if not recurse:
        # treat all source args as files
        source_files = [f for f in source_args if is_rst_file(f)]
    else:
        # source_args may be a mixture of files and directories
        cwd = os.getcwd()
        if cwd not in source_args:
            source_args.append(cwd)
        source_files = [f for f in source_args 
                        if os.path.isfile(f) and is_rst_file(f)]
        for source_dir in (d for d in source_args if os.path.isdir(d)):
            for dirpath, _, filenames in os.walk(source_dir):
                source_files.extend(os.path.join(dirpath, f)
                                    for f in filenames if is_rst_file(f))
    # return unique sources
    return set(os.path.abspath(f) for f in source_files)



def main():
    parser = OptionParser(usage = "usage: %prog [options] file(s)", 
                          version = "%prog {0}".format(__version__))
    parser.add_option \
            ("-f", "--file", metavar = "FILE", dest = "tagfile",
             default = "tags",
             help = 'Write tags into FILE (default: "tags"). Value of '
                    '"-" writes tags to stdout.')
    parser.add_option \
            ("-R", "--recurse", dest = "recurse", action = "store_true",
             default = False,
             help = "Recurse into directories supplied on command line")
    parser.add_option \
            ("--sort", metavar = "[yes|no]", dest = "sort", default = "no",
             help = 'Should tags be sorted by name? Default is "no", which '
             'will sort by line number.')
    options, args = parser.parse_args() 

    if len(args) == 0:
        parser.error('No files specified. Try "--help"')

    writer = CTagsWriter()
    for rstfile in get_rst_files(args, options.recurse):
        with open(rstfile) as f:
            rstdata = f.read()
            doctree = publish_doctree(rstdata, source_path = rstfile)
            writer.nodewalker(doctree, -1, None)
    
    if options.tagfile == "-":
        writer.write(sys.stdout, options.sort, False)
    else:
        with open(options.tagfile, "w") as f:
            writer.write(f, options.sort, True)


if __name__ == "__main__":
    main()
