# This is a "style" file for `mdl` (`markdownlint`):
# - https://github.com/markdownlint/markdownlint/

# References:
#
# - Creating a "configuration":
#   https://github.com/markdownlint/markdownlint/blob/main/docs/configuration.md
#
#   Note that a configuration file merely allows adjustment of things you
#   can specify on the `mdl` command line.  If you want to control the
#   parameters of a particular rule, a configuration file is insufficient by
#   itself, but is still necessary in order to point to a full "style" file that
#   can adjust rule parameters.
#
# - Creating a "style":
#   https://github.com/markdownlint/markdownlint/blob/main/docs/creating_styles.md
#
#   A "style" file has full control over the set of rules and their parameters.
#
# - Explanations of rules:
#   https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md

# Usage
#   Via `g:ale_markdown_mdl_options` in `vimrc`, `mdl` will be pointed to this
#   style file (unless `~/.mdlrc` exists, in which case that will take
#   precedence).

all

# MD005 - Inconsistent indentation for list items at the same level
#
# MD005 is supposed to catch things like this:
#
#   * Item 1
#       * Nested Item 1
#       * Nested Item 2
#      * A misaligned item
#
# Unfortunately, it requires this consistency across all same-level bullets,
# even if they are in a different top-level bullet:
#
#   * Item 1
#       * Each sub-bullet is
#       * Indented by four spaces
#
#   * Item 2
#     * Each sub-bullet is
#     * Indented by two spaces
#
# This would be OK if all bullets were the same; but ordered and unordered
# lists inherently have different amounts of desired indentation:
#
#   1. First ordered item
#      * Ideal indentation of three spaces
#
#   2. Second ordered item
#      * Ideal indentation of three spaces
#
#   - An unordered item
#     * Ideal indentation of two spaces
#
#   - Another unordered item
#     * Ideal indentation of two spaces
#
# MD005 complains that these second-level indentations are inconsistent.
#
# Instead of specifying how a sub-bullet should be indented as a function of the
# sub-bullet, it should be specified as a function of the parent bullet.
# Indentation below a bullet (ordered or not) depends on the indentation level
# of the text following the bullet, e.g.:
#
#   1. Indent three spaces below this line.
#      - This lines up with the `I` in `Indent`.
#
#   1.  Indent four spaces below this line.
#       - This still lines up with the `I` in `Indent`.
#
#   1.  Indent four spaces below this line.
#       1. Even if the indented sub-bullet is another type.
#
#   1.  Indent four spaces below this line.
#
#       Even if additional paragraphs are part of the top-level bullet.
#
# It is misguided to expect all level-two sub-bullets to have the same
# indentation without considering the parent context.
#
# Therefore, disable MD005.
exclude_rule 'MD005'

# MD007 - Unordered list indentation
#
# This rule is supposed to catch indentation errors for unordered bullets.
# It has the same misconceptions as MD005 above, in that it's defined in terms
# of the indentation of the sub-bullet itself, rather than as a function of the
# parent bullet.  For an unordered list with an unordered sub-list, a fixed
# indentation of 2 for the sub-bullet would work, e.g.:
#
#   - Outer list
#     - Sublist
#
# Unfortunately, the concept of "sub-list" seems to be defined only for
# unordered lists; the below three-layer structure is doomed to fail:
#
#   - Outer unordered
#
#     1. Ordered item
#
#        - Innermost unordered item
#
#     2. Second ordered item
#
# mdl doesn't even notice the existence of `1. Ordered item` when calculating
# the indentation for `- Innermost unordered item`; to make it happy with
# 2-space unordered indentation, you must write the above as the structurally
# incorrect two-level mishmash below:
#
#   - Outer unordered
#
#     1. Ordered item
#
#     - Innermost unordered item
#
#     2. Second ordered item
#
# The default used to be 2-space indentation, but it was changed to 3-space
# indentation because of problems with the misguided MD005 rule.
#
# To change back to 2-space indentation, use:
#   rule 'MD007', :indent => 2
#
# MD007 does catch some simple indentation errors with the above setting, e.g.:
#
#   - Outer item
#      - Indented by three; should be two.  mdl catches this.
#
# However, the detection is incorrect often enough to make it not worthwhile.
exclude_rule 'MD007'

# MD041 - First line in file should be a top-level header
exclude_rule 'MD041'

# MD029 - Ordered list item prefix
# This forces use of exactly one of these two styles:
#     1. first
#     1. second
#     1. third
#   or:
#     1. first
#     2. second
#     3. third
# Neither style is universally best, so disable this rule.
exclude_rule 'MD029'

# MD013 - Line length
# Occasional overly-long lines are unavoidable with URLs and the like.
exclude_rule 'MD013'

# MD024 - Multiple headers with the same content
# Should be able to use `:allow_different_nesting => true`, but doesn't
# seem to work.
exclude_rule 'MD024'

# MD036 - Emphasis used instead of a header
# This rule looks for single line paragraphs that consist entirely of emphasized
# text. It won't fire on emphasis used within regular text, multi-line
# emphasized paragraphs, and paragraphs ending in punctuation.
#
# It does complain about temporary notes left in a document as visual cues,
# e.g.:
#
#   **TODO**
#
# But that's probably OK because the goal is to draw attention back to this
# place in the document anyway.
#
# exclude_rule 'MD036'

# MD046 - Code block style
# This rule wants to insist on a single style for code blocks, which is
# excessively inflexible.  Different code block styles exist for good reasons.
exclude_rule 'MD046'
