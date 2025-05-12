" Vim syntax highlighting for Jira issues
"
" Language:     Jira
" Maintainer:   Petr Zemek <s3rvac@petrzemek.net>
" Home Page:    https://github.com/s3rvac/vim-syntax-jira
" Last Change:  2024-02-14 15:12:41 +0100
"
" The MIT License (MIT)
"
" Copyright (c) 2024 Petr Zemek <s3rvac@petrzemek.net> and contributors.
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

" Quit if the syntax file has already been loaded.
if exists("b:current_syntax")
	finish
endif

" Preserve letter casing when matching.
syntax case match

" When highlighting, start from the beginning of the file. This slows the
" highlighting a bit, but fixes highlighting issues when scrolling through the
" file. Anyway, Jira tickets usually do not have thousands of lines, so this
" should be safe. I know, famous last words, right :-)?
syntax sync fromstart

" Headings
" --------

syntax match jiraHeading /^h[1-6]\. .*/

" Text effects
" ------------

syntax match jiraBold /\(^\| \)\@<=\*[^*]\+\*\($\| \)\@=/
syntax match jiraItalic /\(^\| \)\@<=_[^_]\+_\($\| \)\@=/
syntax match jiraCitation /\(^\| \)\@<=??[^?]\+??\($\| \)\@=/
syntax match jiraStrike /\(^\| \)\@<=-[^-]\+-\($\| \)\@=/
syntax match jiraUnderline /\(^\| \)\@<=+[^+]\++\($\| \)\@=/
syntax match jiraSuperscript /\(^\| \)\@<=\^[^^]\+\^\($\| \)\@=/
syntax match jiraSubscript /\(^\| \)\@<=\~[^~]\+\~\($\| \)\@=/
syntax region jiraMonospace start=/{{/ end=/}}/
syntax region jiraColorBlock start=/{color:[a-z]\+}/ end=/{color}/
syntax match jiraQuote /^bq\. .*/
syntax region jiraQuoteBlock start=/{quote}/ end=/{quote}/

" Text breaks
" -----------

syntax match jiraTextLineBreak /\\\\$/
syntax match jiraRuller /^----$/
syntax match jiraDashLong /^---$/
syntax match jiraDashShort /^--$/

" Links
" -----

syntax region jiraLink start=/\[/ end=/\]/
syntax match jiraLinkAnchor /{anchor:[^}]\+}/

" Lists
" -----

syn match jiraListMarker /^\s*[-*#]\+\s\+/

" Images and attachments
" ----------------------

syntax match jiraImageOrAttachment /^!.\+!$/

" Tables
" ------

syn match jiraTable /^|.*|$/

" Advanced formatting
" -------------------

syntax region jiraNoFormatBlock start=/{noformat}/ end=/{noformat}/
syntax region jiraPanelBlock start=/{panel\(:.*\)}/ end=/{panel}/
syntax region jiraCodeBlock start=/{code\(:.*\)}/ end=/{code}/

" Misc
" ----

syntax match jiraMisc /\(:)\|:(\|:P\|:D\|;)\|(y)\|(n)\|(i)\|(\/)\|(x)\|(!)\|(+)\|(-)\|(?)\|(on)\|(off)\|(\*)\|(\*r)\|(\*g)\|(\*b)\|(\*y)\|(flag)\|(flagoff)\)/

" Highlighting
" ------------

highlight default jiraBold term=bold cterm=bold gui=bold
highlight default jiraItalic term=italic cterm=italic gui=italic
highlight default jiraStrike term=strikethrough cterm=strikethrough gui=strikethrough
highlight default jiraSubscript term=italic cterm=italic gui=italic
highlight default jiraSuperscript term=italic cterm=italic gui=italic
highlight default jiraUnderline term=underline cterm=underline gui=underline
highlight default link jiraCitation Comment
highlight default link jiraCodeBlock String
highlight default link jiraColorBlock String
highlight default link jiraDashLong Delimiter
highlight default link jiraDashShort Delimiter
highlight default link jiraHeading Title
highlight default link jiraImageOrAttachment Special
highlight default link jiraLink Underlined
highlight default link jiraLinkAnchor Label
highlight default link jiraListMarker Statement
highlight default link jiraMisc Special
highlight default link jiraMonospace String
highlight default link jiraNoFormatBlock String
highlight default link jiraPanelBlock String
highlight default link jiraQuote Comment
highlight default link jiraQuoteBlock Comment
highlight default link jiraRuller Delimiter
highlight default link jiraTable Structure
highlight default link jiraTextLineBreak Special

" Make sure that the syntax file is loaded at most once.
let b:current_syntax = "jira"
