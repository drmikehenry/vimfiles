vim-abbrev-matcher
==================

Abbreviation matcher plugin to be used as replacement matcher for [CtrlP] and
[Unite].

Unlike "traditional" fuzzy search it matches by beginnings of words. For
example, `fb` matches `foo_bar` but not `if_bar`. Words considered are groups of
alphabetic characters, groups of digits and "CamelCase" words. All other symbols,
including underscore `_` and dash `-` are word separators.

This allows faster narrowing of search results to a needed candidate, with less
typing.


TOC
-----------------

- [Rationale](#rationale)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Ranking](#ranking)
- [Standalone usage](#standalone)
- [Limitations](#limitations)


Rationale
---------

Programmers usually use finders like [CtrlP] and [Unite] mostly to quickly
navigate in large sources trees or jump to file/project tags. File paths and
identifiers can be seen as sequences of words and in order to find the needed
one people usually type first letters of some words (e.g. abbreviation).

For example in order to find a file `src/internal/main_engine.c` one would type
`me` or `meng` or, if there are many `main_engine` files, he will add some path
abbreviation and type `sime`. In the same way, in order to find identifier
`SaveFileDialogBox` one would type `sf` or `sfdb`.

However, these finders search in a "fuzzy" manner: they allow matching of
letters anywhere in the string. That is, these `sf` and `me` searches will give
you tons of irrelevant matches. Of course, more advanced finders go further and
try to prioritize "good" matches by using some kind of ranking algorithm. So in
the end you still will get what you want but probably you will need some
navigation with arrows and irrelevant matches will still pollute your view.

If you suffer from this problem, like I do, this plugin is for you! It's
blazingly fast, it gives you only abbreviation matches and has some simple
ranking built-in.


Requirements
------------
 - Vim compiled with `+python` support.

   The plugin was tested on Vim 7.4 with Python 2.7 on Linux and Windows but
   should work correctly with other platforms/versions. Mac testers are welcome!

 - Unix `grep` utility.

   Why **grep**, you may ask? Well, it is used for filtering candidates.  The
   abbreviation  pattern gets translated to a pretty complex regular expression
   with heavy use of `*`, `|`, `?` operators. It can be handled only by
   FSA-based regex engines such as one used by **grep** (some explanation
   [here](https://swtch.com/~rsc/regexp/regexp1.html), another such engine is
   Google's [RE2]). Backtracking-based engines used in scripting languages are
   too slow at such expressions and could not be used here.

   Besides, **grep** is installed by default in most Unix-like systems and
   engine is can be easily obtained on other platforms.

Here you can find Windows version:

- [GnuWin](http://sourceforge.net/projects/gnuwin32/files/grep/2.5.4/) has
rather old version dated 2010.
- [Git for Windows](https://git-scm.com/download/win) comes with many GNU tools
precompiled, including a fresh version of **grep**.


Installation
------------

For the plugin itself just use your favorite plugin manager.

### Enable for [Unite]
```vim
" use matcher for all sources
call unite#filters#matcher_default#use(['matcher_abbrev'])

" ...or for specific source
call unite#custom#source('line', 'matchers', 'matcher_abbrev')
```

It is also recommended to use included sorter which provides ranking mechanism
similar to [Selecta]:
```vim
" use sorter for all sources
call unite#filters#sorter_default#use(['sorter_abbrev'])

" ...or just for specific sources
call unite#custom#source('file,file_rec,file_rec/async,file_rec/git',
    \ 'sorters', 'sorter_abbrev')
```

### Enable for [CtrlP]:
```vim
let g:ctrlp_match_func = { 'match': 'ctrlp#abbrev_matcher#match' }
```


Configuration
-------------

- `g:abbrev_matcher_grep_exe` - path to *grep* executable.

  Defaults to `grep` on Unix and `grep.exe` on Windows. Use it to override path
  to *grep*. If only name is specified, the executable will be searched for in
  `PATH`.

- `g:abbrev_matcher_grep_args` - arguments to *grep* command.

  The default is `-E -n` which turns on regular expression support and tells
  *grep* to print numbers of matched lines (that is how we know what candidates
  were filtered).

Instead of `grep` you may use [ag] (The Silver Searcher) configured as:
```vim
let g:abbrev_matcher_grep_exe = 'ag'
let g:abbrev_matcher_grep_args = '--numbers'
```


Ranking
-------

Algorithm similar to [Selecta] is used. Each matched character of pattern is
assigned a score (lower is better). The rank of match is the sum of scores of
its characters.

In addition to "word" term (which is sometimes called "subword") a concept of
"big word" is introduced. Big words may consist of alpha-numeric characters, `_`
(undescore) and `-` (dash). So, valid identifiers in most programming languages
are "big words". In file searches, single path component (everything between
slashes) is a "big word".

When searching files, candidates where the match is fully within the last path
component ("basename") come first. Think of it as automatic
'ctrlp_by_filename' mode.

The score is calculated according to the following rules (in the order of
decreasing weight/importance):

* Consecutive characters, e.g. pattern `foobar` prefers `foobar` over `foo_bar`.
* Letters beginning consecutive words, e.g. `fb` prefers `foo_bar` over
  `foo_baz_bar`.
* Letters contained in the same "big word", e.g. `fb` prefers `foo_bar.c` over
  `/foo/bar.c`.
* Letter beginning "big word" is scored lower than that beginning a word inside
  a "big word", e.g. `fb` prefers `foo_bar_baz` over `baz_foo_bar`.
* Shorter matching strings are preferred, e.g. looking for `make` will first
  suggest you top-level `Makefile`.


Standalone usage
----------------
The Python script provided in `python2/abbrev_matcher.py` can also be used as a
standalone utility in two ways:

- As simple `grep`-like filtering utility, it reads *stdin* and prints only
lines matching the pattern.

```
cat some-file.txt | abbrev_matcher.py filter abc
```

- As regular expression generator, to be used in conjunction with other
utilities. For example:
```
ag `./abbrev_matcher.py regex abc`
```
will use `abc` abbreviation as pattern for [ag].


Limitations
-----------

The work is still in its early stage and therefore lacks some features:

- Only english patterns are supported. Implementing Unicode support may need
  some tweaking of *grep* regex generator.
- Only basic configuration is currently possible (for example, ranking algorithm
  is not configurable and can not be turned of for *CtrlP*).
- Highlighting of matched letters could be better. *Unite* is more limited in
  this  sense than *CtrlP*.


[CtrlP]: https://github.com/ctrlpvim/ctrlp.vim
[Unite]: https://github.com/Shougo/unite.vim
[Selecta]: https://github.com/garybernhardt/selecta
[RE2]: https://en.wikipedia.org/wiki/RE2_(software)
[ag]: http://geoff.greer.fm/ag/
