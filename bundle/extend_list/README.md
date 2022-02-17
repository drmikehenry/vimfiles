# Extend List

Extend List is a plugin to add new elements to existing lists.

This plugin will find the most recent list, and add a new element to it.
Indentation and whitespace will be maintained, and the element number will be
incremented.

This plugin displays three distinct behaviors:

- If this is called within a list, a new element will be placed immediately
  following the existing list.
- If this is called on a blank line below a list, the new element will be placed
  on the current line.
- If there is no list, a new list will be started using the default.

## Installation

To install this plugin with Pathogen, you should clone this repository into your
bundle directory.

## Documentation

After generating the help tags (using `:Helptags`), the detailed documentation
can be found at `:help extend_list`.

## License

Distributed under Vim's license.  See `doc/extend_list.txt` for details.
