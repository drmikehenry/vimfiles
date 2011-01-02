To setup for Unix (Linux, mac):

  Automated method (preferred)::

    ~/.vim/setup.py

  Manual method::

    cp ~/.vim/home.vimrc ~/.vimrc
    cd ~/.vim/ruby/command-t
    ruby extconf.rb
    make

To setup for Windows::

    copy home.vimrc %USERPROFILE%\_vimrc

On Windows, if you have a network-mounted %USERPROFILE% directory, you
can checkout to your hard drive in c:\vimfiles and place the following as
%USERPROFILE%\_vimrc:

  " Prepend, append vimfiles paths from hard drive
  " to avoid slow %USERPROFILE% directory.
  set runtimepath^=c:\vimfiles
  set runtimepath+=c:\vimfiles\after
