Building Vim
============

~/.vim/buildtool automates the process of building vim.  Run with
no arguments for usage help.

Note: Stock Vim builds may not include all features (e.g., Ruby support),
so some plugins won't work unless a re-built Vim is used.

Read ~/.vim/doc/notes.txt for build dependencies that must be installed
prior to building.

If you have a pre-built binary tarballl, install as:

  sudo tar -C / -xf /path/to/vim-7.3.123.tar.gz

To setup for Unix (Linux, mac)
==============================

  Automated method (preferred)::

    ~/.vim/setup.py

  Manual method::

    cp ~/.vim/home.vimrc ~/.vimrc
    cd ~/.vim/ruby/command-t
    ruby extconf.rb
    make

To setup for Windows
====================

    copy home.vimrc %USERPROFILE%\_vimrc

On Windows, if you have a network-mounted %USERPROFILE% directory, you
can checkout to your hard drive in c:\vimfiles and place the following as
%USERPROFILE%\_vimrc:

  " Prepend, append vimfiles paths from hard drive
  " to avoid slow %USERPROFILE% directory.
  set runtimepath^=c:\vimfiles
  set runtimepath+=c:\vimfiles\after
