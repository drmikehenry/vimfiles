""" The MIT License (MIT)

Copyright (c) 2015 Sergei Dyshel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

import imp
import os.path
import logging

import vim
import abbrev_matcher


log = logging.getLogger('abbrev_matcher')
_log_hndl = logging.StreamHandler()
_log_hndl.setLevel(logging.WARNING)
_log_hndl.setFormatter(logging.Formatter('abbrev_matcher: %(message)s'))
log.addHandler(_log_hndl)


ctrlp_mmode_cutters = {
    'filename-only': lambda s: os.path.basename(s),
    'first-non-tab': lambda s: s.split('\t')[0],
    'until-last-tab': lambda s: s.rsplit('\t')[0],
    'full-line': lambda s: s,
}


def grep_cmd_in_vim():
    exe = vim.eval('g:abbrev_matcher_grep_exe')
    args = vim.eval('g:abbrev_matcher_grep_args')
    return '{} {}'.format(exe, args)


def filter_by_indices(list_, indices):
    """Remove leave only elements with given indeces in list."""
    inds = [-1] + indices[:] + [len(list_)]
    for i in reversed(range(len(inds) - 1)):
        from_ = inds[i] + 1
        to = inds[i+1]
        if from_ >= to:  # consequtive elements
            continue
        list_[from_:to] = []


def highlight_regex(pattern, **kwargs):
    regex = abbrev_matcher.make_regex(pattern, dialect='vim', **kwargs)
    return regex


def filter_grep_exc_handling(*args, **kwargs):
    try:
        line_nums = abbrev_matcher.filter_grep(*args,
                                               cmd=grep_cmd_in_vim(), **kwargs)
    except BaseException as exc:
        line_nums = []
        log.error(exc)
    return line_nums


def filter_unite():
    pattern = vim.eval('input')
    candidates = vim.bindeval('a:candidates')
    regex = abbrev_matcher.make_regex(pattern)

    def candidate_word(candidate):
        return (candidate['word']
                if isinstance(candidate, vim.Dictionary) else candidate)

    candidate_words = map(candidate_word, candidates)

    line_nums = filter_grep_exc_handling(regex, candidate_words)
    filter_by_indices(candidates, line_nums)


def sort_unite():
    candidates = vim.bindeval('a:candidates')
    is_file = vim.eval('is_file')
    pattern = vim.eval('a:context.input')

    for candidate in candidates:
        word = candidate['word']
        rank = abbrev_matcher.rank(pattern, word, is_file=is_file)
        candidate['filter__rank'] = rank


def filter_ctrlp():
    items = vim.eval('a:items')
    pattern = vim.eval('a:str')
    limit = int(vim.eval('a:limit'))
    ispath = vim.eval('a:ispath')
    mmode = vim.eval('a:mmode')

    regex = abbrev_matcher.make_regex(pattern)
    cutter = ctrlp_mmode_cutters[mmode]

    mmode_items = map(cutter, items)
    line_nums = filter_grep_exc_handling(regex, mmode_items)
    filter_by_indices(items, line_nums)

    def rank(string):
        return abbrev_matcher.rank(pattern, cutter(string), is_file=ispath)

    items.sort(key=rank)
    items[limit:] = []

    return items

