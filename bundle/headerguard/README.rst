******************************************************
Headerguard -  Add header guards to C/C++ header files
******************************************************

It is a common practice to insert header guards into C/C++ header files to
allow a header to be included multiple times.  A header guard for file
HeaderName.h typically looks something like this::

  #ifndef HEADERNAME_H
  #define HEADERNAME_H

    ...header content...

  #endif /* HEADERNAME_H */

Headerguard provides methods for inserting and updating header guards, and for
tailoring the header guard style to fit local conventions.  It checks for a
pre-existing header guard, and if found, modifies the existing guard in-place.

See documentation in doc/headerguard.txt for installation, customization, and
usage instructions.

Developed by Michael Henry (vim at drmikehenry.com).

Distributed under Vim's license.

Git repository:   https://github.com/drmikehenry/vim-headerguard
