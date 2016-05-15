#!/usr/bin/env python

import unittest
from abbrev_matcher import *


class BaseTest(unittest.TestCase):
    def assert_filter(self, pattern, matching=[], not_matching=[]):
        all_strings = matching + not_matching
        inds = filter_grep(make_regex(pattern), all_strings)
        self.assertEqual(inds, range(len(matching)))

    def assert_ranked(self, pattern, strings, **kwargs):
        self.assert_filter(pattern, matching=strings)
        ranked = sorted(reversed(strings),
                        key=lambda s: rank(pattern, s, **kwargs))
        self.assertEqual(ranked, strings)

    def assert_ranked_files(self, pattern, path_lists):
        path_strings = [os.path.join(*p) for p in path_lists]
        self.assert_ranked(pattern, path_strings, is_file=True)


class TestFilter(BaseTest):
    def test_basic(self):
        self.assert_filter('abc',
                          matching=['abc', 'ABC', 'Abc', 'aBC', 'aBc', 'AbC'])
        self.assert_filter('abc',
                          matching=['a_b_c', 'A_B_C', 'aa_bc', 'aa_bb_cc'])
        self.assert_filter('abc', matching=['AdBC', 'adBc'],
                          not_matching=['ADbc'])


class TestRank(BaseTest):
    def test_line_length(self):
        self.assert_ranked('abc', ['abc', 'abc abc'])

    def test_basic(self):
        # consecutive letters
        self.assert_ranked('foobar', ['some_foobar', 'foo_bar'])

        # consecutive words
        self.assert_ranked('fb', ['foo_bar_qux', 'foo_qux_bar'])
        self.assert_ranked('fb', ['qux_foo_bar', 'foo_qux_bar'])

        # same big word
        self.assert_ranked('fb', ['foo_bar', 'foo bar'])

        # letters starting big words
        self.assert_ranked('fq', ['for_bar qux', 'bar_foo qux'])


class TestRankFiles(BaseTest):
    def test_basic(self):
        # line length
        self.assert_ranked_files('fb', [['fb'], ['dir', 'fb']])

        # match within basename
        self.assert_ranked_files('fb', [['foo bar'], ['foo', 'bar']])


if __name__ == '__main__':
    unittest.main()
