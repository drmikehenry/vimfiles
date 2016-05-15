#!/usr/bin/env python

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

from __future__ import print_function

import os
import os.path
import sys
import logging
import shlex
import subprocess
import distutils.spawn
import operator
import pipes

REGEX_DIALECTS = ['grep', 'vim']

log = logging.getLogger('abbrev_matcher')

def _word_boundary(prev, curr):
    """Whether current character is on word boundary."""
    if not prev:
        return True
    return ((curr.isupper() and not prev.isupper()) or
            (curr.islower() and not prev.isalpha()) or
            (curr.isdigit() and not prev.isdigit()) or
            (not curr.isalnum() and curr != prev))


def _match_generator(pattern, string, offset=0):
    """Recursively generate matches of `pattern` in `string`."""

    def _find_ignorecase(string, char, start=0):
        """Find first occurrence of `char` inside `string`,
           starting with `start`-th character."""
        if char.isalpha():
            lo = string.find(char.lower(), start)
            hi = string.find(char.upper(), start)
            if lo == -1:
                return hi
            elif hi == -1:
                return lo
            else:
                return min(hi, lo)
        else:
            return string.find(char, start)

    if pattern == '':
        yield []
        return

    if string == '':
        return

    indices = range(len(string))

    abbrev_0 = pattern[0]
    abbrev_rest = pattern[1:]

    if abbrev_0.lower() == string[0].lower():
        matches = _match_generator(abbrev_rest, string[1:], offset + 1)
        for m in matches:
            m.insert(0, offset)
            yield m

    i = _find_ignorecase(string, abbrev_0, 1)
    while i != -1:
        curr = string[i]

        prev = string[i - 1]
        if _word_boundary(prev, curr):
            matches = _match_generator(abbrev_rest, string[i + 1:],
                                       offset + i + 1)
            for m in matches:
                m.insert(0, offset + i)
                yield m

        i = _find_ignorecase(string, abbrev_0, i + 1)


def make_regex(pattern, dialect='grep', greedy=True, escape=False):
    """Build regular expression corresponding to `pattern`."""

    assert dialect in REGEX_DIALECTS
    vim = (dialect == 'vim')

    def re_group(r):
        if dialect == 'vim':
            return r'%(' + r + r')'
        return r'(' + r + r')'

    def re_or(r1, r2):
        return re_group(re_group(r1) + '|' + re_group(r2))

    def re_opt(r):
        return re_group(r) + '?'

    asterisk = '*' if greedy or not vim else '{-}'
    res = ''
    if vim:
        res += r'\v'
    if not vim:  # XXX: ^ does not work in vim hightlighting
        res += '^'
    for i, ch in enumerate(pattern):
        match_start = '\zs' if i == 0 and vim else ''

        if ch.isalpha():
            ch_lower = ch.lower()
            ch_upper = ch.upper()
            not_alpha = '[^a-zA-Z]'
            not_upper = '[^A-Z]'
            anycase = (re_opt(r'.{asterisk}{not_alpha}') + '{match_start}' +
                       '[{ch_lower}{ch_upper}]')
            camelcase = re_opt(r'.{asterisk}{not_upper}') + '{ch_upper}'
            ch_res = re_or(anycase, camelcase)
        elif ch.isdigit():
            ch_res = (re_opt(r'.{asterisk}[^0-9]') + '{match_start}{ch}')
        else:
            ch_res = r'.{asterisk}\{match_start}{ch}'
        res += ch_res.format(**locals())
    if vim:
        res += '\ze'
    if escape:
        res = res.replace('\\', '\\\\')
    return res


def is_exe(path):
    return os.path.isfile(path) and os.access(path, os.X_OK)


def which(exe):
    if not is_exe(exe):
        found = distutils.spawn.find_executable(exe)
        if found is not None and is_exe(found):
            return found
    return exe


def filter_grep(regex, strings, cmd='grep -E -n'):
    """Return list of indexes in `strings` which match `regex`"""
    arg_list = shlex.split(cmd)
    arg_list[0] = which(arg_list[0])
    arg_list.append(regex)
    cmd_str = ' '.join(pipes.quote(arg) for arg in arg_list)
    log.info('Command: ' + cmd_str)

    popen_kwargs = dict(creationflags=0x08000000) if os.name == 'nt' else {}
    try:
        grep = subprocess.Popen(arg_list,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, **popen_kwargs)
    except BaseException as exc:
        msg = 'Exception when executing "{}": {}'.format(cmd_str, exc)
        raise Exception(msg)
    out, err = grep.communicate('\n'.join(strings))
    if err or grep.returncode == 2:
        msg = 'Command "{}" exited with return code {} and stderr "{}"'.format(
            cmd_str, grep.returncode, err.strip())
        raise Exception(msg)
    res = []
    for out_str in out.splitlines():
        splitted = out_str.split(':', 1)
        try:
            assert len(splitted) == 2
            line_num = int(splitted[0])
        except:
            msg = 'Output "{}" does not contain line number (wrong grep arguments?)'
            raise Exception(msg.format(out_str))
        res.append(line_num - 1)
    return res


def rank(pattern, string, is_file=False):
    """Calculate rank of `string` when matching against `pattern`."""

    def _is_bigword_sep(ch):
        if is_file:
            return ch == os.sep
        return not (ch.isalnum() or ch in ['-', '_'])

    def _is_same_bigword(s, prev, curr):
            return not any(map(_is_bigword_sep, list(s[prev:curr])))

    def _starts_bigword(s, i):
        return i == 0 or _is_bigword_sep(s[i - 1])

    def _consecutive_words(s, first, second):
        for i in range(first + 1, second):
            if _word_boundary(s[i-1], s[i]) and s[i].isalpha():
                return False
        return True

    def _rank_match(string, match):
        log.debug('Ranking match ' + str(match))
        r = 0.0
        prev = -2
        for i in match:
            log.debug('Scoring {}-th character "{}"'.format(i, string[i]))
            if i == prev + 1:
                log.debug('consecutuve letters')
                w = 0
            elif (prev >= 0 and _consecutive_words(string, prev, i) and
                  not _starts_bigword(string, i)):
                log.debug('consecutuve words')
                w = 20  # bonus for letters consecutive words
            elif prev >= 0 and _is_same_bigword(string, prev, i):
                log.debug('within the same big word')
                w = 50
            elif _starts_bigword(string, i):
                log.debug('letter starting big word')
                w = 70  # bonus letters starting big words
            else:
                log.debug('normal')
                w = 100
            log.debug('weight ' + str(w))
            r += w
            prev = i
        log.debug('total weight ' + str(r))
        r = r / len(pattern)  # normalize
        r = r * (len(string) ** 0.05)  # bonus for shorter string

        # big bonus for matches entirely in filenames
        if is_file:
            basename_start = len(os.path.split(string)[0])
            if match[0] >= basename_start:
                r = r / 10

        return r

    log.debug('Ranking "{}" with pattern "{}"'.format(string, pattern))
    matches = _match_generator(pattern, string)
    match_list = list(matches)
    if not match_list:
        return 0
    log.debug('{} matches found'.format(len(match_list)))
    ranked_matches = [(_rank_match(string, m), m) for m in match_list]
    best_rank, best_match = min(ranked_matches, key=lambda x: x[0])
    return best_rank


def regex_cmd(args):
    print(make_regex(args.pattern, dialect=args.dialect), end='')
    return 0


def filter_cmd(args):
    strings = [str.strip(line, '\r\n') for line in sys.stdin]
    regex = make_regex(args.pattern)
    try:
        line_nums = filter_grep(regex, strings, args.grep_cmd)
    except BaseException as exc:
        log.error(exc)
        return 2
    results = [strings[line_num] for line_num in line_nums]

    ranked_results = [(rank(args.pattern, res,
                            is_file=args.file) if args.rank else 0, res)
                      for res in results]
    ranked_results.sort(key=operator.itemgetter(0), reverse=args.reverse)

    for score, line in ranked_results:
        if args.rank and args.loglevel <= logging.DEBUG:
            print(score, end=' ')
        print(line)

    return 0 if results else 1


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--debug',
                        action='store_const',
                        dest='loglevel',
                        const=logging.DEBUG,
                        default=logging.WARNING)
    parser.add_argument('-v', '--verbose',
                        action='store_const',
                        dest='loglevel',
                        const=logging.INFO)

    subparsers = parser.add_subparsers(dest='cmd', help='Sub-commands.')

    regex_parser = subparsers.add_parser('regex', help='Generate regular expression.')
    regex_parser.add_argument('--vim',
                              action='store_const',
                              dest='dialect',
                              const='vim',
                              default='grep',
                              help='Use vim dialect')
    regex_parser.add_argument('pattern')
    regex_parser.set_defaults(func=regex_cmd)

    filter_parser = subparsers.add_parser('filter',
                                          help='Filter input through pattern.')
    filter_parser.add_argument('--cmd',
                               dest='grep_cmd',
                               default='grep -E -n',
                               help='Grep command.')
    filter_parser.add_argument('--rank',
                               action='store_true',
                               help='Sort matched strings by rating.')
    filter_parser.add_argument('--file',
                               action='store_true',
                               default=False,
                               help='Assume input consists of file names.')
    filter_parser.add_argument('--reverse',
                        action='store_true',
                        default=False,
                        help='Reverse the sorting order.')
    filter_parser.add_argument('pattern')
    filter_parser.set_defaults(func=filter_cmd)

    args = parser.parse_args()

    logging.basicConfig(format='%(message)s', level=args.loglevel)
    return args.func(args)


if __name__ == '__main__':
    sys.exit(main())
