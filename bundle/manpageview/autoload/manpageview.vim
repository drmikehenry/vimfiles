" manpagevim : extra commands for manual-handling
" Author:	Charles E. Campbell
" Date:		Apr 08, 2013
" Version:	25l	 ASTRO-ONLY
"
" Please read :help manpageview for usage, options, etc
"
" GetLatestVimScripts: 489 1 :AutoInstall: manpageview.vim
"redraw!|call DechoSep()|call inputsave()|call input("Press <cr> to continue")|call inputrestore()
"let mesg= "(ManPageView) C-MBAK#1".s:WinReport() | Dech-WF mesg

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_manpageview")
 finish
endif
let g:loaded_manpageview = "v25l"
if v:version < 702
 echohl WarningMsg
 echo "***warning*** this version of manpageview needs vim 7.2 or later"
 echohl Normal
 finish
endif
let s:keepcpo= &cpo
set cpo&vim
"DechoTabOn

" ---------------------------------------------------------------------
" Set up default manual-window opening option: {{{1
if !exists("g:manpageview_winopen")
 let g:manpageview_winopen= "hsplit"
elseif g:manpageview_winopen == "only" && !has("mksession")
 echomsg "***g:manpageview_winopen<".g:manpageview_winopen."> not supported w/o +mksession"
 let g:manpageview_winopen= "hsplit"
endif

" ---------------------------------------------------------------------
" Sanity Check: {{{1
if !exists("*shellescape")
 fun! manpageview#ManPageView(bknum,...) range
   echohl ERROR
   echo "You need to upgrade your vim to v7.1 or later (manpageview uses the shellescape() function)"
 endfun
 finish
endif

" ---------------------------------------------------------------------
" Default Variable Values: {{{1
"DechoWF "Set up default variable values:"
if has("unix") || has("win32unix")
 let s:nostderr= " 2>/dev/null"
else
 let s:nostderr= ""
endif
if !exists("g:manpageview_iconv")
 if executable("iconv")
  let s:iconv= "iconv -c"
 else
  let s:iconv= ""
 endif
else
 let s:iconv= g:manpageview_iconv
endif
if s:iconv != ""
 let s:iconv= s:nostderr."| ".s:iconv
endif
if !exists("g:manpageview_pgm") && executable("man")
 let g:manpageview_pgm= "man"
endif
if !exists("g:manpageview_multimanpage")
 let g:manpageview_multimanpage= 1
endif
if !exists("g:manpageview_options")
 let g:manpageview_options= ""
endif
if !exists("g:manpageview_pgm_i") && executable("info")
" DechoWF "installed info help support via manpageview"
 let g:manpageview_pgm_i     = "info"
 let g:manpageview_options_i = "--output=-"
 let g:manpageview_syntax_i  = "info"
 let g:manpageview_K_i       = "<sid>MPVInfo(0)"
 let g:manpageview_init_i    = "call MPVInfoInit()"

 let s:linkpat1 = '\*[Nn]ote \([^():]*\)\(::\|$\)' " note
 let s:linkpat2 = '^\* [^:]*: \(([^)]*)\)'         " filename
 let s:linkpat3 = '^\* \([^:]*\)::'                " menu
 let s:linkpat4 = '^\* [^:]*:\s*\([^.]*\)\.$'      " index
endif
if !exists("g:manpageview_pgm_pl") && executable("perldoc")
" DechoWF "installed perl help support via manpageview"
 let g:manpageview_pgm_pl     = "perldoc"
 let g:manpageview_options_pl = "-f"
endif
if !exists("g:manpageview_pgm_pm") && executable("perldoc")
" DechoWF "installed perl help support via manpageview"
 let g:manpageview_pgm_pm     = "perldoc"
 let g:manpageview_options_pm = "-f"
endif
if !exists("g:manpageview_php_url")
 let g:manpageview_php_url     = "http://www.php.net/"
endif
if !exists("g:manpageview_pgm_php") && (executable("links") || executable("elinks"))
"  DechoWF "installed php help support via manpageview"
 let g:manpageview_pgm_php     = (executable("links")? "links" : "elinks")." -dump ".g:manpageview_php_url
 let g:manpageview_syntax_php  = "manphp"
 let g:manpageview_nospace_php = 1
 let g:manpageview_K_php       = "manpageview#ManPagePhp()"
endif
if !exists("g:manpageview_gl_url")
 let g:manpageview_gl_url= "http://www.opengl.org/sdk/docs/man/xhtml/"
endif
if !exists("g:manpageview_pgm_gl") && (executable("links") || executable("elinks"))
 let g:manpageview_pgm_gl     = (executable("links")? "links" : "elinks")." -dump ".g:manpageview_gl_url
 let g:manpageview_syntax_gl  = "mangl"
 let g:manpageview_nospace_gl = 1
 let g:manpageview_K_gl       = "manpageview#ManPagePhp()"
 let g:manpageview_sfx_gl     = ".xml"
endif
if !exists("g:manpageview_pgm_py") && executable("pydoc")
" DechoWF "installed python help support via manpageview"
 let g:manpageview_pgm_py     = "pydoc"
 let g:manpageview_K_py       = "manpageview#ManPagePython()"
endif
if exists("g:manpageview_hypertext_tex") && !exists("g:manpageview_pgm_tex") && (executable("links") || executable("elinks"))
" DechoWF "installed tex help support via manpageview"
 let g:manpageview_pgm_tex    = (executable("links")? "links" : "elinks")." ".g:manpageview_hypertext_tex
 let g:manpageview_lookup_tex = "manpageview#ManPageTexLookup"
 let g:manpageview_K_tex      = "manpageview#ManPageTex()"
endif
if has("win32") && !exists("g:manpageview_rsh")
" DechoWF "installed rsh help support via manpageview"
 let g:manpageview_rsh= "rsh"
endif
if !exists("g:manpageview_K_http")
 if executable("lynx")
  let g:manpageview_K_http     = "lynx -dump"
 elseif executable("links")
  let g:manpageview_K_http     = "links -dump"
 elseif executable("elinks")
  let g:manpageview_K_http     = "elinks -dump"
 elseif executable("wget")
  let g:manpageview_K_http     = "wget -O -"
 elseif executable("curl")
  let g:manpageview_K_http     = "curl"
 endif
endif

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" manpageview#ManPageView: view a manual-page, accepts three formats: {{{2
"    :call manpageview#ManPageView("topic")
"    :call manpageview#ManPageView(booknumber,"topic")
"    :call manpageview#ManPageView("topic(booknumber)")
"
"    bknum   : the book number of the manpage (default=0)
"
"    Returns  0 : usually, except when
"            -1 : manpage does not exist
fun! manpageview#ManPageView(...) range
"  call Dfunc("manpageview#ManPageView(...) a:0=".a:0. " version=".g:loaded_manpageview)
"  DechoWF "(ManPageView) a:1<".((a:0 >= 1)? a:1 : 'n/a').">"
"  DechoWF "(ManPageView) a:2<".((a:0 >= 2)? a:2 : 'n/a').">"
"  DechoWF "(ManPageView) a:3<".((a:0 >= 3)? a:3 : 'n/a').">"
  set lz
  let manpageview_fname = expand("%")
  call s:MPVSaveSettings()

  " ---------------------------------------------------------------------
  " parse arguments for topic and booknumber {{{3
  "   merge quoted arguments :  ie.  handle  :Man "some topic here"
"  DechoWF "(ManPageView) parse input arguments for topic and booknumber"
  let i= 1
  while i <= a:0
   if a:{i} =~ '^"' 
	" start extracting quoted argument(s)
	let topic= substitute(a:{i},'^"','','')
	if topic =~ '"$'
	 " handling :Man "topic"
	 let topic= substitute(topic,'"$','','')
	else
	 " handling :Man "some topic"
	 let i= i + 1
	 while i <= a:0
	  let topic= topic.a:{i}
	  if a:{i} =~ '"$'
	   let topic= substitute(topic,'"$','','')
	   break
	  endif
"	  DechoWF '(ManPageView) ‣‣a:{i='.i.'}<'.a:{i}.'>: topic<'.(exists("topic")? topic : 'n/a').'> bknum<'.(exists("bknum")? bknum : 'n/a').">"
	  let i= i + 1
	 endwhile
	endif

   elseif type(a:{i}) == 0 " Number
	let bknum= string(a:{i})

   elseif a:{i} =~ '^\d\+'   " Handling booknumbers that start with digit(s) (ie. 3p)
	let bknum= a:{i}

   elseif a:{i} =~ '('
	" Handling :Man topic(book)
	let bknum= substitute(a:{i},'^.*(\(.\{-}\)).*$','\1','')
	let topic= substitute(a:{i},"(.*$","","")

   elseif a:{i} == "-k"
    let dokeysrch= 1

   else
    " Handling :call manpageview#ManPageView("topic")
	let topic= a:{i}
   endif
"   DechoWF '(ManPageView) ‣a:{i='.i.'}<'.a:{i}.'>: topic<'.(exists("topic")? topic : 'n/a').'> bknum#'.(exists("bknum")? bknum : 'n/a')
   let i= i + 1
  endwhile

  " sanity check
  if !exists("topic") || topic == ""
   echohl WarningMsg
   echo "***warning*** missing topic"
   echohl None
   sleep 2
"   call Dret("manpageview#ManPageView 0 : missing topic")
   return 0
  endif

  " default book number
  if !exists("bknum")
   let bknum= 0
  endif
"  DechoWF "(ManPageView) after parsing: topic<".topic."> bknum#".bknum

  " ---------------------------------------------------------------------
  " for the benefit of associated routines (such as InfoIndexLink()) {{{3
  let s:manpagetopic = topic
  let s:manpagebook  = bknum

  " ---------------------------------------------------------------------
  " default program g:manpageview_pgm=="man" may be overridden {{{3
  " if an extension is matched
  if exists("g:manpageview_pgm")
   let pgm = g:manpageview_pgm
  else
   let pgm = ""
  endif
  let ext = ""
  if topic =~ '\.'
   let ext = substitute(topic,'^.*\.','','e')
  endif
  if exists("g:manpageview_pgm_gl") && topic =~ '^gl'
   let ext = "gl"
  endif

  " ---------------------------------------------------------------------
  " infer the appropriate extension based on the filetype {{{3
  if ext == ""
"   DechoWF "(ManPageView) attempt to infer on filetype<".&ft.">"

   " filetype: vim
   if &ft == "vim"
"	DechoWF "(ManPageView) special vim handler"
	let retval= manpageview#ManPageVim(topic)
"	call Dret("manpageview#ManPageView ".retval)
	return retval

   " filetype: perl
   elseif &ft == "perl" || &ft == "perldoc"
"	DechoWF "(ManPageView) special perl handler"
   	let ext = "pl"

   " filetype:  php
   elseif &ft == "php" || &ft == "manphp"
"	DechoWF "(ManPageView) special php handler"
   	let ext = "php"

	" filetype:  python
   elseif &ft == "python" || &ft == "pydoc"
"	DechoWF "(ManPageView) special python handler"
   	let ext = "py"

   " filetype: info
   elseif &ft == "info"
"	DechoWF "(ManPageView) special info handler"
	let ext= "i"

   " filetype: tex
   elseif &ft == "tex"
"	DechoWF "(ManPageView) special tex handler"
    let ext= "tex"
    let retval= manpageview#ManPageTexLookup(0,topic)
"    call Dret("manpageview#ManPageView ".retval)
    return retval
   endif

  elseif ext == "vim"
"   DechoWF "(ManPageView) special vim handler"
   let retval= manpageview#ManPageVim(substitute(topic,'\.vim$','',''))
"   call Dret("manpageview#ManPageView ".retval)
   return retval

  elseif ext == "tex"
   let retval= manpageview#ManPageTexLookup(0,substitute(topic,'\.tex$',"",""))
"   call Dret("manpageview#ManPageView ".retval)
   return retval
  endif
"  DechoWF "(ManPageView) ext<".ext.">"

  " ---------------------------------------------------------------------
  " elide extension from topic {{{3
  if exists("g:manpageview_pgm_{ext}") || ext == "."
   let pgm   = g:manpageview_pgm_{ext}
   let topic = substitute(topic,'.'.ext.'$','','')
  elseif topic =~ '\.man$'
   let ext   = 'man'
  endif
  let nospace= exists("g:manpageview_nospace_{ext}")? g:manpageview_nospace_{ext} : 0
"  DechoWF "(ManPageView) pgm<".pgm."> topic<".topic."> bknum#".bknum."  (after elision of extension)"

  " ---------------------------------------------------------------------
  " special extension-based exceptions: {{{3
  if ext == 'man'
   " for man: allow ".man" extension to mean we want regular manpages even while in a supported filetype
   let pgm   = ext
   let topic = substitute(topic,'\.'.ext.'$','','')
   let ext   = ""
   if bknum == 0
	let bknum = ""
	let mpb   = ""
   endif
"   DechoWF "(ManPageView) special exception for .man: pgm<".pgm."> topic<".topic."> ext<".ext.">"

  elseif ext == "i"
  " special exception for info
   if exists("s:manpageview_pfx_i")
    unlet s:manpageview_pfx_i
   endif
   let bknum = ""
"   DechoWF "(ManPageView) special exception for .i: pgm<".(exists("pgm")? pgm : 'n/a')."> topic<".(exists("topic")? topic : 'n/a')."> ext<".(exists("ext")? ext : 'n/a').">"
   if topic == "Top"
	let g:mpvcmd = ""
   endif

  elseif bknum == 0
   let bknum = ""
  endif
"  DechoWF "(ManPageView) topic<".topic."> bknum#".bknum

  if exists("s:manpageview_pfx_{ext}") && s:manpageview_pfx_{ext} != ""
   let topic= s:manpageview_pfx_{ext}.topic
"   DechoWF "(ManPageView) modified topic<".topic."> #1"
  elseif exists("g:manpageview_pfx_{ext}") && g:manpageview_pfx_{ext} != ""
   " prepend any extension-specified prefix to topic
   let topic= g:manpageview_pfx_{ext}.topic
"   DechoWF "(ManPageView) modified topic<".topic."> #2"
  endif

  if exists("g:manpageview_sfx_{ext}") && g:manpageview_sfx_{ext} != ""
   " append any extension-specified suffix to topic
   let topic= topic.g:manpageview_sfx_{ext}
"   DechoWF "(ManPageView) modified topic<".topic."> #3"
  endif

  if exists("g:manpageview_K_{ext}") && g:manpageview_K_{ext} != ""
   " override usual K map
"   DechoWF "(ManPageView) change K map to call ".g:manpageview_K_{ext}
   exe "nmap <silent> K :\<c-u>call ".g:manpageview_K_{ext}."\<cr>"
  endif

  if exists("g:manpageview_syntax_{ext}") && g:manpageview_syntax_{ext} != ""
   " allow special-suffix extensions to optionally control syntax highlighting
   let manpageview_syntax= g:manpageview_syntax_{ext}
  else
   let manpageview_syntax= "man"
  endif
"  DechoWF "(ManPageView) manpageview_syntax<".manpageview_syntax."> topic<".topic."> bknum#".bknum

  " ---------------------------------------------------------------------
  " support for searching for options from conf pages {{{3
  if bknum == "" && manpageview_fname =~ '\.conf$'
   let manpagesrch = '^\s\+'.topic
   let topic       = manpageview_fname
  endif
"  DechoWF "(ManPageView) topic<".topic."> bknum#".bknum

  " ---------------------------------------------------------------------
  " it was reported to me that some systems change display sizes when a {{{3
  " filtering command is used such as :r! .  I record the height&width
  " here and restore it afterwards.  To make use of it, put
  "   let g:manpageview_dispresize= 1
  " into your <.vimrc>
  let dwidth  = &cwh
  let dheight = &co
"  DechoWF "(ManPageView) dwidth=".dwidth." dheight=".dheight

  " ---------------------------------------------------------------------
  " Set up the window for the manpage display (only hsplit split etc) {{{3
"  DechoWF "(ManPageView) set up window for manpage display (g:manpageview_winopen<".g:manpageview_winopen."> ft<".&ft."> manpageview_syntax<".manpageview_syntax.">)"
"  DechoWF "(ManPageView) winnr($)=".winnr("$")." ft=".&ft
  if     g:manpageview_winopen == "only"
   " OMan
   sil! noautocmd windo w
   if !exists("g:ManCurPosn") && has("mksession")
    call s:MPVSavePosn()
   endif
   " Record current file/position/screen-position
   if &ft != manpageview_syntax
    sil! only!
"	let mesg= "(ManPageView) [only]".s:WinReport() | DechoWF mesg
   endif
   sil! enew!

  elseif g:manpageview_winopen == "hsplit"
   " HMan
   if &ft != manpageview_syntax
    wincmd s
	sil! enew!
    wincmd _
    3wincmd -
   else
	sil! enew!
   endif
"   let mesg= "(ManPageView) [hsplit]".s:WinReport() | DechoWF mesg

  elseif g:manpageview_winopen == "hsplit="
   " HEMan
   if &ft != manpageview_syntax
    wincmd s
   endif
   sil! enew!
"   let mesg= "(ManPageView) [hsplit=]".s:WinReport() | DechoWF mesg

  elseif g:manpageview_winopen == "vsplit"
   " VMan
   if &ft != manpageview_syntax
    wincmd v
	sil! enew!
    wincmd |
    20wincmd <
   else
	sil! enew!
   endif
"   let mesg= "(ManPageView) [vsplit]".s:WinReport() | DechoWF mesg

  elseif g:manpageview_winopen == "vsplit="
   " VEMan
   if &ft != "man"
    wincmd v
   endif
   enew!
"   let mesg="(ManPageView) [vsplit=]".s:WinReport() | DechoWF mesg

  elseif g:manpageview_winopen == "tab"
   " TMan
   if &ft != "man"
    tabnew
   endif
"   let mesg= "(ManPageView) [tab]".s:WinReport() | DechoWF mesg

  elseif g:manpageview_winopen == "reuse"
   " RMan
   " determine if a Manpageview window already exists
   if exists("s:booksearching")
	let g:manpageview_manwin= s:booksearching
   else
    let g:manpageview_manwin= -1
    exe "noautocmd windo if &ft == '".fnameescape(manpageview_syntax)."'|let g:manpageview_manwin= winnr()|endif"
   endif
   if g:manpageview_manwin != -1
    " found a pre-existing Manpageview window, re-using it
"	DechoWF "(ManPageView) found pre-existing manpageview window (win#".g:manpageview_manwin."), re-using it"
    exe g:manpageview_manwin."wincmd w"
	sil! enew!
"	DechoWF "(ManPageView) re-using win#".g:manpageview_manwin." (note that win($)=".winnr("$").")"
   elseif &l:mod == 1
    " file has been modified, would be lost if we re-used window.  Use hsplit instead.
"    DechoWF "file<".expand("%")."> has been modified, would be lost if re-used.  Using hsplit instead"
    wincmd s
	sil! enew!
    wincmd _
    3wincmd -
   elseif &ft != manpageview_syntax
    " re-using current window (but hiding it first)
"    DechoWF "re-using current window#".winnr()." (hiding it first)"
    setlocal bh=hide
	sil! enew!
   else
	sil! enew!
   endif
"   let mesg= "(ManPageView) [reuse]".s:WinReport() | DechoWF mesg

  else
   echohl ErrorMsg
   echo "***sorry*** g:manpageview_winopen<".g:manpageview_winopen."> not supported"
   echohl None
   sleep 2
   call s:MPVRestoreSettings()
"   call Dret("manpageview#ManPageView 0 : manpageview_winopen<".g:manpageview_winopen."> not supported")
   return 0
  endif

  " ---------------------------------------------------------------------
  " let manpages format themselves to specified window width {{{3
  " this setting probably only affects the linux "man" command.
  if exists("$MANWIDTH")
   let $MANWIDTH = winwidth(0)
  endif

  " ---------------------------------------------------------------------
  " add some maps for multiple manpage handling {{{3
  " (some manpages on some systems have multiple NAME... topics provided on a single manpage)
  " The code here has PageUp/Down typically do a ctrl-f, ctrl-b; however, if there are multiple
  " topics on the manpage, then PageUp/Down will go to the previous/succeeding topic, instead.
  if g:manpageview_multimanpage
   let swp       = SaveWinPosn(0)
   let nameline1 = search("^NAME$",'Ww')
   let nameline2 = search("^NAME$",'Ww')
   sil! call RestoreWinPosn(swp)
   if nameline1 != nameline2 && nameline1 >= 1 && nameline2 >= 1
"	DechoWF "(ManPageView) multimanpage: mapping PageUp/Down to go to preceding/succeeding topic"
	nno <silent> <script> <buffer> <PageUp>			:call search("^NAME$",'bW')<cr>z<cr>5<c-y>
	nno <silent> <script> <buffer> <PageDown>		:call search("^NAME$",'W')<cr>z<cr>5<c-y>
   else
"	DechoWF "(ManPageView) multimanpage: mapping PageUp/Down to go to ctrl-f, ctrl-b"
    nno <silent> <script> <buffer> <PageDown>	<c-f>
	nno <silent> <script> <buffer> <PageUp>		<c-b>
   endif
  else
"   DechoWF "(ManPageView) not-multimanpage: mapping PageUp/Down to do ctrl-f, ctrl-b"
   nno <silent> <script> <buffer> <PageDown>	<c-f>
   nno <silent> <script> <buffer> <PageUp>		<c-b>
  endif

  " ---------------------------------------------------------------------
  " allow K to use <cWORD> when in man pages {{{3
  if manpageview_syntax == "man"
   nmap <silent> <script> <buffer>	K   :<c-u>call manpageview#KMap(1)<cr>
  endif

  " ---------------------------------------------------------------------
  " allow user to specify file encoding {{{3
  if exists("g:manpageview_fenc")
   exe "setlocal fenc=".fnameescape(g:manpageview_fenc)
  endif

  " ---------------------------------------------------------------------
  " when this buffer is exited it will be wiped out {{{3
  if v:version >= 602
   setlocal bh=wipe
  endif
  let b:did_ftplugin= 2
  let $COLUMNS=winwidth(0)

  " ---------------------------------------------------------------------
  " special manpageview buffer maps {{{3
  nnoremap <silent> <buffer> <space>     <c-f>
  nnoremap <silent> <buffer> <c-]>       :call manpageview#ManPageView(v:count1,expand("<cWORD>"))<cr>

  " -----------------------------------------
  " Invoke the man command to get the manpage {{{3
  " -----------------------------------------

  " the buffer must be modifiable for the manpage to be loaded via :r! {{{4
  setlocal ma

  let cmdmod= ""
  if v:version >= 603
   let cmdmod= "sil! keepj "
"   call Decho("(ManPageView) setting cmdmod<".cmdmod.">")
  endif

  " ---------------------------------------------------------------------
  " extension-based initialization (expected: buffer-specific maps) {{{4
  if exists("g:manpageview_init_{ext}")
   if !exists("b:manpageview_init_{ext}")
"	DechoWF "(ManPageView) exe manpageview_init_".ext."<".g:manpageview_init_{ext}.">"
	exe g:manpageview_init_{ext}
	let b:manpageview_init_{ext}= 1
   endif
  elseif ext == ""
"   DechoWF "(ManPageView) change K map to support empty extension"
   sil! unmap K
"   DechoWF "(ManPageView) nmap <silent> <unique> K manpageview#KMap(0)"
   nmap <silent> <unique> K :<c-u>call manpageview#KMap(0)<cr>
  endif

  " ---------------------------------------------------------------------
  " default program g:manpageview_options (empty string) may be overridden {{{4
  " if an extension is matched
  let opt= g:manpageview_options
  if exists("g:manpageview_options_{ext}")
   let opt= g:manpageview_options_{ext}
  endif

  let cnt= 0
  while cnt < 3 && (strlen(opt) > 0 || cnt == 0)
"   DechoWF "(ManPageView) ‣while [cnt=".cnt."]<3 AND (strlen(opt<".opt.">) > 0 || cnt==0)"
   let cnt   = cnt + 1
   let iopt  = substitute(opt,';.*$','','e')
   let opt   = substitute(opt,'^.\{-};\(.*\)$','\1','e')
"   DechoWF "(ManPageView) ‣cnt=".cnt." iopt<".iopt."> opt<".opt."> s:iconv<".(exists("s:iconv")? s:iconv : "").">"
   if exists("dokeysrch")
	let iopt= iopt." -k"
   endif

  " ---------------------------------------------------------------------
   " use pgm to read/find/etc the manpage (but only if pgm is not the empty string)
   " by default, pgm is "man"
   if pgm != ""

	" ---------------------------
	" use manpage_lookup function {{{4
	" ---------------------------
   	if exists("g:manpageview_lookup_{ext}")
"	 DechoWF "(ManPageView) ‣lookup: exe call ".g:manpageview_lookup_{ext}."('".bknum."','".topic."')"
"	 DechoWF "(ManPageView) ‣lookup: g:manpageview_lookup_".ext."<".g:manpageview_lookup_{ext}.">"
"	 DechoWF "(ManPageView) ‣lookup: bknum<".bknum.">"
"	 DechoWF "(ManPageView) ‣lookup: topic<".topic.">"
	 exe "call ".g:manpageview_lookup_{ext}."('".bknum."','".topic."')"

    elseif has("win32") && exists("g:manpageview_server") && exists("g:manpageview_user")
"	 DechoWF "(ManPageView) ‣win32: bknum<".bknum."> topic<".topic.">"
     exe cmdmod."r!".g:manpageview_rsh." ".g:manpageview_server." -l ".g:manpageview_user." ".pgm." ".iopt." ".shellescape(bknum,1)." ".shellescape(topic,1)
     exe cmdmod.'sil!  %s/.\b//ge'

	"--------------------------
	" use pgm to obtain manpage {{{4
	"--------------------------
    else
	 if bknum != ""
	  let mpb= shellescape(bknum,1)
	 else
	  let mpb= ""
	 endif
"	 DechoWF "(ManPageView) ‣pgm    <".(exists("pgm")?     pgm     : 'n/a').">"
"	 DechoWF "(ManPageView) ‣iopt   <".(exists("iopt")?    iopt    : 'n/a').">"
"	 DechoWF "(ManPageView) ‣mpb    <".(exists("mpb")?     mpb     : 'n/a').">"
"	 DechoWF "(ManPageView) ‣topic  <".(exists("topic")?   topic   : 'n/a').">"
"	 DechoWF "(ManPageView) ‣s:iconv<".(exists("s:iconv")? s:iconv : 'n/a').">"
"	 call Decho('(ManPageView) ‣s:nostderr="'.s:nostderr.'"')
	 if exists("g:mpvcmd")
"	  DechoWF "(ManPageView) ‣mpvcmd: exe ".cmdmod."r!".pgm." ".iopt." ".mpb." ".g:mpvcmd.s:nostderr
      exe cmdmod."r!".pgm." ".iopt." ".mpb." ".g:mpvcmd.s:nostderr
	  unlet g:mpvcmd
	 elseif nospace
"	  DechoWF "(ManPageView) ‣nospace=".nospace.":  exe sil! ".cmdmod."r!".pgm.iopt.mpb.topic.(exists("s:iconv")? s:iconv : "").s:nostderr
	  exe cmdmod."r!".pgm.iopt.mpb.shellescape(topic,1).(exists("s:iconv")? s:iconv : "").s:nostderr
     elseif has("win32")
"	  DechoWF "(ManPageView) ‣win32: exe ".cmdmod."r!".pgm." ".iopt." ".mpb." \"".topic."\" ".(exists("s:iconv")? s:iconv : "").s:nostderr
	  exe cmdmod."r!".pgm." ".iopt." ".mpb." ".shellescape(topic,1).(exists("s:iconv")? " ".s:iconv : "").s:nostderr
	 else
"	  call Decho("(ManPageView) ‣normal: exe ".cmdmod."r!".pgm." ".iopt." ".mpb." '".topic."' ".(exists("s:iconv")? s:iconv : "").s:nostderr)
	  exe cmdmod."r!".pgm." ".iopt." ".mpb." ".shellescape(topic,1).(exists("s:iconv")? " ".s:iconv : "").s:nostderr
	endif
     exe cmdmod.'sil!  %s/.\b//ge'
    endif
	setlocal ro nomod noswf
   endif

  " ---------------------------------------------------------------------
   " check if manpage actually found {{{3
   if line("$") != 1 || col("$") != 1
"	DechoWF "(ManPageView) ‣manpage found"
    break
   endif
"   DechoWF "(ManPageView) ‣cnt=".cnt.": manpage not found"
   if cnt == 3 && !exists("g:manpageview_iconv") && s:iconv != ""
	let s:iconv= ""
"	DechoWF "(ManPageView) ‣trying with no iconv"
   elseif cnt == 1
	break
   endif
  endwhile

  " ---------------------------------------------------------------------
  " here comes the vim display size restoration {{{3
  if exists("g:manpageview_dispresize")
   if g:manpageview_dispresize == 1
"	DechoWF "(ManPageView) restore display size to ".dheight."x".dwidth
    exe "let &co=".dwidth
    exe "let &cwh=".dheight
   endif
  endif

  " ---------------------------------------------------------------------
  " clean up (ie. remove) any ansi escape sequences {{{3
  if line("$") != 1 || col("$") != 1
"   DechoWF "(ManPageView) remove any ansi escape sequences"
   sil! %s/\e\[[0-9;]\{-}m//ge
   sil! %s/\%xe2\%x80\%x90/-/ge
   sil! %s/\%xe2\%x88\%x92/-/ge
   sil! %s/\%xe2\%x80\%x99/'/ge
   sil! %s/\%xe2\%x94\%x82/ /ge

  " ---------------------------------------------------------------------
  " set up options and put cursor at top-left of manpage {{{3
"  DechoWF "(ManPageView) set up options and put cursor at top-left of manpage"
   if bknum == "-k"
    setlocal ft=mankey
   else
    exe cmdmod."setlocal ft=".fnameescape(manpageview_syntax)
   endif
   exe cmdmod."setlocal ro"
   exe cmdmod."setlocal noma"
   exe cmdmod."setlocal nomod"
   exe cmdmod."setlocal nolist"
   exe cmdmod."setlocal nonu"
   exe cmdmod."setlocal fdc=0"
"   exe cmdmod."setlocal isk+=-,.,(,)"
   exe cmdmod."setlocal nowrap"
   set nolz
   exe cmdmod."1"
   exe cmdmod."norm! 0"
  endif

  " ---------------------------------------------------------------------
  "  check if help was not found  {{{3
  if line("$") == 1 && col("$") == 1
"   DechoWF "(ManPageView) no help found: ft=".&ft." manpageview_syntax<".(exists("manpageview_syntax")? manpageview_syntax : 'n/a').">"

   if &ft == manpageview_syntax
	if exists("s:manpageview_curtopic")
"	 DechoWF "(ManPageView) no help found: s:manpageview_curtopic<".s:manpageview_curtopic.">"
	 call manpageview#ManPageView(v:count,s:manpageview_curtopic)
	endif
   elseif winnr("$") > 1 && !exists("s:booksearching")
"    DechoWF "(ManPageView) no help found, quitting help window"
    sil! q!
   endif

"   DechoWF "(ManPageView) save winposn"
   call SaveWinPosn()
"   DechoWF "***warning*** no manpage exists for <".topic."> book<".bknum.">"
   if !exists("s:mpv_booksearch")
    echohl ErrorMsg
    echo "***warning*** sorry, no manpage exists for <".topic.">"
    echohl None
    sleep 2
   endif
"   DechoWF "(ManPageView) winnr($)=".winnr("$")." ft=".&ft

   if exists("s:mpv_before_k_posn")
"	DechoWF "(ManPageView) restoring winposn"
	sil! call RestoreWinPosn(s:mpv_before_k_posn)
	unlet s:mpv_before_k_posn
   endif

   " attempt to recover from a no-manpage-found condition
   if exists("s:onerr_bknum")
	call manpageview#ManPageView(s:onerr_bknum,s:onerr_topic)
	call RestoreWinPosn(s:onerr_winpos)
	unlet s:onerr_bknum s:onerr_topic s:onerr_winpos
   endif

"   DechoWF "(ManPageView) restoring settings"
   call s:MPVRestoreSettings()
"   call Dret("manpageview#ManPageView -1 : no manpage exists for <".topic.">")
   return -1

  elseif bknum == ""
"   DechoWF '(ManPageView) exe file '.fnameescape('Manpageview['.topic.']')
   exe 'sil! file '.fnameescape('Manpageview['.topic.']')
   let s:manpageview_curtopic= topic

  else
"   DechoWF '(ManPageView) exe file '.fnameescape('Manpageview['.topic.'('.fnameescape(bknum).')]')
   exe 'sil! file '.fnameescape('Manpageview['.topic.'('.fnameescape(bknum).')]')
   let s:manpageview_curtopic= topic."(".bknum.")"
  endif

  " ---------------------------------------------------------------------
  " Enter booknumber and topic into history
  if !exists("s:history") || s:ihist == len(s:history)-1
"   DechoWF "(ManPageView) Saving history: bknum#".bknum." topic<".topic.">"
   call manpageview#History(0,bknum,topic)
  endif

  " ---------------------------------------------------------------------
  " Install search book maps
  nno <silent> <buffer> <s-left>	:call manpageview#BookSearch(-v:count1)<cr>
  nno <silent> <buffer> <s-right>	:call manpageview#BookSearch( v:count1)<cr>

  " ---------------------------------------------------------------------
  " if there's a search pattern, use it {{{3
  if exists("manpagesrch")
   if search(manpagesrch,'w') != 0
    exe "norm! z\<cr>"
   endif
  endif

  " ---------------------------------------------------------------------
  " restore settings {{{3
  call s:MPVRestoreSettings()
"  call Dret("manpageview#ManPageView 0")
  return 0
endfun

" ---------------------------------------------------------------------
" manpageview#KMap: handles the K map {{{2
fun! manpageview#KMap(usecWORD)
"  call Dfunc("manpageview#KMap(usecWORD=".a:usecWORD.")")
  if a:usecWORD =~ '^http:'
   if exists("g:manpageview_K_http")
	let url= substitute(a:usecWORD,")$","","")
"	call Decho("url<".url.">")
    tabnew
	exec 'sil! r! '.g:manpageview_K_http." ".fnameescape(url)
	exe "file ".fnameescape(url)
	setl nomod noma
   else
    echohl WarningMsg
	echo "***warning*** (manpageview#KMap) needs one of (lynx|links|elinks|wget|curl) to handle urls"
	echohl None
   endif
  elseif &ft == "info"
   if getline(".") =~ '^\s*\*\s*.*::'
    call s:MPVInfo(5)
   else
	call manpageview#ManPageView(0,expand("<cword>"))
   endif
  else
   let book= v:count
   if book == 0
	if getline(".") =~ '\<'.expand("<cword>").'\s\+(\d\+)'
	 let book= substitute(getline("."),'\<'.expand("<cword>").'\s\+(\(\d\+\)).*$','\1','') + 0
	else
     let book= "0"
	endif
   elseif book > 0
    let book= string(book)
   else
    let book= ""
   endif
   if a:usecWORD
    let topic               = expand("<cWORD>")
   else
    let topic               = expand("<cword>")
   endif
   let s:mpv_before_k_posn = SaveWinPosn(0)
"   DechoWF "(KMap) book#".(exists("book")? book : 'n/a')."  topic<".(exists("topic")? topic : 'n/a').">"
   call manpageview#ManPageView(book,topic)
  endif
"  call Dret("manpageview#KMap")
endfun

" ---------------------------------------------------------------------
" s:MPVSavePosn: saves current file, line, column, and screen position {{{2
fun! s:MPVSavePosn()
"  call Dfunc("s:MPVSavePosn()")

  let g:ManCurPosn= tempname()
  let keep_ssop   = &ssop
  let &ssop       = 'winpos,buffers,slash,globals,resize,blank,folds,help,options,winsize'
  if v:version >= 603
   exe 'keepj sil! mksession! '.fnameescape(g:ManCurPosn)
  else
   exe 'sil! mksession! '.fnameescape(g:ManCurPosn)
  endif
  let &ssop       = keep_ssop
  cnoremap <silent> q call <SID>MPVRestorePosn()<CR>

"  call Dret("s:MPVSavePosn")
endfun

" ---------------------------------------------------------------------
" s:MPVRestorePosn: restores file/position/screen-position {{{2
"                 (uses g:ManCurPosn)
fun! s:MPVRestorePosn()
"  call Dfunc("s:MPVRestorePosn()")

  if exists("g:ManCurPosn")
"   DechoWF "g:ManCurPosn<".g:ManCurPosn.">"
   if v:version >= 603
	exe 'keepj sil! source '.fnameescape(g:ManCurPosn)
   else
	exe 'sil! source '.fnameescape(g:ManCurPosn)
   endif
   unlet g:ManCurPosn
   sil! cunmap q
  endif

"  call Dret("s:MPVRestorePosn")
endfun

" ---------------------------------------------------------------------
" s:MPVSaveSettings: save and standardize certain user settings {{{2
fun! s:MPVSaveSettings()

  if !exists("s:sxqkeep")
"   call Dfunc("s:MPVSaveSettings()")
   let s:manwidth          = expand("$MANWIDTH")
   let s:sxqkeep           = &sxq
   let s:srrkeep           = &srr
   let s:repkeep           = &report
   let s:gdkeep            = &gd
   let s:cwhkeep           = &cwh
   let s:magickeep         = &l:magic
   setlocal srr=> report=10000 nogd magic
   if &cwh < 2
    " avoid hit-enter prompts
    setlocal cwh=2
   endif
  if has("win32") || has("win95") || has("win64") || has("win16")
   let &sxq= '"'
  else
   let &sxq= ""
  endif

  if $MANWIDTH == ""
   let $MANWIDTH = winwidth(0)
  endif
  let s:curmanwidth = $MANWIDTH
"  call Dret("s:MPVSaveSettings")
 endif
 if &ft == "man" && exists("s:history") && exists("s:ihist")
  let s:onerr_bknum  = s:history[s:ihist][0]
  let s:onerr_topic  = s:history[s:ihist][1]
  let s:onerr_winpos = SaveWinPosn()
 endif

endfun

" ---------------------------------------------------------------------
" s:MPVRestoreSettings: {{{2
fun! s:MPVRestoreSettings()
  if exists("s:sxqkeep")
"   call Dfunc("s:MPVRestoreSettings()")
   let &sxq      = s:sxqkeep     | unlet s:sxqkeep
   let &srr      = s:srrkeep     | unlet s:srrkeep
   let &report   = s:repkeep     | unlet s:repkeep
   let &gd       = s:gdkeep      | unlet s:gdkeep
   let &cwh      = s:cwhkeep     | unlet s:cwhkeep
   let &l:magic  = s:magickeep   | unlet s:magickeep
   let $MANWIDTH = s:curmanwidth | unlet s:curmanwidth
"   call Dret("s:MPVRestoreSettings")
  endif
endfun

" ---------------------------------------------------------------------
" s:MPVInfo: {{{2
fun! s:MPVInfo(type)
"  call Dfunc("s:MPVInfo(type=".a:type.")")
  let s:before_K_posn = SaveWinPosn(0)

  if &ft != "info"
   " restore K and do a manpage lookup for word under cursor
"   DechoWF "ft<".&ft."> ≠ info: restore K and do a manpage lookup of word under cursor"
   setlocal kp=manpageview#ManPageView
   if exists("s:manpageview_pfx_i")
    unlet s:manpageview_pfx_i
   endif
   call manpageview#ManPageView(0,expand("<cWORD>"))
"   call Dret("s:MPVInfo : restored K")
   return
  endif

  if !exists("s:manpageview_pfx_i") && exists("g:manpageview_pfx_i")
   let s:manpageview_pfx_i= g:manpageview_pfx_i
  endif

  " -----------
  " Follow Link
  " -----------
  if a:type == 0
   " extract link
   let curline  = getline(".")
"   DechoWF "type==0: curline<".curline.">"
   let ipat     = 1
   while ipat <= 4
    let link= matchstr(curline,s:linkpat{ipat})
"	DechoWF '..attempting s:linkpat'.ipat.":<".s:linkpat{ipat}.">"
    if link != ""
     if ipat == 2
      let s:manpageview_pfx_i = substitute(link,s:linkpat{ipat},'\1','')
      let node                = "Top"
     else
      let node                = substitute(link,s:linkpat{ipat},'\1','')
 	 endif
"   	 DechoWF "ipat=".ipat."link<".link."> node<".node."> pfx<".s:manpageview_pfx_i.">"
 	 break
    endif
    let ipat= ipat + 1
   endwhile

  " -------------------
  " Go to next node "]"
  " -------------------
  elseif a:type == 1
   let infofile = matchstr(getline(2),'File: \zs[^,]\+\ze,')
   let nxtnode  = matchstr(getline(2),'Next: \zs[^,]\+\ze,')
   let node     = ""
   let g:mpvcmd = ' --node="'.nxtnode.'" -f "'.infofile.'"'
"   DechoWF "type==1: goto next node<".node."> with infofile<".infofile.">"

  " -----------------------
  " Go to previous node "["
  " -----------------------
  elseif a:type == 2
   let infofile = matchstr(getline(2),'File: \zs[^,]\+\ze,')
   let prvnode  = matchstr(getline(2),'Prev: \zs[^,]\+\ze,')
   let node     = ""
   let g:mpvcmd = ' --node="'.prvnode.'" -f "'.infofile.'"'
"   DechoWF "type==2: goto previous node<".node."> with infofile<".infofile.">"

  " --------------
  " Go up node "u"
  " --------------
  elseif a:type == 3
   let infofile = matchstr(getline(2),'File: \zs[^,]\+\ze,')
   let upnode   = matchstr(getline(2),'Up: \zs.\+$')
   let node     = ""
   let g:mpvcmd = ' --node="'.upnode.'" -f "'.infofile.'"'
"   DechoWF "type==3: go up one node<".upnode."> with infofile<".infofile.">"
   if node == "(dir)"
	echo "***sorry*** can't go up from this node"
"    call Dret("s:MPVInfo : can't go up a node")
    return
   endif

  " ------------------
  " Go to top node "t"
  " ------------------
  elseif a:type == 4
"   DechoWF "type==4: go to top node"
   let node= ""

  " -----------------------
  " Select Menu Node "<cr>"
  " -----------------------
  elseif a:type == 5
   let infofile = matchstr(getline(2),'File: \zs[^,\t]\+\ze[,\t]')
   let node     = matchstr(getline(2),'^.*Node: \zs[^,\t]\+\ze[,\t]')
   let selnode  = matchstr(getline("."),'^\s*\*\s*\zs[^:]\+\ze:')
   let infofile2= matchstr(getline("."),'^\s*\*\s*[^:]\+:\s*(\zs[^)]\+\ze)')
   let node2    = matchstr(getline("."),'^\s*\*\s*[^:]\+:\s*([^)]\+)\zs[^.]*\ze\.')
"   DechoWF "type==5:  infofile<".infofile.">"
"   DechoWF "type==5: infofile2<".infofile2.">"
"   DechoWF "type==5:   selnode<".selnode.">"
"   DechoWF "type==5:      node<".node.">"
"   DechoWF "type==5:      node2<".node2.">"
   if infofile2 != "" && node2 != ""
	let infofile= infofile2
"	DechoWF "type==5: infofile <".infofile."> (overridden with infofile2)"
   endif
   if node2 != ""
	let srchpat= selnode
	let selnode= node2
"	DechoWF "type==5: selnode <".selnode."> (overridden with node2)"
   endif
   if line('.') == 2
"    DechoWF "cword<".expand("<cword>").">"
	if     expand("<cword>") == "Next"
	 call s:MPVInfo(1)
"     call Dret("s:MPVInfo")
	 return
	elseif expand("<cword>") == "Prev" 
	 call s:MPVInfo(2)
"     call Dret("s:MPVInfo")
	 return
	elseif expand("<cword>") == "Up" 
	 call s:MPVInfo(3)
"     call Dret("s:MPVInfo")
	 return
	else
	 let marka = SaveMark("a")
	 let markb = SaveMark("b")
	 let keepa = @a
	 norm! mbF:lmaf,"ay`a`b
	 let selnode= @a
	 call RestoreMark("b")
	 call RestoreMark("a")
	 let @a       = keepa
     let g:mpvcmd = ' --node="'.selnode.'" -f "'.infofile.'"'
"	 DechoWF "type==5: selnode<".selnode.">"
	endif
   elseif selnode == "Menu" || selnode == ""
"	call Dret("s:MPVInfo : skip Menu")
    return
   elseif node == "Top" && infofile == "dir"
	let g:mpvcmd = ' -f '.selnode
	let node     = ""
"	DechoWF "type==5: goto selected node<".selnode."> (special: infofile is dir)"
   else
	let node     = ""
    let g:mpvcmd = ' --node="'.selnode.'" -f "'.infofile.'"'
"    DechoWF "type==5: goto selected node<".selnode."> with infofile<".infofile.">"
   endif
"   DechoWF "type==5: g:mpvcmd<".(exists("g:mpvcmd")? g:mpvcmd : 'n/a').">"
  endif
"  DechoWF "node<".(exists("node")? node : '--n/a--').">"

  " use ManPageView() to view selected node
  if !exists("node")
   echohl ErrorMsg
   echo "***sorry*** unable to view selection"
   echohl None
   sleep 2
  else
   call manpageview#ManPageView(0,node.".i")
   if exists("srchpat")
"	DechoWF "applying srchpat<".srchpat.">"
	call search('\<'.srchpat.'\>')
   endif
  endif

"  call Dret("s:MPVInfo")
endfun

" ---------------------------------------------------------------------
" MPVInfoInit: initialize maps for info pages {{{2
fun! MPVInfoInit()
"  call Dfunc("MPVInfoInit()")

  " some mappings to imitate the default info reader
  nmap    <buffer> <silent> K			:<c-u>call manpageview#KMap(0)<cr>
  noremap <buffer> <silent>	]			:call <SID>MPVInfo(1)<cr>
  noremap <buffer> <silent>	n			:call <SID>MPVInfo(1)<cr>
  noremap <buffer> <silent>	[			:call <SID>MPVInfo(2)<cr>
  noremap <buffer> <silent>	p			:call <SID>MPVInfo(2)<cr>
  noremap <buffer> <silent>	u			:call <SID>MPVInfo(3)<cr>
  noremap <buffer> <silent>	t			:call <SID>MPVInfo(4)<cr>
  noremap <buffer> <silent>	<cr>		:call <SID>MPVInfo(5)<CR>
  noremap <buffer> <silent>	<leftmouse>	<leftmouse>:call <SID>MPVInfo(5)<CR>
  noremap <buffer> <silent>	?			:he manpageview-info<cr>
  noremap <buffer> <silent>	d			:call manpageview#ManPageView(0,"dir.i")<cr>
  noremap <buffer> <silent>	H			:help manpageview-info<cr>
  noremap <buffer> <silent>	<Tab>		:call <SID>NextInfoLink()<CR>
  noremap <buffer> <silent>	i			:call <SID>InfoIndexLink('i')<CR>
  noremap <buffer> <silent>	>			:call <SID>InfoIndexLink('>')<CR>
  noremap <buffer> <silent>	<			:call <SID>InfoIndexLink('<')<CR>
  noremap <buffer> <silent>	,			:call <SID>InfoIndexLink('>')<CR>
  noremap <buffer> <silent>	;			:call <SID>InfoIndexLink('<')<CR>
  noremap <buffer> <silent> <F1>		:echo "] goto nxt node   [ goto prv node   d goto toplvl   u go up   i indx srch   > nxt indx srch   < prv indx srch   \<tab\> next hyperlink"<cr> 
"  call Dret("MPVInfoInit")
endfun

" ---------------------------------------------------------------------
" s:NextInfoLink: {{{2
fun! s:NextInfoLink()
    let ln = search('\%('.s:linkpat1.'\|'.s:linkpat2.'\|'.s:linkpat3.'\|'.s:linkpat4.'\)', 'w')
    if ln == 0
		echohl ErrorMsg
	   	echo '***sorry*** no links found' 
	   	echohl None
		sleep 2
    endif
endfun

" ---------------------------------------------------------------------
" s:InfoIndexLink: supports info's  i  for index-search-for-topic {{{2
"                                 > ,  for next occurrence of index searched topic
"                                 < ;  for prev occurrence of index searched topic
fun! s:InfoIndexLink(cmd)
"  call Dfunc("s:InfoIndexLink(cmd<".a:cmd.">)")

  if a:cmd == 'i'
   call inputsave()
   let g:mpv_infolink= input("Index entry: ","","shellcmd")
   call inputrestore()
"   DechoWF "(InfoIndexLink) g:mpv_infolink<".g:mpv_infolink.">"
   call manpageview#ManPageView(0,g:mpv_infolink.".i")
   call search('\<'.g:mpv_infolink.'\>','W')
"   call Dret("s:InfoIndexLink")
   return

  elseif a:cmd == '>'
   let g:mpv_infolink= matchstr(getline(2),'^.*Next: \zs[^,\t]\+\ze[,\t]')
   call search('\<'.g:mpv_infolink.'\>','W')

  elseif a:cmd == '<'
   let g:mpv_infolink= matchstr(getline(2),'^.*Prev: \zs[^,\t]\+\ze[,\t]')
   call search('\<'.g:mpv_infolink.'\>','bW')

  else
   echohl WarningMsg
   echo "***warning*** (s:InfoIndexLink) unsupported command ".a:cmd
   echohl Normal
  endif

"  call Dret("s:InfoIndexLink")
endfun

" ---------------------------------------------------------------------
" manpageview#:ManPagePhp: {{{2
fun! manpageview#ManPagePhp()
  let s:before_K_posn = SaveWinPosn(0)
  let topic           = substitute(expand("<cWORD>"),'()\=.*$','.php','')
"  call Dfunc("manpageview#ManPagePhp() topic<".topic.">")
  call manpageview#ManPageView(0,topic)
"  call Dret("manpageview#ManPagePhp")
endfun

" ---------------------------------------------------------------------
" manpageview#:ManPagePython: {{{2
fun! manpageview#ManPagePython()
  let s:before_K_posn = SaveWinPosn(0)
  let topic           = substitute(expand("<cWORD>"),'()\=.*$','.py','')
"  call Dfunc("manpageview#ManPagePython() topic<".topic.">")
  call manpageview#ManPageView(0,topic)
"  call Dret("manpageview#ManPagePython")
endfun

" ---------------------------------------------------------------------
" manpageview#ManPageVim: {{{2
fun! manpageview#ManPageVim(topic)
"  call Dfunc("manpageview#ManPageVim(topic<".a:topic.">)")
  if g:manpageview_winopen == "only"
   " OMan
   exe "help ".fnameescape(a:topic)
   only
  elseif g:manpageview_winopen == "vsplit"
   " VMan
   exe "vert help ".fnameescape(a:topic)
  elseif g:manpageview_winopen == "vsplit="
   " VEMan
   exe "vert help ".fnameescape(a:topic)
   wincmd =
  elseif g:manpageview_winopen == "hsplit="
   " HEMan
   exe "help ".fnameescape(a:topic)
   wincmd =
  elseif g:manpageview_winopen == "tab"
   " TMan
   tabnew
   exe "help ".fnameescape(a:topic)
   only
  elseif g:manpageview_winopen == "reuse"
   " RMan
   let g:manpageview_manwin = -1
   exe "noautocmd windo if &ft == 'help'|let g:manpageview_manwin= winnr()|endif"
   if g:manpageview_manwin != -1
	" found a pre-existing help window, re-using it
"	DechoWF "found pre-exiting help window, re-using it"
	exe g:manpageview_manwin."wincmd w"
    exe "help ".fnameescape(a:topic)
   elseif &l:mod == 1
	" file has been modified, would be lost if we re-used window.  Use regular help instead if its the only window on the buffer
	let g:manpageview_bufcnt  = 0
	let g:manpageview_bufname = bufname("%")
	noautocmd windo if bufname("%") == g:manpageview_bufname|let g:manpageview_bufcnt= g:manpageview_bufcnt + 1 | endif
    if g:manpageview_bufcnt > 1
     exe "help ".fnameescape(a:topic)
	 wincmd j
	 q
	else
"	 DechoWF "file<".expand("%")."> has been modified and would be lost if re-used.  Using regular help"
     exe "help ".fnameescape(a:topic)
	endif
   elseif &ft != "help"
	" re-using current window (but hiding it first)
"	DechoWF "re-using current window#".winnr()." (hiding it first)"
   	setlocal bh=hide
    exe "help ".fnameescape(a:topic)
	wincmd j
	q
   else
	" already a help window
    exe "help ".fnameescape(a:topic)
   endif
  else
   " Man
   exe "help ".fnameescape(a:topic)
  endif

"  call Dret("manpageview#ManPageVim")
endfun

" ---------------------------------------------------------------------
" manpageview#ManPageTex: {{{2
fun! manpageview#ManPageTex()
  let s:before_K_posn = SaveWinPosn(0)
  let topic           = '\'.expand("<cWORD>")
"  call Dfunc("manpageview#ManPageTex() topic<".topic.">")
  call manpageview#ManPageView(0,topic)
"  call Dret("manpageview#ManPageTex")
endfun

" ---------------------------------------------------------------------
" manpageview#ManPageTexLookup: {{{2
fun! manpageview#ManPageTexLookup(book,topic)
"  call Dfunc("manpageview#ManPageTexLookup(book<".a:book."> topic<".a:topic.">)")
  let userdoc= substitute(&rtp,',.*','','')
  if filereadable(userdoc."/doc/latexhelp.txt")
   call manpageview#ManPageVim(a:topic)
  else
   echomsg "May I suggest getting Mikolaj Michowski's latexhelp.txt"
   echomsg "http://www.vim.org/scripts/script.php?script_id=206"
  endif
"  call Dret("manpageview#ManPageTexLookup")
endfun

" ---------------------------------------------------------------------
" Function: {{{2
fun! Function()
"  call Dfunc("Function()")
"  call Dret("Function")
endfun

" ---------------------------------------------------------------------
" manpageview#KMan: set default extension for K map {{{2
fun! manpageview#KMan(ext)
"  call Dfunc("manpageview#KMan(ext<".a:ext.">)")

  let s:before_K_posn = SaveWinPosn(0)
  if a:ext == "perl"
   let ext= "pl"
  elseif a:ext == "gvim"
   let ext= "vim"
  elseif a:ext == "info" || a:ext == "i"
   let ext    = "i"
   set ft=info
  elseif a:ext == "man"
   let ext= ""
  else
   let ext= a:ext
  endif
"  DechoWF "ext<".ext.">"

  " change the K map
"  DechoWF "change the K map"
  sil! nummap K
  sil! nunmap <buffer> K
  if exists("g:manpageview_K_{ext}") && g:manpageview_K_{ext} != ""
   exe "nmap <silent> <buffer> K :call ".g:manpageview_K_{ext}."\<cr>"
"   DechoWF "nmap <silent> K :call ".g:manpageview_K_{ext}
  else
"   DechoWF "change K map (KMan)"
   nmap <unique> K <Plug>ManPageView
"   DechoWF "nmap <unique> K <Plug>ManPageView"
  endif

"  call Dret("manpageview#KMan ")
endfun

" ---------------------------------------------------------------------
" s:WinReport: {{{2
fun! s:WinReport()
  let winreport = ""
  let curwin    = winnr()
  sil! noautocmd windo let winreport= winreport." win#".winnr()."<".bufname("%").">"
  exe "noautocmd ".curwin."wincmd w"
  return winreport
endfun

" ---------------------------------------------------------------------
" manpageview#History: save and apply history {{{2
"   mode=0 : save
"   mode>0 : move up history
"   move<0 : move down history
fun! manpageview#History(mode,...)
"  call Dfunc("manpageview#History(mode=".a:mode.") a:0=".a:0)
  if !exists("s:history")
"   DechoWF "initializing history"
   let s:history= []
   let s:ihist  = 0
  endif
"  call Decho("s:history=".string(s:history))
"  call Decho("s:ihist  =".s:ihist)
"  call Decho("a:mode=".a:mode)
"  call Decho("a:0   =".a:0)
"  if a:0 >= 1|call Decho("a:1<".a:1.">")|endif
"  if a:0 >= 2|call Decho("a:2<".a:2.">")|endif
"  if exists("s:history[s:ihist]")|call Decho("s:history[s:ihist] exists")|endif
"  if exists("s:history[s:ihist]")|call Decho("s:history[".s:ihist."]<".string(s:history[s:ihist]).">")|endif

  " Enter current manpage into history
  if a:mode == 0
   if a:0 >= 2
	if len(s:history) == 0 || (exists("s:history[s:ihist]") && !(s:history[s:ihist][0] == a:1 && s:history[s:ihist][1] == a:2))
     let s:history+= [[a:1,a:2]]
	 let s:ihist   = len(s:history)-1
"	 call Decho("(new) s:history[".s:ihist."]=".string(s:history))
    endif
   endif

  " Return to subsequent history
  elseif a:mode > 0
   if s:ihist >= len(s:history)-1
	" already showing end of history
    let s:ihist= len(s:history)
   else
	let s:ihist= s:ihist + a:mode
	if s:ihist > len(s:history)
	 let s:ihist= len(s:history) - 1
	endif
"	call Decho("(next) history[".s:ihist."]=".string(s:history[s:ihist]))
	call manpageview#ManPageView(s:history[s:ihist][0],s:history[s:ihist][1])
   endif

  " Return to prior history
  elseif a:mode < 0
   if s:ihist <= 0
	" already showing beginning of history
    let s:ihist= 0
   else
	let s:ihist= s:ihist + a:mode
	if s:ihist < 0
	 let s:ihist= 0
	endif
"	call Decho("(prev) history[".s:ihist."]=".string(s:history[s:ihist]))
	call manpageview#ManPageView(s:history[s:ihist][0],s:history[s:ihist][1])
   endif
  endif

  " install history maps
  nno <silent> <buffer> <s-down>	:call manpageview#History(-v:count1)<cr>
  nno <silent> <buffer> <s-up>		:call manpageview#History( v:count1)<cr>
"  call Dret("manpageview#History")
endfun

" ---------------------------------------------------------------------
" manpageview#BookSearch: search for another manpagepage on the given topic {{{2
"   direction= +1 : search larger  book numbers
"            = -1 : search smaller book numbers
fun! manpageview#BookSearch(direction)
"  call Dfunc("manpageview#BookSearch(direction=".a:direction.")")
  let bknum    = s:history[s:ihist][0]
  let curbknum = bknum
  if bknum == ""
   if getline(2) =~ '(\d\+[px]\=)'
	let bknum= substitute(getline(2),'^.\{-}(\(\d\+[px]\=\)).*$','\1','')
   elseif getline(1) =~ '(\d\+[px]\=)'
	let bknum= substitute(getline(1),'^.\{-}(\(\d\+[px]\=\)).*$','\1','')
   else
	let bknum= "1"
   endif
"   call Decho("booksearch: setting bknum=".bknum." (was empty string)")
  elseif type(bknum) != 1
   let bknum= string(bknum)
  endif
  let s:mpv_booksearch      = 1
  let retval                = -1
  let topic                 = s:history[s:ihist][1]
  let curtopic              = topic
  let keep_mpv_winopen      = g:manpageview_winopen
  let keeplz                = &lz
  set lz
  let g:manpageview_winopen = "reuse"
  let bknumlist             = ["0p","1","1p","1x","2","2x","3","3p","3x","4","4x","5","5x","5p","6","6x","6p","7","7x","8","8x","9","9x"]
  let ibk                   = index(bknumlist,bknum)
"  call Decho("booksearch: current bknum#".bknum." (type ".type(bknum).")   topic<".topic."> ibk=".ibk. "(reuse)")
  if ibk != -1
   let s:booksearching= winnr()
   while retval < 0
    let ibk  += a:direction
	if ibk < 0 || len(bknumlist) <= ibk
	 break
	endif
    let bknum = bknumlist[ibk]
"    call Decho("‣booksearch: trying bknum#".bknum."   topic<".topic.">")
    let retval = manpageview#ManPageView(bknum,topic)
   endwhile
   unlet s:booksearching
  endif
  unlet s:mpv_booksearch
  let &lz= keeplz
  if retval < 0
   call manpageview#ManPageView(curbknum,curtopic)
   echohl WarningMsg
   echomsg "***warning*** unable to find man page on <".topic."> with a ".((a:direction > 0)? "larger" : "smaller")." book number"
   echohl None
   sleep 2
  endif
  let g:manpageview_winopen = keep_mpv_winopen
"  call Dret("manpageview#BookSearch")
endfun

" =====================================================================
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" =====================================================================
" Modeline: {{{1
" vim: ts=4 fdm=marker
