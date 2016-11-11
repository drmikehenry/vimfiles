[![Build Status](https://travis-ci.org/mhinz/vim-grepper.svg?branch=master)](https://travis-ci.org/mhinz/vim-grepper)

![vim-grepper](https://raw.githubusercontent.com/mhinz/vim-grepper/master/pictures/grepper-logo.png)

--

Use your **favorite grep tool**
([ag](https://github.com/ggreer/the_silver_searcher),
[ack](http://beyondgrep.com), [git grep](https://git-scm.com/docs/git-grep),
[ripgrep](https://github.com/BurntSushi/ripgrep),
[pt](https://github.com/monochromegane/the_platinum_searcher),
[sift](https://sift-tool.org),
[findstr](https://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/findstr.mspx),
grep) to start an **asynchronous search**. All matches will be put in a
**quickfix or location list**.

This plugin is written in pure VimL and works with Vim and Neovim.

--

- [Prompt](https://github.com/mhinz/vim-grepper/wiki/using-the-prompt): Use
  `:Grepper` to open a prompt, enter your query, optionally cycle through the
  list of tools, fire up the search.
- [Operator](https://github.com/mhinz/vim-grepper/wiki/using-the-operator): Use
  the current visual selection to pre-fill the prompt or start searching right
  away.
- [Commands](https://github.com/mhinz/vim-grepper/wiki/using-the-commands):
  `:Grepper` supports a wide range of flags which makes it extremely flexible.
  All supported tools come with their own command for convenience:
  `:GrepperGit`, `:GrepperAg`, and so on. They're all built atop of `:Grepper`.
- [Custom tools](https://github.com/mhinz/vim-grepper/wiki/Add-a-tool): Changing
  the behaviour of the default tools is very easy. And so is adding new tools.

_The truth is out there. And in `:h grepper`. And in the
[wiki](https://github.com/mhinz/vim-grepper/wiki)._

## Installation

Use your favorite plugin manager. E.g.
[vim-plug](https://github.com/junegunn/vim-plug):

    Plug 'mhinz/vim-grepper'

## Demo

General usage:

![vim-grepper](https://github.com/mhinz/vim-grepper/blob/master/pictures/grepper-demo.gif)

Grepping only files currently loaded in Vim:

![vim-grepper](https://github.com/mhinz/vim-grepper/blob/master/pictures/grepper-demo2.gif)

## Feedback

If you like this plugin, star it! It's a great way of getting feedback. The same
goes for reporting issues or feature requests.

Contact: [Twitter](https://twitter.com/_mhinz_)
