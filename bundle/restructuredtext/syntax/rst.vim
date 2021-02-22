" Vim reST syntax file
" Language: reStructuredText documentation format
" Maintainer: Marshall Ward <marshall.ward@gmail.com>
" Previous Maintainer: Nikolai Weibull <now@bitwi.se>
" Website: https://github.com/marshallward/vim-restructuredtext
" Latest Revision: 2020-03-31

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case ignore

syn match   rstTransition  /^[=`:.'"~^_*+#-]\{4,}\s*$/

syn cluster rstCruft                contains=rstEmphasis,rstStrongEmphasis,
      \ rstInterpretedTextOrHyperlinkReference,rstInlineLiteral,
      \ rstSubstitutionReference, rstInlineInternalTargets,rstFootnoteReference,
      \ rstHyperlinkReference

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Literal blocks typically look like this:
"
"   Some non-literal text followed by double colons::
"
"     This part is literal.
"     And so is this.
"
"   Back to non-literal text here (since it lines up below "Some non-literal").
"
" Literal mode turns off when the level of indentation decreases back to
" the original amount of indentation on the line with the double colons.
" Put another way, literal mode remains as long as there is more
" leading whitespace than was found at the start of the line with the double
" colons.
"
" When the double colons are on a bulleted or numbered line, however, literal
" mode stops once the indentation decreases to match the first non-whitespace
" position *after* the bullet, e.g.::
"
"   - A bullet followed by double colons::
"
"       This part is literal.
"       And so is this.
"
"     Back to non-literal text here (since it lines up below "A bullet").
"
" For this case, the amount of leading whitespace is calculated by treating
" the bullet character or the line number as if they were composed of spaces.
" Consider this example:
"
"   - This is a bullet.
"
"     - Here is a sub-bullet with double colons::
"
"         This part is literal.
"         And so is this.
"
"       Back to non-literal text here (since it lines up below "Here is").
"       This line is indented four spaces from "- This is".
"
" In the above example, the leading whitespace threshold is four spaces: two
" spaces before "- Here is", plus the bullet character ("-") converted to a
" space, plus the space following the bullet.  Literal mode remains as long as
" there is more than the threshold four spaces of indentation.
"
" A valid bulleted line begins with zero or more whitespace characters, a single
" bullet character ("-", "+", or "*"), and whitespace.
"
" As explained in
" https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html#enumerated-lists,
" a valid numbered line begins with zero or more whitespace characters followed
" by an enumerator.  An enumerator consists of an enumeration sequence member
" and formatting, followed by whitespace. The following enumeration sequences
" are recognized:
"
"   arabic numerals: 1, 2, 3, ... (no upper limit).
"   uppercase alphabet characters: A, B, C, ..., Z.
"   lower-case alphabet characters: a, b, c, ..., z.
"   uppercase Roman numerals: I, II, III, IV, ..., MMMMCMXCIX (4999).
"   lowercase Roman numerals: i, ii, iii, iv, ..., mmmmcmxcix (4999).
"
" In addition, the auto-enumerator, "#", may be used to automatically enumerate
" a list.  The following formatting types are recognized:
"
"   suffixed with a period: "1.", "A.", "a.", "I.", "i.".
"   surrounded by parentheses: "(1)", "(A)", "(a)", "(I)", "(i)".
"   suffixed with a right-parenthesis: "1)", "A)", "a)", "I)", "i)".
"
" Therefore, the threshold leading whitespace, w, could be described by:
"
"   let w = whitespace at the start of the line with double colons.
"   If this line starts with a bullet and whitespace, extend w by one space for
"   each character in the sequence (bullet + following whitespace).
"   If this line starts with a enumeration, extend w by one space for each
"   character in the enumeration (note that this includes the whitespace at the
"   end of the enumeration).
"
" The difficulty lies in trying to count the number of characters in either a
" (bullet + following whitespace) sequence or an enumeration.  In a syntax
" region, there doesn't appear to be any way to calculate the length of a
" captured group (such as '\z1') in the 'start=' section and pass that to the
" 'end=' section in such a way that the length can be used to require a match
" for a run of that many space characters.
"
" Consider this example:
"
"   -   Some bullet::
"
"         This part is literal.
"         And so is this.
"
"       Back to non-literal (since it lines up with "Some bullet").
"
" There is no indentation before "-   Some bullet::".  The equivalent amount of
" indentation before "Some numbered line" is four spaces (one for the "-" and
" three for the three following spaces).  This enumeration could be matched with
" a capturing pattern such as '\z(-\s\+\)' (a hyphen bullet, a period, and one
" or more whitespace characters); but there seems to be no direct way to convert
" this captured text into a requirement to match four whitespace characters in
" the 'end=' pattern.
"
" To work around this limitation, consider that if a bullet is present, it must
" be followed by at least one space; if the bullet is not present, then the
" space won't be present, either.  Consider the following pattern with three
" capturing groups, where the entire pattern is optional::
"
"   \(\z(-\)\z( \)\z(\s*)\)\?
"
" If no bullet is present, the above pattern fails to match, and all three
" captured groups are empty.  If the bullet is present with following
" whitespace, then \z1 holds the bullet, \z2 holds a single space, and \z3 holds
" any additional trailing whitespace.  Consider using the following pattern in
" 'end='::
"
"   \z2\z2\z3
"
" The above pattern will match a run of whitespace with the length we desire.
" When no bullet is present, it matches the empty string.  When a bullet is
" present, we know \z2 will be a single space, in which case the pattern matches
" a space for the bullet (the first \z2), the following space (the second \z2),
" and the remaining spaces (the \z3).
"
" A similar technique allows matching a enumeration.  In the above technique, we
" were matching a single bullet character, and we used \z2 in the bullet's
" position to effectively convert the bullet to a space.  For enumerations, we
" can match a fixed number, n, of non-whitespace characters, and convert them
" into n space characters by repeating \z2 that many times.  For example::
"
"   1. Some numbered line::
"
"        This part is literal.
"        And so is this.
"
"      Back to non-literal (since it lines up with "Some numbered").
"
" The following pattern matches optional single-digit enumerations like the one
" above::
"
"   \(\z(\d\.\)\z( \)\z(\s*)\)\?
"
" If the above matches, we know that \z1 will be two characters (a digit and a
" period).  To replace that two-character sequence with two spaces in the
" 'end=' pattern, we use two copies of \z2 for these non-whitespace characters
" and an additional \z2 for the immediately following space, plus \z3 to match
" any additional whitespace::
"
"   \z2\z2\z2\z3
"
" By carefully matching runs of known-length non-whitespace characters,
" we can convert these runs into runs of equal numbers of space characters by
" repeating the group which captured a single space the desired number of times.
"
" Bullets and enumeration patterns can then be grouped by the number of
" non-whitespace characters before the single following space.  Consider the
" samples below:
"
"   1-character sequences:
"
"   - Bullets::
"
"       -
"       +
"       *
"
"   2-character sequences::
"
"     #.
"     #)
"     1.
"     1)
"     a)
"
"   3-character sequences::
"
"     12.
"     ab)
"     (a)
"     (#)
"
"   4-character sequences::
"
"     123.
"     abc)
"     (ab)
"
" Overall, then, a pattern to match the start of a literal block with an
" optional bullet or enumeration could be structured as the following captured
" groups::
"
"   \z(any leading whitespace)
"   (
"     (
"       (one-character sequence)   \z(one space) |
"       (two-character sequence)   \z(one space) |
"       (three-character sequence) \z(one space) |
"       (four-character sequence)  \z(one space) |
"       (five-character sequence)  \z(one space) |
"       (six-character sequence)   \z(one space) |
"       (seven-character sequence) \z(one space)
"     )
"     \z(any extra whitespace)
"   )\?
"   any characters
"   ::
"   end-of-line
"
" This uses all nine capture groups, \z1 through \z9, to support the largest
" number of digits in enumerations (up to six digits and a period, for example).
"
" In the above, \z1 holds the leading whitespace, and \z9 holds any extra
" whitespace.  Each of the remaining capture groups will hold a single space if
" their corresponding n-character sequence matched, and empty otherwise.  The
" group can be repeated n times to convert the n-character sequence into n
" spaces.  For example, \z3\z3\z3 will be three spaces if a three-character
" sequence is matched, and empty otherwise.  Further, \z2\z2\z3\z3\z3 will be
" two spaces for a 2-character match, three spaces for a three-character match,
" and empty otherwise.
"
" Therefore, the threshold whitespace pattern is given by the concatenation of
" all of the below patterns::
"
"   \z1
"   \z2\z2
"   \z3\z3\z3
"   \z4\z4\z4\z4
"   \z5\z5\z5\z5\z5
"   \z6\z6\z6\z6\z6\z6
"   \z7\z7\z7\z7\z7\z7\z7
"   \z8\z8\z8\z8\z8\z8\z8\z8
"   \z9

" Return a pattern for the given number of digits (in enumerations).
function! s:digits_pat(num_digits)
    if a:num_digits == 1
        " A lone "digit" includes numbers, letters and '#'.
        return '[0-9a-zA-Z#]'
    endif
    " Multiple "digits" comprise numbers and letters (but not '#').
    return '[0-9a-zA-Z]\{' . a:num_digits . '}'
endfunction

" Build up s:pat, a pattern to detect the start of rstLiteral.

" Begin group for everything before double-colon:
let s:pat = '\('

" \z1 captures optional leading whitespace:
let s:pat .= '^\z(\s*\)'

" Begin optional capture of bullet or enumeration:
let s:pat .= '\('

" n=1: A bullet character and \z2 capturing a space:
let s:pat .= '[-+*]\z( \)'

" s:n is the number of non-whitespace characters in the enumeration.
" Iterate from 2 through 7 (capturing into \z3 through \z8).
let s:n = 2
while s:n <= 7
    let s:pat .= '\|\('

    " Handle 'dddd.' and 'dddd)':
    let s:pat .= s:digits_pat(s:n - 1) . '[).]'

    " If enough characters, handle the '(ddd)' case:
    if s:n >= 3
        let s:pat .= '\|(' . s:digits_pat(s:n - 2) . ')'
    endif

    let s:pat .= '\)'

    " \z(n+1) captures a space:
    let s:pat .= '\z( \)'

    let s:n += 1
endwhile

" End optional capture of bullet or enumeration:
let s:pat .= '\)\?'

" Trailing whitespace in \z9
let s:pat .= '\z( *\)'

" Finish with arbitrary characters, then close the group:
let s:pat .= '.*\)'

" Use a zero-width look-behind for everything before double-colon:
let s:pat .= '\@<='

" End with double-colon at the end of the line followed by a blank line:
let s:pat .= '::\n\s*\n'

" Now build up the corresponding end pattern, s:end_pat.

" Match leading whitespace:
let s:end_pat = '^\(\z1'

" Then match the remaining characters of threshold whitespace for each
" capture group:
let s:end_pat .= '\z2\z2'
let s:end_pat .= '\z3\z3\z3'
let s:end_pat .= '\z4\z4\z4\z4'
let s:end_pat .= '\z5\z5\z5\z5\z5'
let s:end_pat .= '\z6\z6\z6\z6\z6\z6'
let s:end_pat .= '\z7\z7\z7\z7\z7\z7\z7'
let s:end_pat .= '\z8\z8\z8\z8\z8\z8\z8\z8'

" Require at least one more space to stay in literal block; then negate the
" match to exit literal mode:
let s:end_pat .= '\s\+\)\@!'

" Build up 'syn' command:
let s:syn = "syn region  rstLiteralBlock         matchgroup=rstDelimiter"
let s:syn .= " start='" . s:pat . "'"
let s:syn .= " skip='^\s*$'"
let s:syn .= " end='" . s:end_pat . "'"
let s:syn .= " contains=@NoSpell"

" Change to 0 to compare with original:
if 1
execute s:syn
else
syn region  rstLiteralBlock         matchgroup=rstDelimiter
      \ start='\(^\z(\s*\).*\)\@<=::\n\s*\n' skip='^\s*$' end='^\(\z1\s\+\)\@!'
      \ contains=@NoSpell
endif

syn region  rstQuotedLiteralBlock   matchgroup=rstDelimiter
      \ start="::\_s*\n\ze\z([!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]\)"
      \ end='^\z1\@!' contains=@NoSpell

syn region  rstDoctestBlock         oneline display matchgroup=rstDelimiter
      \ start='^>>>\s' end='^$'

syn region  rstTable                transparent start='^\n\s*+[-=+]\+' end='^$'
      \ contains=rstTableLines,@rstCruft
syn match   rstTableLines           contained display '|\|+\%(=\+\|-\+\)\='

syn region  rstSimpleTable          transparent
      \ start='^\n\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
      \ end='^$'
      \ contains=rstSimpleTableLines,@rstCruft
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(=\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(=\+\)\@>\%(\s*\)\@>\)\+\)\@>$'
syn match   rstSimpleTableLines     contained display
      \ '^\%(\s*\)\@>\%(\%(-\+\)\@>\%(\s\+\)\@>\)\%(\%(\%(-\+\)\@>\%(\s*\)\@>\)\+\)\@>$'

syn cluster rstDirectives           contains=rstFootnote,rstCitation,
      \ rstHyperlinkTarget,rstExDirective

syn match   rstExplicitMarkup       '^\s*\.\.\_s'
      \ nextgroup=@rstDirectives,rstComment,rstSubstitutionDefinition

" "Simple reference names are single words consisting of alphanumerics plus
" isolated (no two adjacent) internal hyphens, underscores, periods, colons
" and plus signs."
let s:ReferenceName = '[[:alnum:]]\%([-_.:+]\?[[:alnum:]]\+\)*'

syn keyword     rstTodo             contained FIXME TODO XXX NOTE

execute 'syn region rstComment contained' .
      \ ' start=/.*/'
      \ ' skip=+^$+' .
      \ ' end=/^\s\@!/ contains=rstTodo'

execute 'syn region rstFootnote contained matchgroup=rstDirective' .
      \ ' start=+\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstCruft,@NoSpell'

execute 'syn region rstCitation contained matchgroup=rstDirective' .
      \ ' start=+\[' . s:ReferenceName . '\]\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstCruft,@NoSpell'

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_\%(_\|[^:\\]*\%(\\.[^:\\]*\)*\):\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget contained matchgroup=rstDirective
      \ start='_`[^`\\]*\%(\\.[^`\\]*\)*`:\_s' skip=+^$+ end=+^\s\@!+

syn region rstHyperlinkTarget matchgroup=rstDirective
      \ start=+^__\_s+ skip=+^$+ end=+^\s\@!+

execute 'syn region rstExDirective contained matchgroup=rstDirective' .
      \ ' start=+' . s:ReferenceName . '::\_s+' .
      \ ' skip=+^$+' .
      \ ' end=+^\s\@!+ contains=@rstCruft,rstLiteralBlock,rstExplicitMarkup'

execute 'syn match rstSubstitutionDefinition contained' .
      \ ' /|.*|\_s\+/ nextgroup=@rstDirectives'

function! s:DefineOneInlineMarkup(name, start, middle, end, char_left, char_right)
  " Only escape the first char of a multichar delimiter (e.g. \* inside **)
  if a:start[0] == '\'
    let first = a:start[0:1]
  else
    let first = a:start[0]
  endif

  if a:start != '``'
    let rst_contains=' contains=rstEscape' . a:name
    execute 'syn match rstEscape'.a:name.' +\\\\\|\\'.first.'+'.' contained'
  else
    let rst_contains=''
  endif

  execute 'syn region rst' . a:name .
        \ ' start=+' . a:char_left . '\zs' . a:start .
        \ '\ze[^[:space:]' . a:char_right . a:start[strlen(a:start) - 1] . ']+' .
        \ a:middle .
        \ ' end=+' . a:end . '\ze\%($\|\s\|[''"’)\]}>/:.,;!?\\-]\)+' .
        \ rst_contains

  if a:start != '``'
    execute 'hi def link rstEscape'.a:name.' Special'
  endif
endfunction

" TODO: The "middle" argument may no longer be useful here.
function! s:DefineInlineMarkup(name, start, middle, end)
  if a:middle == '`'
    let middle = ' skip=+\s'.a:middle.'+'
  else
    let middle = ' skip=+\\\\\|\\' . a:middle . '\|\s' . a:middle . '+'
  endif

  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, "'", "'")
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '"', '"')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '(', ')')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\[', '\]')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '{', '}')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '<', '>')
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '’', '’')

  " TODO: Additional whitespace Unicode characters: Pd, Po, Pi, Pf, Ps
  call s:DefineOneInlineMarkup(a:name, a:start, middle, a:end, '\%(^\|\s\|\%ua0\|[/:]\)', '')

  execute 'syn match rst' . a:name .
        \ ' +\%(^\|\s\|\%ua0\|[''"([{</:]\)\zs' . a:start .
        \ '[^[:space:]' . a:start[strlen(a:start) - 1] . ']'
        \ a:end . '\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

  execute 'hi def link rst' . a:name . 'Delimiter' . ' rst' . a:name
endfunction

call s:DefineInlineMarkup('Emphasis', '\*', '\*', '\*')
call s:DefineInlineMarkup('StrongEmphasis', '\*\*', '\*', '\*\*')
call s:DefineInlineMarkup('InterpretedTextOrHyperlinkReference', '`', '`', '`_\{0,2}')
call s:DefineInlineMarkup('InlineLiteral', '``', '`', '``')
call s:DefineInlineMarkup('SubstitutionReference', '|', '|', '|_\{0,2}')
call s:DefineInlineMarkup('InlineInternalTargets', '_`', '`', '`')

" Sections are identified through their titles, which are marked up with
" adornment: "underlines" below the title text, or underlines and matching
" "overlines" above the title. An underline/overline is a single repeated
" punctuation character that begins in column 1 and forms a line extending at
" least as far as the right edge of the title text.
"
" It is difficult to count characters in a regex, but we at least special-case
" the case where the title has at least three characters to require the
" adornment to have at least three characters as well, in order to handle
" properly the case of a literal block:
"
"    this is the end of a paragraph
"    ::
"       this is a literal block
syn match   rstSections "\v^%(([=`:.'"~^_*+#-])\1+\n)?.{1,2}\n([=`:.'"~^_*+#-])\2+$"
    \ contains=@Spell
syn match   rstSections "\v^%(([=`:.'"~^_*+#-])\1{2,}\n)?.{3,}\n([=`:.'"~^_*+#-])\2{2,}$"
    \ contains=@Spell

" TODO: Can’t remember why these two can’t be defined like the ones above.
execute 'syn match rstFootnoteReference contains=@NoSpell' .
      \ ' +\%(\s\|^\)\[\%(\d\+\|#\%(' . s:ReferenceName . '\)\=\|\*\)\]_+'

execute 'syn match rstCitationReference contains=@NoSpell' .
      \ ' +\%(\s\|^\)\[' . s:ReferenceName . '\]_\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)+'

execute 'syn match rstHyperlinkReference' .
      \ ' /\<' . s:ReferenceName . '__\=\ze\%($\|\s\|[''")\]}>/:.,;!?\\-]\)/'

syn match   rstStandaloneHyperlink  contains=@NoSpell
      \ "\<\%(\%(\%(https\=\|file\|ftp\|gopher\)://\|\%(mailto\|news\):\)[^[:space:]'\"<>]\+\|www[[:alnum:]_-]*\.[[:alnum:]_-]\+\.[^[:space:]'\"<>]\+\)[[:alnum:]/]"

syn region rstCodeBlock contained matchgroup=rstDirective
      \ start=+\%(sourcecode\|code\%(-block\)\=\)::\s*\(\S*\)\?\s*\n\%(\s*:.*:\s*.*\s*\n\)*\n\ze\z(\s\+\)+
      \ skip=+^$+
      \ end=+^\z1\@!+
      \ contains=@NoSpell
syn cluster rstDirectives add=rstCodeBlock

if !exists('g:rst_syntax_code_list')
    " A mapping from a Vim filetype to a list of alias patterns (pattern
    " branches to be specific, see ':help /pattern'). E.g. given:
    "
    "   let g:rst_syntax_code_list = {
    "       \ 'cpp': ['cpp', 'c++'],
    "       \ }
    "
    " then the respective contents of the following two rST directives:
    "
    "   .. code:: cpp
    "
    "       auto i = 42;
    "
    "   .. code:: C++
    "
    "       auto i = 42;
    "
    " will both be highlighted as C++ code. As shown by the latter block
    " pattern matching will be case-insensitive.
    let g:rst_syntax_code_list = {
        \ 'vim': ['vim'],
        \ 'java': ['java'],
        \ 'cpp': ['cpp', 'c++'],
        \ 'lisp': ['lisp'],
        \ 'php': ['php'],
        \ 'python': ['python'],
        \ 'perl': ['perl'],
        \ 'sh': ['sh'],
        \ }
elseif type(g:rst_syntax_code_list) == type([])
    " backward compatibility with former list format
    let s:old_spec = g:rst_syntax_code_list
    let g:rst_syntax_code_list = {}
    for s:elem in s:old_spec
        let g:rst_syntax_code_list[s:elem] = [s:elem]
    endfor
endif

for s:filetype in keys(g:rst_syntax_code_list)
    unlet! b:current_syntax
    " guard against setting 'isk' option which might cause problems (issue #108)
    let prior_isk = &l:iskeyword
    let s:alias_pattern = ''
                \.'\%('
                \.join(g:rst_syntax_code_list[s:filetype], '\|')
                \.'\)'

    exe 'syn include @rst'.s:filetype.' syntax/'.s:filetype.'.vim'
    exe 'syn region rstDirective'.s:filetype
                \.' matchgroup=rstDirective fold'
                \.' start="\c\%(sourcecode\|code\%(-block\)\=\)::\s\+'.s:alias_pattern.'\_s*\n\ze\z(\s\+\)"'
                \.' skip=#^$#'
                \.' end=#^\z1\@!#'
                \.' contains=@NoSpell,@rst'.s:filetype
    exe 'syn cluster rstDirectives add=rstDirective'.s:filetype

    " reset 'isk' setting, if it has been changed
    if &l:iskeyword !=# prior_isk
        let &l:iskeyword = prior_isk
    endif
    unlet! prior_isk
endfor

" Enable top level spell checking
syntax spell toplevel

" TODO: Use better syncing.
syn sync minlines=50 linebreaks=2

hi def link rstTodo                         Todo
hi def link rstComment                      Comment
hi def link rstSections                     Title
hi def link rstTransition                   rstSections
hi def link rstLiteralBlock                 String
hi def link rstQuotedLiteralBlock           String
hi def link rstDoctestBlock                 PreProc
hi def link rstTableLines                   rstDelimiter
hi def link rstSimpleTableLines             rstTableLines
hi def link rstExplicitMarkup               rstDirective
hi def link rstDirective                    Keyword
hi def link rstFootnote                     String
hi def link rstCitation                     String
hi def link rstHyperlinkTarget              String
hi def link rstExDirective                  String
hi def link rstSubstitutionDefinition       rstDirective
hi def link rstDelimiter                    Delimiter
hi def link rstInterpretedTextOrHyperlinkReference  Identifier
hi def link rstInlineLiteral                String
hi def link rstSubstitutionReference        PreProc
hi def link rstInlineInternalTargets        Identifier
hi def link rstFootnoteReference            Identifier
hi def link rstCitationReference            Identifier
hi def link rstHyperLinkReference           Identifier
hi def link rstStandaloneHyperlink          Identifier
hi def link rstCodeBlock                    String
if exists('g:rst_use_emphasis_colors')
    " TODO: Less arbitrary color selection
    hi def rstEmphasis          ctermfg=13 term=italic cterm=italic gui=italic
    hi def rstStrongEmphasis    ctermfg=1 term=bold cterm=bold gui=bold
else
    hi def rstEmphasis          term=italic cterm=italic gui=italic
    hi def rstStrongEmphasis    term=bold cterm=bold gui=bold
endif

let b:current_syntax = "rst"

let &cpo = s:cpo_save
unlet s:cpo_save
