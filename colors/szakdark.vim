" szakdark color scheme
" It's a modified version of the ir_black color scheme.
" More at: http://blog.infinitered.com.

set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "szakdark"

if !exists("g:szakdark_subtle_search")
    let g:szakdark_subtle_search=0
endif

"hi Example         guifg=NONE        guibg=NONE        gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

" General colors
hi Normal           guifg=#bbbbbb     guibg=#0d0d0d     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi NonText          guifg=#303030     guibg=#1c1c1c     gui=NONE      ctermfg=236         ctermbg=234         cterm=NONE

hi Cursor           guifg=black       guibg=white       gui=NONE      ctermfg=black       ctermbg=white       cterm=reverse
hi LineNr           guifg=#4e4e4e     guibg=#262626     gui=NONE      ctermfg=239         ctermbg=235         cterm=NONE
hi CursorLineNr     guifg=#6c6c6c     guibg=#262626     gui=BOLD      ctermfg=242         ctermbg=235         cterm=BOLD
hi FoldColumn       guifg=#878700     guibg=#262626     gui=NONE      ctermfg=100         ctermbg=235         cterm=NONE
hi SignColumn       guifg=#00afff     guibg=#262626     gui=NONE      ctermfg=39          ctermbg=235         cterm=NONE

hi VertSplit        guifg=#c6c6c6     guibg=#767676     gui=NONE      ctermfg=251         ctermbg=243         cterm=NONE
hi StatusLine       guifg=#d0d0d0     guibg=#626262     gui=NONE      ctermfg=252         ctermbg=241         cterm=NONE
hi StatusLineNC     guifg=#767676     guibg=#3a3a3a     gui=italic    ctermfg=243         ctermbg=237         cterm=NONE

hi Folded           guifg=#a0a8b0     guibg=#384048     gui=NONE      ctermfg=NONE        ctermbg=darkgray    cterm=NONE
hi Title            guifg=#e3dab7     guibg=NONE        gui=BOLD      ctermfg=223         ctermbg=NONE        cterm=BOLD
hi Visual           guifg=NONE        guibg=#262D51     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=REVERSE

hi SpecialKey       guifg=#303030     guibg=#1c1c1c     gui=NONE      ctermfg=236         ctermbg=234         cterm=NONE

hi WildMenu         guifg=#e8e0c3     guibg=#222240     gui=NONE      ctermfg=187         ctermbg=17          cterm=NONE
hi PmenuSbar        guifg=black       guibg=white       gui=NONE      ctermfg=black       ctermbg=white       cterm=NONE
"hi Ignore           guifg=gray        guibg=black       gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

hi Error            guifg=red         guibg=#553333     gui=BOLD      ctermfg=white       ctermbg=red         cterm=NONE
hi ErrorMsg         guifg=white       guibg=#FF6C60     gui=BOLD      ctermfg=white       ctermbg=red         cterm=NONE
hi WarningMsg       guifg=white       guibg=#FF6C60     gui=BOLD      ctermfg=white       ctermbg=red         cterm=NONE
hi LongLineWarning  guifg=NONE        guibg=#371F1C     gui=underline ctermfg=NONE        ctermbg=NONE	      cterm=underline

" Message displayed in lower left, such as --INSERT--
hi ModeMsg          guifg=#00d7d7     guibg=#262626     gui=BOLD      ctermfg=DarkCyan    ctermbg=235         cterm=BOLD

" Spelling-related
if &t_Co > 255
    " The highlighting scheme sucks for spelling errors.  Tweak them
    " to be more readable.  Only do this for terminals that have
    " 256 colors or better... which happens to be most of mine.
    hi SpellBad   ctermbg=52
    hi SpellRare  ctermbg=53
    hi SpellLocal ctermbg=23
    hi SpellCap   ctermbg=17
endif

if &t_Co > 255 || has("gui_running")
    " The highlighting for going past the rightmost column is also
    " hard to read (or to harsh to read) in a black terminal.  Tweak
    " them too.
    hi HG_Subtle        ctermfg=white   ctermbg=52  guibg=red       guifg=white
    hi HG_Warning       ctermfg=white   ctermbg=136 guibg=#505000   guifg=lightgray
    hi HG_Error         ctermfg=white   ctermbg=160 guibg=red       guifg=white
    hi Highlight_tabs                   ctermbg=236 guibg=#303030   guifg=white
endif

if version >= 700 " Vim 7.x specific colors
  hi CursorLine     guifg=NONE        guibg=#232323     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
  hi CursorColumn   guifg=NONE        guibg=#232323     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
  hi MatchParen     guifg=#f6f3e8     guibg=#857b6f     gui=BOLD      ctermfg=white       ctermbg=darkgray    cterm=NONE
  hi Pmenu          guifg=#f6f3e8     guibg=#444444     gui=NONE      ctermfg=230         ctermbg=238         cterm=NONE
  hi PmenuSel       guifg=#000000     guibg=#cae682     gui=NONE      ctermfg=black       ctermbg=192         cterm=NONE

  if g:szakdark_subtle_search != 0
    hi Search       guifg=NONE        guibg=#404000     gui=NONE      ctermfg=NONE        ctermbg=58          cterm=NONE
  else
    hi Search       guifg=#c8c800     guibg=NONE        gui=reverse   ctermfg=3           ctermbg=NONE        cterm=reverse
  endif
endif

" Syntax highlighting
hi Comment          guifg=#7C7C7C     guibg=NONE        gui=NONE      ctermfg=darkgray    ctermbg=NONE        cterm=NONE
hi String           guifg=#5ac600     guibg=NONE        gui=NONE      ctermfg=green       ctermbg=NONE        cterm=NONE
hi Number           guifg=#FF73FD     guibg=NONE        gui=NONE      ctermfg=magenta     ctermbg=NONE        cterm=NONE

hi Keyword          guifg=#96CBFE     guibg=NONE        gui=BOLD      ctermfg=blue        ctermbg=NONE        cterm=BOLD
hi PreProc          guifg=#96CBFE     guibg=NONE        gui=NONE      ctermfg=blue        ctermbg=NONE        cterm=NONE
hi Conditional      guifg=#6699CC     guibg=NONE        gui=NONE      ctermfg=blue        ctermbg=NONE        cterm=NONE  " if else end

hi Todo             guifg=#8f8f8f     guibg=NONE        gui=NONE      ctermfg=red         ctermbg=NONE        cterm=NONE
hi Constant         guifg=#99CC99     guibg=NONE        gui=NONE      ctermfg=cyan        ctermbg=NONE        cterm=NONE

hi Identifier       guifg=#C6C5FE     guibg=NONE        gui=NONE      ctermfg=cyan        ctermbg=NONE        cterm=NONE
hi Function         guifg=#FFD2A7     guibg=NONE        gui=BOLD      ctermfg=brown       ctermbg=NONE        cterm=BOLD
hi Type             guifg=#C4C45A     guibg=NONE        gui=BOLD      ctermfg=yellow      ctermbg=NONE        cterm=BOLD
hi Statement        guifg=#6699CC     guibg=NONE        gui=NONE      ctermfg=lightblue   ctermbg=NONE        cterm=NONE

hi Special          guifg=#E18964     guibg=NONE        gui=NONE      ctermfg=white       ctermbg=NONE        cterm=NONE
hi Delimiter        guifg=#00A0A0     guibg=NONE        gui=NONE      ctermfg=cyan        ctermbg=NONE        cterm=NONE
hi Operator         guifg=white       guibg=NONE        gui=NONE      ctermfg=white       ctermbg=NONE        cterm=NONE

hi link Character       Constant
hi link Boolean         Constant
hi link Float           Number
hi link Repeat          Statement
hi link Label           Statement
hi link Exception       Statement
hi link Include         PreProc
hi link Define          PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link Tag             Special
hi link SpecialChar     Special
hi link SpecialComment  Special
hi link Debug           Special


" Special for Ruby
hi rubyRegexp                  guifg=#B18A3D      guibg=NONE      gui=NONE      ctermfg=brown          ctermbg=NONE      cterm=NONE
hi rubyRegexpDelimiter         guifg=#FF8000      guibg=NONE      gui=NONE      ctermfg=brown          ctermbg=NONE      cterm=NONE
hi rubyEscape                  guifg=white        guibg=NONE      gui=NONE      ctermfg=cyan           ctermbg=NONE      cterm=NONE
hi rubyInterpolationDelimiter  guifg=#00A0A0      guibg=NONE      gui=NONE      ctermfg=blue           ctermbg=NONE      cterm=NONE
hi rubyControl                 guifg=#6699CC      guibg=NONE      gui=BOLD      ctermfg=blue           ctermbg=NONE      cterm=BOLD  "and break, etc
"hi rubyGlobalVariable          guifg=#FFCCFF      guibg=NONE      gui=NONE      ctermfg=lightblue      ctermbg=NONE      cterm=NONE  "yield
hi rubyStringDelimiter         guifg=#4a934a      guibg=NONE      gui=NONE      ctermfg=lightgreen     ctermbg=NONE      cterm=NONE
"rubyInclude
"rubySharpBang
"rubyAccess
"rubyPredefinedVariable
"rubyBoolean
"rubyClassVariable
"rubyBeginEnd
"rubyRepeatModifier
"hi link rubyArrayDelimiter    Special  " [ , , ]
"rubyCurlyBlock  { , , }

hi link rubyClass             Keyword
hi link rubyModule            Keyword
hi link rubyKeyword           Keyword
hi link rubyOperator          Operator
hi link rubyIdentifier        Identifier
hi link rubyInstanceVariable  Identifier
hi link rubyGlobalVariable    Identifier
hi link rubyClassVariable     Identifier
hi link rubyConstant          Type


" Special for Java
" hi link javaClassDecl    Type
hi link javaScopeDecl         Identifier
hi link javaCommentTitle      javaDocSeeTag
hi link javaDocTags           javaDocSeeTag
hi link javaDocParam          javaDocSeeTag
hi link javaDocSeeTagParam    javaDocSeeTag

hi javaDocSeeTag              guifg=#CCCCCC     guibg=NONE        gui=NONE      ctermfg=darkgray    ctermbg=NONE        cterm=NONE
hi javaDocSeeTag              guifg=#CCCCCC     guibg=NONE        gui=NONE      ctermfg=darkgray    ctermbg=NONE        cterm=NONE
"hi javaClassDecl              guifg=#CCFFCC     guibg=NONE        gui=NONE      ctermfg=white       ctermbg=NONE        cterm=NONE


" Special for XML
hi link xmlTag          Keyword
hi link xmlTagName      Conditional
hi link xmlEndTag       Identifier


" Special for HTML
hi link htmlTag         Keyword
hi link htmlTagName     Conditional
hi link htmlEndTag      Identifier


" Special for Javascript
hi link javaScriptNumber      Number


" Special for Python
hi pythonDot guibg=NONE
hi pythonBytesEscape ctermfg=71 guifg=#439300


" Special for CSharp
hi  link csXmlTag             Keyword


" Special for PHP

" Markdown
hi htmlH1           guifg=#ffffff     guibg=#208020     gui=italic    ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi htmlH2           guifg=#ffffff     guibg=#383868     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi htmlH3           guifg=#e0e0e0     guibg=#303058     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi htmlH4           guifg=#e0e0e0     guibg=#202040     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi htmlH5           guifg=#e0e0e0     guibg=#181830     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi htmlH6           guifg=#e0e0e0     guibg=#101020     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

" Diff support
hi Special          guifg=#E18964     guibg=NONE        gui=NONE      ctermfg=white       ctermbg=NONE        cterm=NONE

highlight DiffAdd       guifg=NONE    guibg=#0e410e     gui=NONE      ctermfg=white       ctermbg=darkgreen               term=reverse
highlight DiffDelete    guifg=NONE    guibg=#5d1515     gui=NONE      ctermfg=white       ctermbg=red                     term=reverse
highlight DiffChange                  guibg=#002626     gui=NONE      ctermfg=black       ctermbg=cyan                    term=reverse
highlight DiffText                    guibg=#303030     gui=NONE      ctermfg=black       ctermbg=gray                    term=reverse
highlight diffFile      guifg=#c8c800                   gui=NONE      ctermfg=3           ctermbg=black
highlight link diffAdded DiffAdd
highlight link diffRemoved DiffDelete

if &t_Co > 255
    highlight DiffAdd       ctermbg=22      ctermfg=NONE
    highlight DiffDelete    ctermbg=88      ctermfg=NONE
    highlight DiffChange    ctermbg=23      ctermfg=NONE
    highlight DiffText      ctermbg=235     ctermfg=NONE
endif

" ColorColumn
if exists('+colorcolumn')
    if &t_Co > 255 || has("gui_running")
        highlight ColorColumn ctermbg=234 guibg=#1c1c1c
    else
        highlight ColorColumn ctermbg=8
    endif
endif

" Tagbar
hi TagbarSignature  guifg=#7f7f7f     guibg=NONE        gui=NONE      ctermfg=darkgray    ctermbg=NONE        cterm=NONE
hi TagbarHighlight  guifg=white       guibg=#af5f00     gui=NONE      ctermfg=white       ctermbg=130         cterm=NONE

" BufExplorer
hi bufExplorerMapping   guifg=gray      ctermfg=gray
hi bufExplorerHelp      guifg=#6c6c6c   ctermfg=242

" Syntastic
hi SyntasticErrorSign   guifg=white     guibg=#af0000   ctermfg=white   ctermbg=124
hi SyntasticWarningSign guifg=white     guibg=#aaaa00   ctermfg=white   ctermbg=136
hi SyntasticErrorLine   guibg=#3f0000   ctermbg=52
hi SyntasticWarningLine guibg=#2f2f00   ctermbg=58

" Indent guides
hi IndentGuidesOdd  guibg=#141414 ctermbg=233
hi IndentGuidesEven guibg=#212121 ctermbg=235

" Git
hi gitcommitSummary guifg=#96CBFE gui=BOLD ctermfg=lightblue cterm=BOLD

" Subversion
hi link svnDelimiter Comment

" Java
hi javaCommentTitle guifg=#7C7C7C gui=BOLD
hi link javaDocTags javaCommentTitle

" reStructuredText
hi rstEmphasis       guifg=#E18964 guibg=NONE gui=italic ctermfg=210 ctermbg=NONE cterm=NONE
hi rstStrongEmphasis guifg=#E18964 guibg=NONE gui=BOLD   ctermfg=210 ctermbg=NONE cterm=BOLD

" Signature
highlight SignatureMarkText   guifg=#4fff4f guibg=#262626 ctermfg=83  ctermbg=235
highlight SignatureMarkerText guifg=#b4b4ee guibg=#262626 ctermfg=147 ctermbg=235

let g:SignatureMarkerTextHL='"SignatureMarkerText"'
let g:SignatureMarkTextHL='"SignatureMarkText"'
