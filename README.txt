Building Vim
============

~/.vim/buildtool automates the process of building vim.  Run with
no arguments for usage help.

Note: Stock Vim builds may not include all features (e.g., Ruby support),
so some plugins won't work unless a re-built Vim is used.

Read ~/.vim/doc/notes.txt for build dependencies that must be installed
prior to building.

If you have a pre-built binary tarball, install as:

  sudo tar -C / -xf /path/to/vim-7.3.123.i386.tar.gz

To setup for Unix (Linux, mac)
==============================

First, checkout vimfiles to ``~/.vim`` (such that this README.txt file ends up
as ``~/.vim/README.txt``).  Using Subversion, this might be::

  svn co https://server/svn/.../vimfiles ~/.vim

Next, choose one of these methods:

- Automated method (preferred)::

    ~/.vim/setup.py

- Manual method::

    cp ~/.vim/home.vimrc ~/.vimrc

To setup for Windows
====================

Vim will look for your ``vimfiles`` in your ``USERPROFILE`` directory, which
will typically be ``C:\Documents and Settings\USERNAME`` or
``C:\Users\USERNAME``, but may be different when on a network.

It's easiest to use this default location:

- Start ``cmd.exe`` (Start | Run | cmd).

- The current working directory will typically be the ``USERPROFILE``
  directory, but you can confirm this location by executing::

    set USERPROFILE

- Checkout vimfiles below this directory. Using Subversion, this might be::

    svn co https://server/svn/.../vimfiles vimfiles

- Copy source-controlled ``home.vimrc`` file to become ``_vimrc``::

    copy vimfiles\home.vimrc _vimrc

If the default location is not suitable, you may move the ``vimfiles``
directory elsewhere and inform Vim of the new location.  Choose one of the
following methods for informing Vim:

- Method 1: Override HOME:

  - In Windows, the ``HOME`` environment variable does not exist by default.
    When Vim starts, if ``HOME`` is defined, it will use ``$HOME/vimfiles`` for
    ``VIMFILES`` (which points to the per-user configuration files).  If
    ``HOME`` is not defined, Vim will set it to the value ``%USERPROFILE%.

  - Therefore, to use a different location for ``VIMFILES``, set the value of
    ``HOME`` to someplace like ``c:\home\username``, and Vim will then set
    ``VIMFILES`` to ``c:\home\username\vimfiles``.

  With this method, move the ``vimfiles`` directory and the ``_vimrc`` file to
  the ``HOME`` directory.

- Method 2: Chain to alternate location:

  - With this method, copy the ``vimfiles\_vimrc`` file to the expected
    location specified by ``USERPROFILE``, as for the default case.

  - Modify ``%USERPROFILE%\_vimrc`` to extend your ``runtimepath`` to include
    a new location.  For example, to checkout ``vimfiles`` directly into ``C:``,
    add the following lines at the start of ``%USERPROFILE%\_vimrc``::

    " Prepend, append vimfiles paths from hard drive
    " to avoid slow %USERPROFILE% directory.
    set runtimepath^=c:\vimfiles
    set runtimepath+=c:\vimfiles\after

  - Now move the checkout of ``vimfiles`` to become ``C:\vimfiles``.

ctags support
-------------

For ctags support, ensure that Exuberant ctags.exe is in the PATH.  This will
enable the TagList plugin.

Ruby-based plugins
------------------

Install the Ruby programming language for Windows to enable the Ruby-based
plugins (e.g., Lusty Explorer) to work.  Ensure the Ruby interpreter is in the
PATH.  Also, ensure your build of Gvim for Windows includes the Ruby
interpreter. (Note: the "Vim without Cream" build does *not* include Ruby).
To see if Ruby is included, run the following from within Gvim::

  :echo has("ruby")
