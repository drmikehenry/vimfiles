" vim:tw=80:ts=4:sts=4:sw=4:et:ai

" =============================================================
" Early Setup
" =============================================================

if has('nvim') && !exists('g:python3_host_prog')
    " Ensure Neovim Python provider is setup before any use of Python.
    for s:pynvim_python in [
            \ 'pynvim-python-interpreter',
            \ expand('~/venvs/pynvim/bin/python'),
            \ expand('~/venvs/pynvim/Scripts/python.exe'),
            \ '/opt/pynvim/bin/python'
            \ ]
        if executable(s:pynvim_python)
            let g:python3_host_prog = s:pynvim_python
            break
        endif
    endfor
endif

" Enable vi-incompatible Vim extensions (redundant since .vimrc exists).
set nocompatible

" Use utf-8 encoding for all content.
set encoding=utf-8

" 'fileencodings' contains a list of possible encodings to try when reading
" a file.  When 'encoding' is a unicode value (such as utf-8), the
" value of fileencodings defaults to ucs-bom,utf-8,default,latin1.
"   ucs-bom  Treat as unicode-encoded file if and only if BOM is present
"   utf-8    Use utf-8 encoding
"   default  Value from environment LANG
"   latin1   8-bit encoding typical of DOS
" Setting this value explicitly, though to the default value.
set fileencodings=ucs-bom,utf-8,default,latin1

" Turn off syntax highlighting and filetype support in case a system vimrc
" has enabled them.  We'll turn them back on after necessary configuration
" has been done.
syntax off
filetype plugin indent off
filetype off

" Leaving 'fileencoding' unset, as it defaults to the value of 'encoding'.
" May set 'fileencoding' before writing a file to force a new encoding.
" May also set 'bomb' to force use of a BOM (Byte Order Mark).
" set fileencoding=

" `v:true` and `v:false` were added in Vim-7.4.1271, 2016-02-06.
if exists('v:true')
    let g:local_true = v:true
    let g:local_false = v:false
else
    let g:local_true = 1
    let g:local_false = 0
endif

" Set environment variable to directory containing this vimrc.  Expect absolute
" directory $HOME/.vim on Unix or %USERPROFILE%\vimfiles on Windows.
let $VIMFILES = expand("<sfile>:p:h")

function! DetectPlatform()
    if has("gui_win32")
        return "win32"
    endif

    " Assume we're on a Unix box.
    let name = substitute(system("uname"), '^\_s*\(.\{-}\)\_s*$', '\1', '')

    return tolower(name)
endfunction

function! DetectVmware(platform)
    if a:platform == "linux"
        if filereadable("/sys/class/dmi/id/sys_vendor")
            for line in readfile("/sys/class/dmi/id/sys_vendor", '', 10)
                if line =~ '\cvmware'
                    return 1
                endif
            endfor
        endif
    elseif a:platform == "freebsd"
        if executable("kldstat")
            let output = system("kldstat")
            if output =~ "vmxnet"
                return 1
            endif
        endif
    endif

    return 0
endfunction

let g:Platform = DetectPlatform()
let g:InVmware = DetectVmware(g:Platform)

function! AdjustBaseFontSize(size)
    if g:Platform != "darwin"
        return a:size
    endif

    " Mac's idea of a point on screen is not the same as everyone else's.
    " It appears that most operating systems either expect the screen to be 96
    " DPI, or will query the monitor.  Mac, on the other hand, assumes that the
    " monitor is 72 DPI.
    return ((a:size * 96) + 35) / 72
endfunction

" -------------------------------------------------------------
" List manipulation
" -------------------------------------------------------------

function! Flatten(nestedLists)
    let flattened = []
    let i = 0
    while i < len(a:nestedLists)
        if type(a:nestedLists[i]) == type([])
            let flattened += Flatten(a:nestedLists[i])
        else
            let flattened += [a:nestedLists[i]]
        endif
        let i += 1
    endwhile
    return flattened
endfunction

function! ListContains(list, valueToFind)
    for item in a:list
        if item == a:valueToFind
            return 1
        endif
    endfor
    return 0
endfunction

" Pop leftmost element from list; if list is empty, return defaultValue instead.
function! ListPop(list, defaultValue)
    let value = a:defaultValue
    if len(a:list) > 0
        let value = a:list[0]
        unlet a:list[0]
    endif
    return value
endfunction


" -------------------------------------------------------------
" Utility functions
" -------------------------------------------------------------

" Make sure to include the proper scope on varName (e.g., an unprefixed
" variable will not be considered global).
function! GetVar(varName, defaultValue)
    if exists(a:varName)
        return eval(a:varName)
    endif
    return a:defaultValue
endfunction

function! DictGet(dict, key, defaultValue)
    if has_key(a:dict, a:key)
        return a:dict[a:key]
    endif
    return a:defaultValue
endfunction

function! DictUnlet(dict, key)
    if has_key(a:dict, a:key)
        unlet a:dict[a:key]
    endif
endfunction

" Verify len(varArgs) <= maxNumArgs, then return a modifiable copy of varArgs.
function! VarArgs(maxNumArgs, varArgs)
    let args = copy(a:varArgs)
    if len(args) > a:maxNumArgs
        throw "Too many arguments supplied (>" . a:maxNumArgs . ")"
    endif
    return args
endfunction

" Verify len(varArgs) is 0 or 1; return sole arg or defaultValue if none given.
function! OptArg(varArgs, defaultValue)
    return ListPop(VarArgs(1, a:varArgs), a:defaultValue)
endfunction

" Acquire the list of all loaded scripts as absolute paths.
"   Paths will use native separators (e.g., /unix/path or \windows\path).
function! ScriptPaths()
    redir => lines
    silent! scriptnames
    redir END
    let paths = []
    for line in split(lines, '\n')
        let path = substitute(line, '^\s*[0-9]\+:\s*\(.*\)', '\1', '')
        call add(paths, fnamemodify(path, ':p'))
    endfor
    return paths
endfunction

" Return absolute ScriptPath that matches given script.
"   If an exact match can be found, it will be returned.  Otherwise, if exactly
"   one absolute path has a:script as a suffix, it will be returned.
"   The empty string is returned on failure.
function! GetScript(script)
    let paths = ScriptPaths()
    let matches = []
    for path in paths
        if path == a:script
            return path
        elseif path[-len(a:script):] == a:script
            call add(matches, path)
        endif
    endfor
    if len(matches) == 1
        return matches[0]
    endif
    return ''
endfunction

" Lookup the <SID> for a given script.  This allows for accessing
" script-local variables.
" Return 0 on failure.
function! GetSID(script)
    let path = GetScript(a:script)
    if path != ''
        return index(ScriptPaths(), path) + 1
    endif
    return 0
endfunction

" Lookup symbol in s: of given script.
" Uses GetSID(script) to locate the <SID> of the given script; if found,
" creates the script-local name ('<SNR>' . sid . '_' . symbol).
function! GetSymbol(script, symbol)
    let sid = GetSID(a:script)
    if sid > 0
        return '<SNR>' . sid . '_' . a:symbol
    endif
    return ''
endfunction

" Return [line, col] subset of the output of getpos(expr).
function! GetPos(expr)
    return getpos(a:expr)[1:2]
endfunction

" [line, col] points to the start of a character in the buffer.
" [1, 1] indicates the [first line, first character on the line].
" Adjust col to point to the final byte of this character; this will do nothing
" for single-byte characters.
function! AdjustColToCharEnd(line, col)
    let end_col = a:col
    " Match a single character at end_col.
    " Note that end_col might be an oversize value (e.g., 2147483647)
    " compared to the number of bytes on the corresponding line.  This occurs
    " when doing a linewise selection, for example.  To keep matchstr() from
    " throwing E951 due to an oversized column number, avoid testing the
    " text when end_col is too large to need incrementation.
    let text = getline(a:line)
    if end_col < len(text)
        let num_bytes = len(matchstr(text, '\%' . end_col . 'c.'))
        if num_bytes > 1
            let end_col += num_bytes - 1
        endif
    endif
    return end_col
endfunction

" If start_pos comes after end_pos in the buffer, reverse them.
" Return the pair in their proper order within the buffer.
function! NormalizeStartEndPos(start_pos, end_pos)
    let [start_line, start_col] = a:start_pos
    let [end_line, end_col] = a:end_pos
    if start_line > end_line || (start_line == end_line && start_col > end_col)
        return [a:end_pos, a:start_pos]
    endif
    return [a:start_pos, a:end_pos]
endfunction

" start_pos = [start_line, start_col]
" end_pos = [end_line, end_col]
" end_pos may be earlier in the buffer than start_pos.
" Each col number is a one-based byte index into the corresponding line.
" For example, [1, 1] is the first line, first column.
" If the ending column points to a multi-byte character, the byte index must
" be adjusted to include all of the bytes in that character.
" Ref: https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function GetLines(start_pos, end_pos)
    let [start_pos, end_pos] = NormalizeStartEndPos(a:start_pos, a:end_pos)
    let [start_line, start_col] = start_pos
    let [end_line, end_col] = end_pos
    " Account for end_col pointing to multi-byte character.
    let end_col = AdjustColToCharEnd(end_line, end_col)
    let lines = []
    let end_final_col = col([end_line, '$'])
    let start_line_text = getline(start_line)
    if start_line == end_line
        if end_col >= end_final_col
            call extend(lines, [start_line_text[(start_col - 1):], ""])
        else
            call add(lines, start_line_text[(start_col - 1):(end_col - 1)])
        endif
    else
        call add(lines, start_line_text[(start_col - 1):])
        let end_line_text = getline(end_line)
        if (end_line - start_line) > 1
            call extend(lines, getline(start_line + 1, end_line - 1))
        endif
        if end_col < end_final_col
            call add(lines, end_line_text[:(end_col - 1)])
        else
            call extend(lines, [end_line_text, ""])
        endif
    endif
    return lines
endfunction

" start_pos = [start_line, start_col]
" end_pos = [end_line, end_col]
" Joins lines returned from GetLines(start_pos, end_pos) into a single string.
function GetText(start_pos, end_pos)
    return join(GetLines(a:start_pos, a:end_pos), "\n")
endfunction

" Get most recently selected visual text.
function GetSelectedText()
    return GetText(GetPos("'<"), GetPos("'>"))
endfunction

" -------------------------------------------------------------
" runtimepath manipulation
" -------------------------------------------------------------

" Escape commas and backslashes in path.
function! PathEscape(path)
    return escape(a:path, ',\')
endfunction

" Un-escape commas and backslashes in path.
function! PathUnescape(path)
    " Very magic.
    let rex = '\v'

    " Find escaping backslash, capture following backslash or a comma.
    let rex .= '\\([\\,])'

    return substitute(a:path, rex, '\1', "g")
endfunction

" Join paths into comma-separated path string.
"   Backslashes and commas will be escaped in final string.
"   Arguments are individual strings or lists of strings.
function! PathJoin(...)
    let paths = Flatten(a:000)
    let paths = map(paths, 'PathEscape(v:val)')
    let path = join(paths, ",")
    return path
endfunction

" Split comma-separated path string into a list.
"   Honors escaped backslashes and commas.
function! PathSplit(path)
    " Split regex: Very magic.
    let rex = '\v'

    " Begin match after a non-backslash.
    let rex .= '\\@<!'

    " Match an zero or more pairs of backslashes; each pair
    " represents a single escaped backslash.
    let rex .= '%(\\\\)*'

    " Now set start-of-match and require a comma (which is necessarily not
    " escaped).
    let rex .= '\zs,'

    let paths = split(a:path, rex)

    " Unescape individual paths.
    let paths = map(paths, 'PathUnescape(v:val)')
    return paths
endfunction

function! RtpPrepend(path)
    if isdirectory(a:path)
        let &runtimepath = PathEscape(a:path) . "," . &runtimepath
        let after = a:path . "/after"
        if isdirectory(after)
            let &runtimepath = &runtimepath . "," . PathEscape(after)
        endif
    endif
endfunction

" Append path later in &runtimepath than refPath (similarly for path/after).
" - Non-existing paths are not added to &runtimepath.
" - If refPath does not exist, path is inserted at start of &runtimepath.
" - If refPath/after does not exist, path/after is added to end of &runtimepath.
function! RtpAppend(path, refPath)
    if isdirectory(a:path)
        let rtpParts = PathSplit(&runtimepath)
        let i = index(rtpParts, a:refPath)
        if i >= 0
            call insert(rtpParts, a:path, i + 1)
        else
            call insert(rtpParts, a:path, 0)
        endif
        let after = a:path . "/after"
        if isdirectory(after)
            let i = index(rtpParts, a:refPath . "/after")
            if i >= 0
                call insert(rtpParts, after, i)
            else
                call add(rtpParts, after)
            endif
        endif
        let &runtimepath = PathJoin(rtpParts)
    endif
endfunction

" If script exists, source it.
function! Source(script)
    let expandedPath = expand(a:script)
    if filereadable(expandedPath)
        execute 'source ' . expandedPath
    endif
endfunction

" Inserts directory "path" right after $VIMUSERFILES in &runtimepath. If
" "path/after" exists, it will be inserted just before $VIMUSERFILES/after (or
" appended to the end of &runtimepath if $VIMUSERFILES/after is not in
" &runtimepath).
"
" The goal is to allow inheriting another user's configuration. This will get
" &runtimepath fixed up correctly, but you still need to source the before and
" after scripts within your before and after scripts, respectively.
function! RtpInherit(path)
    call RtpAppend(a:path, $VIMUSERFILES)
endfunction

" -------------------------------------------------------------
" Ensure `$VIMFILES` is in 'runtimepath'.
" -------------------------------------------------------------
if index(PathSplit(&runtimepath), $VIMFILES) < 0
    call RtpPrepend($VIMFILES)
endif

" -------------------------------------------------------------
" Per-user customization pre-setup
" -------------------------------------------------------------

" NOTE: Several environment variables follow that may be customized.
" See doc/notes.txt in the |notes_customizations| section for details about
" these variables.
"
" Environment variables are used instead of Vim variables to allow
" configuration at the operating-system level outside of Vim.

" VIMUSER defaults to the logged-in user, but may be overridden to allow
" multiple user to share the same overrides (e.g., to let "root" share settings
" with another user).
if $VIMUSER == ""
    let $VIMUSER = expand(has('win32') ? '$USERNAME' : '$USER')
endif

" Parent directory of .vim/vimfiles (typically $HOME).
let s:vimParent = fnamemodify($VIMFILES, ':h')

let s:slashdot = has('win32') ? '/_' : '/.'

if $VIMLOCALFILES == ''
    let $VIMLOCALFILES = s:vimParent . s:slashdot . 'vimlocal'
    if !isdirectory($VIMLOCALFILES)
        let $VIMLOCALFILES = expand('$VIMFILES/local')
    endif
endif

if $VIMUSERFILES == ''
    let $VIMUSERFILES = s:vimParent . s:slashdot . 'vimuser'
    if !isdirectory($VIMUSERFILES)
        let $VIMUSERFILES = expand('$VIMFILES/user/$VIMUSER')
    endif
endif

if $VIMUSERLOCALFILES == ''
    let $VIMUSERLOCALFILES = s:vimParent . s:slashdot . 'vimuserlocal'
endif

" To enable, disable, or check the enabled status of a plugin, use the below
" functions:
"
"   call vimf#plugin#enable('plugin_name')
"   call vimf#plugin#disable('plugin_name')
"   if vimf#plugin#enabled('plugin_name')
"       " 'plugin_name' is enabled....
"   endif
"
" NOTE: Plugin enabling or disabling must be performed very early in your
" vimrc-vars.vim.
"
" Plugin enabling is based on the Pathogen plugin.
" Define an empty g:pathogen_disabled so users can assume it always exists.
if !exists('g:pathogen_disabled')
    let g:pathogen_disabled = []
endif

" Disable an experimental plugin for users in general.  Do this early (before
" `vimrc-vars.vim`):
"   call vimf#plugin#disable('plugin_name')

" Activate pathogen in case a user would need to activate a bundle in
" |VIMRC_VARS| as part of setting up some variable.

runtime bundle/pathogen/autoload/pathogen.vim

" Source |VIMRC_VARS| files (if they exist), lowest-to-highest priority order.
" Note that $VIMUSERFILES won't yet be in the 'runtimepath'.
call Source('$VIMLOCALFILES/vimrc-vars.vim')
call Source('$VIMUSERFILES/vimrc-vars.vim')
call Source('$VIMUSERLOCALFILES/vimrc-vars.vim')

" Prepend override directories in lowest-to-highest priority order, so that
" the highest priority ends up first in 'runtimepath'.
call RtpPrepend($VIMLOCALFILES)
call RtpPrepend($VIMUSERFILES)
call RtpPrepend($VIMUSERLOCALFILES)

" Setup an environment variable for cache-related bits.  This follows
" XDG_CACHE_HOME by default, but can be overridden by the user.
if $VIM_CACHE_DIR == ""
    if $XDG_CACHE_HOME != ""
        let $VIM_CACHE_DIR = expand("$XDG_CACHE_HOME/vim")
    else
        if has("win32")
            let $VIM_CACHE_DIR = expand("$USERPROFILE/.cache/vim")
        else
            let $VIM_CACHE_DIR = expand("$HOME/.cache/vim")
        endif
    endif
endif

" -------------------------------------------------------------
" Python path management
" -------------------------------------------------------------

if has('python3')
    let g:Python = 'python3'
elseif has('python')
    let g:Python = 'python'
else
    let g:Python = ''
endif

" Determine best system Python executable.
if !exists('g:PythonExecutable')
    if executable('python3') == 1
        let g:PythonExecutable = 'python3'
    elseif executable('python') == 1
        let g:PythonExecutable = 'python'
    else
        let g:PythonExecutable = ''
    endif
endif

" Setup Python's sys.path to include any "python2", "python3", or "pythonx"
" directories found as immediate children of paths in Vim's 'runtimepath'.  This
" allows for more easily sharing Python modules.

" Only need to run if Vim is not at least 7.3.1163.
" See :help python-special-path (>=7.3.1163) for more information.
if has('python3') || has('python')
if v:version < 703 || (v:version == 703 && !has('patch1163'))
function! AugmentPythonPath(python, folders)
    execute a:python . ' << endpython'
import vim
import os
for p in vim.eval("PathSplit(&runtimepath)"):
    for f in vim.eval("a:folders"):
        libPath = os.path.join(p, f)
        if os.path.isdir(libPath) and libPath not in sys.path:
            sys.path.append(libPath)
endpython
endfunction
if has('python3')
    call AugmentPythonPath('python3', ['pythonx', 'python3'])
endif
if has('python')
    call AugmentPythonPath('python', ['pythonx', 'python2'])
endif
endif
endif

" -------------------------------------------------------------
" Plugin enables
" -------------------------------------------------------------

" These must be handled before pathogen#infect() below.

" To disable one of the specified plugins below, define the corresponding
" g:EnableXxx variables below to be 0 (typically, this would be done in
" the per-user VIMRC_VARS file, as plugin enable/disable adjustments must be
" done early).
" For example, to disable the UltiSnips plugin, use the following:
"   let g:EnableUltiSnips = 0

if !exists('g:EnableAle')
    let g:EnableAle = !has('nvim')
endif

if !exists('g:EnableSyntastic')
    let g:EnableSyntastic = !has('nvim')
endif

if !exists('g:EnableVimLsp')
    let g:EnableVimLsp = !has('nvim')
endif

" Determine vim-lsp compatibility.
if has('nvim')
    " TODO: Determine what version of Neovim is required for vim-lsp.
else
    " vim-lsp requires Vim 8.1.1035 or newer.
    if v:version < 801 || (v:version == 801 && !has('patch1035'))
        let g:EnableVimLsp = 0
    endif
endif

" Gvim bug https://github.com/vim/vim/issues/3417 is fixed in Gvim 8.1.0834.
" Without this patch, Gvim support for timers is buggy, so ALE should not be
" enabled.
if v:version < 801 || (v:version == 801 && !has('patch0834'))
    let g:EnableAle = 0
endif

" Prefer Ale to Syntastic.
if g:EnableAle
    let g:EnableSyntastic = 0
endif

if !g:EnableSyntastic
    call vimf#plugin#disable('syntastic')
    " Define :SyntasticReset so other Syntastic wrapper functions will not fail.
    command! SyntasticReset let b:syntastic_enabled = 0
endif

if !g:EnableAle
    call vimf#plugin#disable('ale')
endif

if !g:EnableVimLsp
    call vimf#plugin#disable('vim-lsp')
    call vimf#plugin#disable('vim-lsp-ale')
endif

" Don't use Powerline or Airline on 8-color terminals; they don't look good.
if !has("gui_running") && &t_Co == 8
    let g:EnableAirline = 0
    let g:EnablePowerline = 0
endif

if !exists("g:EnableAirline")
    let g:EnableAirline = 1
endif

if !exists("g:EnablePowerline")
    let g:EnablePowerline = 0
endif

if g:EnablePowerline
    let g:EnableAirline = 0
endif

" Disable Powerline and/or Airline.
if !g:EnablePowerline
    call vimf#plugin#disable('powerline')
endif
if !g:EnableAirline
    call vimf#plugin#disable('airline')
    call vimf#plugin#disable('airline-themes')
endif


if !exists("g:EnableUltiSnips")
    " UltiSnips now requires Python3.
    let g:EnableUltiSnips = has('python3')
endif

if !exists('g:EnableOmniCppComplete')
    let g:EnableOmniCppComplete = !has('nvim')
endif

if !g:EnableOmniCppComplete
    call vimf#plugin#disable('omnicppcomplete')
endif

" -------------------------------------------------------------
" Pathogen bundle management
" -------------------------------------------------------------

" Bundle directories:
"
" - `bundle/` is for bundles used by both Vim and Neovim.
" - `nvim-bundle/` is for Neovim-only bundles.
" - `vim-bundle/` is for Vim-only bundles.
" - Bundles in a directory with prefix `pre-` will come earlier in the
"   'runtimepoath' than those without the prefix.

" Infect all bundle directories in order of increasing priority.

if has('nvim')
    let s:editor_name = 'nvim'
else
    let s:editor_name = 'vim'
endif

let g:vimf_bundle_dirnames = [
        \ 'bundle',
        \ s:editor_name . '-bundle',
        \ 'pre-bundle',
        \ 'pre-' . s:editor_name . '-bundle',
        \ ]

for s:dirname in g:vimf_bundle_dirnames
    call pathogen#infect(s:dirname . '/{}')
endfor

" Enable 24-bit color for terminals that support it.
" To countermand this, put ``set notermguicolors`` in your vimrc-before file.
if $COLORTERM == 'truecolor'
    if has("termguicolors")
        set termguicolors
    endif
    if $TERM =~ 'screen\|tmux'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
endif

" -------------------------------------------------------------
" "vimrc-before" overrides
" -------------------------------------------------------------

" Execute in highest-to-lowest priority order, so that high-priority
" gets the first word (and also the last word via vimrc-after).
call Source('$VIMUSERLOCALFILES/vimrc-before.vim')
call Source('$VIMUSERFILES/vimrc-before.vim')
call Source('$VIMLOCALFILES/vimrc-before.vim')

" Determine if Vim's auto-detected 'background' option is trustworthy.
function! BackgroundIsTrustworthy()
    if has('gui_running')
        " Without a terminal, there is no background context to detect.
        return 0
    endif

    if $COLORFGBG != ''
        " COLORFBBG is a good indicator of the terminal background color.
        return 1
    endif

    " In Vim 7.4.757 (2015-06-25), support was added to probe for the terminal's
    " background color.  This is a feature of xterm that some other terminals
    " have added (notably, and sadly, not tmux (yet)).  However, there is no
    " easy way for us to tell whether the terminal responded to the request for
    " background color with this early support.  Later, Vim 8.0.1016
    " (2017-08-30) brought in the variable v:termrgbresp (mis-spelled) to hold
    " the terminal's response to the background color query.  The spelling was
    " corrected to v:termrbgresp in Vim 8.0.1194 (2017-10-14) (though the
    " runtime documentation wasn't corrected until 2017-11-02).  If either of
    " these variables exists and is non-empty, then Vim successfully learned the
    " true background color from the terminal and 'background' is trustworthy.

    " Well, bummer.  The above paragraph sounds nice, but the reality is that
    " v:termrbgresp isn't set yet while the .vimrc is being processed.  Other
    " than setting a timer and probing for it, there isn't a way to use the
    " automatically probed values.  The question has come up on the list:
    " https://groups.google.com/forum/#!topic/vim_use/zV2sO-m3fD0
    " Sounds like there may someday be an autocommand for reporting back
    " the background color, but it's not clear how that can help us determine
    " which colorscheme to choose since it will come later than we'd like.
    "
    " TODO: Revisit this if Vim ever gets better support for v:termrbgresp:
    " if (exists('v:termrgbresp') && v:termrgbresp != '') ||
    "         \ (exists('v:termrbgresp') && v:termrbgresp != '')
    "    return 1
    " endif

    return 0
endfunction

" =============================================================
" Title
" =============================================================

" Enable setting the title in the titlebar.
set title

" Defer calculation of 'titlestring' until entering Vim, as it depends
" on the value of `v:servername` that won't be set this early.
augroup vimf_title
    autocmd!
    autocmd VimEnter * call vimf#init#setupTitle()
augroup END

" =============================================================
" Color schemes
" =============================================================

" Setup a color scheme early for better visibility of errors and to nail down
" 'background' (which changes when a new colorscheme is selected).

" If a user sets up a colorscheme in his |VIMRC_BEFORE| script (or early in his
" ~/.vimrc file), the varible g:colors_name will be set and no default
" colorscheme selection will take place.  To use no colorscheme at all, set
" g:colors_name to the empty string.

" If the user hasn't chosen a colorscheme, we setup a default.  If we can't
" trust the background color detection, we force a dark background.

if !exists("g:colors_name")
    if !BackgroundIsTrustworthy()
        set background=dark
    endif
    if &background == "dark"
        if !has("gui_running") && &t_Co <= 8
            " With only a few colors, it's better to use a simple colorscheme.
            colorscheme elflord
        else
            " Dark scheme maintained by John Szakmeister.
            colorscheme szakdark
        endif
    else
        colorscheme nuvola
    endif
endif

" Provide a default Powerline colorscheme.
if !exists("g:Powerline_colorscheme")
    if &background == "dark"
        let g:Powerline_colorscheme = 'szakdark'
    else
        " At present, we don't have complete support for light backgrounds
        " (though 'nuvola' is a start at it).
    endif
endif

" Highlight the column just after &textwidth (unless &textwidth is zero).
if exists('+colorcolumn')
    set colorcolumn=+1
endif

" =============================================================
" GUI Setup
" =============================================================

if !exists("g:DefaultFontFamilies")
    let g:DefaultFontFamilies = []
endif
let g:DefaultFontFamilies += [
        \ "Hack",
        \ "PragmataPro for Powerline",
        \ "PragmataPro",
        \ "DejaVu Sans Mono for Powerline",
        \ "Droid Sans Mono for Powerline",
        \ "Consolas for Powerline",
        \ "DejaVu Sans Mono",
        \ "Droid Sans Mono",
        \ "Consolas",
        \]

" Font Families matching the regex patterns below have known-good Unicode
" symbols for use with Powerline.
if !exists("g:GoodUnicodeSymbolFontFamilyPatterns")
    let g:GoodUnicodeSymbolFontFamilyPatterns = []
endif
let g:GoodUnicodeSymbolFontFamilyPatterns += [
        \ '^PragmataPro\>',
        \ '^DejaVu Sans Mono\>',
        \ '^Droid Sans Mono\>',
        \]

function! FontSupportsPowerlineSymbols(family)
    if a:family =~# ' Powerline$' || a:family == 'Hack'
        return 1
    endif

    return 0
endfunction

" Return type of Powerline symbols to use for given font family.
" Value will be one of "fancy", "unicode", or "compatible".
function! PowerlineSymbolsForFontFamily(family)
    if FontSupportsPowerlineSymbols(a:family)
        return "fancy"
    endif
    for pattern in g:GoodUnicodeSymbolFontFamilyPatterns
        if a:family =~# pattern
            return "unicode"
        endif
    endfor
    return "compatible"
endfunction

function! AirlineCustomizeSymbols()
    if !exists("g:airline_symbols")
        let g:airline_symbols = {}
    endif

    if exists("g:FontFamily") && FontSupportsPowerlineSymbols(g:FontFamily)
        let g:airline_left_sep = "\ue0b0"
        let g:airline_left_alt_sep = "\ue0b1"
        let g:airline_right_sep = "\ue0b2"
        let g:airline_right_alt_sep = "\ue0b3"
        let g:airline_symbols.crypt = "\ue0a2"
        let g:airline_symbols.whitespace = "\u2739"
        let g:airline_symbols.linenr = "\ue0a1"
        let g:airline_symbols.maxlinenr = "\u2630"
        let g:airline_symbols.branch = "\ue0a0"
    else
        " let g:airline_left_sep = '»'
        " let g:airline_left_sep = '▶'
        " let g:airline_left_sep = '│'
        " let g:airline_left_sep = ''
        " let g:airline_left_sep = '>'
        let g:airline_left_sep = ' '
        let g:airline_left_alt_sep = '>'
        " let g:airline_right_sep = '«'
        " let g:airline_right_sep = '◀'
        " let g:airline_right_sep = '│'
        " let g:airline_right_sep = ''
        " let g:airline_right_sep = '<'
        let g:airline_right_sep = ' '
        let g:airline_right_alt_sep = '<'
        let g:airline_symbols.crypt = '🔒'
        let g:airline_symbols.whitespace = 'WS:'
        let g:airline_symbols.linenr = '¶'
        let g:airline_symbols.maxlinenr = ''
        let g:airline_symbols.branch = '⚡'
    endif
endfunction
command! -bar AirlineCustomizeSymbols call AirlineCustomizeSymbols()

function! SetFont()
    if !has("gui_running")
        return
    endif
    if !exists("g:FontFamily")
        let g:FontFamily = fontdetect#firstFontFamily(g:DefaultFontFamilies)
    endif
    if !exists("g:FontSize")
        let g:FontSize = AdjustBaseFontSize(14)
    endif
    if g:FontFamily != "" && g:FontSize > 0
        if has("gui_gtk2") || has("gui_gtk3")
            let font = g:FontFamily . " " . g:FontSize
        else
            let font = g:FontFamily . ":h" . g:FontSize
        endif
        let &guifont = font
        let g:Powerline_symbols = PowerlineSymbolsForFontFamily(g:FontFamily)
        AirlineCustomizeSymbols
    endif
endfunction
command! -bar SetFont call SetFont()

if has("gui_running")
    " 'T' flag controls the toolbar (we don't need it).
    set guioptions-=T

    " 'a' is for Autoselect mode, in which selections will automatically be
    " added to the clipboard (on Windows) or the primary selection (on Unix).
    " This makes it hard to create a selection and then overwrite it with
    " something from the clipboard, so we disable it.
    set guioptions-=a

    " 'L' causes a left-side scrollbar to automatically appear when a
    " vertical split is created.  Unfortunately, there is a timing bug of
    " some kind in Vim that sometimes prevents 'columns' from being
    " properly maintained when the comings and goings of the scrollbar
    " change the width of the GUI frame.  The right-side scrollbar still
    " functions properly for the active window, so there's no need for the
    " left-side scrollbar anyway.
    set guioptions-=L

    " We don't need an always-present left-side scrollbar, either.
    set guioptions-=l

    " Remove additional GUI features that take up space unnecessarily.
    " 'r' - right-hand scrollbar is always present.
    set guioptions-=r

    " 'R' - right-hand scrollbar is present for vertical splits.
    set guioptions-=R

    " 'm' - menu bar is present.
    set guioptions-=m
    SetFont

    " Number of lines of text overall.
    set lines=40
endif

" MacVim-specific setup.  MacVim has a gvimrc setup that alters some bindings.
" We want to keep our M-Left, M-Right, M-Up, and M-Down bindings, so let's
" disable the MacVim setup, and only map the ones that don't collide with other
" mappings we make.
if has("gui_running") && has("gui_macvim")
    if !exists("macvim_skip_cmd_opt_movement")
        let macvim_skip_cmd_opt_movement = 1

        noremap   <D-Left>       <Home>
        noremap!  <D-Left>       <Home>

        noremap   <D-Right>      <End>
        noremap!  <D-Right>      <End>

        noremap   <D-Up>         <C-Home>
        inoremap  <D-Up>         <C-Home>

        noremap   <D-Down>       <C-End>
        inoremap  <D-Down>       <C-End>

        imap      <M-BS>         <C-w>
        imap      <D-BS>         <C-u>
    endif
endif

" =============================================================
" General setup
" =============================================================

" Number of lines of VIM history to remember.
set history=10000

" Automatically re-read files that have changed as long as there
" are no outstanding edits in the buffer.
set autoread

" Setup print options for hardcopy command (if available; Neovim has removed the
" `:hardcopy` functionality).
if has('&printoptions')
    set printoptions=paper:letter,duplex:off
endif

" Enable the [n/m] message for searching.
set shortmess-=S

" Configure mapping timeout in milliseconds (default 1000).
" Controls how long Vim waits for partially complete mapping
" before timing out and using prefix directly.
set timeout timeoutlen=3000

" Configure keycode timeout in milliseconds (default -1).
" Controls how long Vim waits for partially complete
" keycodes (such as <ESC>OH which is the <Home> key).
" If negative, uses 'timeoutlen'.
" Note that in insert mode, there is a special-case hack in the Vim
" source that checks for <Esc> and if there are no additional characters
" immediately waiting, Vim pretends to leave insert mode immediately.
" But Vim is still waiting for 'ttimeoutlen' milliseconds for keycodes,
" so if in insert mode you press <Esc>OH in console Vim (on Linux) within
" 'ttimeoutlen' milliseconds, you'll get <Home> instead of opening a new
" line above and inserting "H".
" Note: The previous value of 50 ms proved to be much too long once
" support for Alt+letter mappings were added by the fixkey plugin.
" Problems cropped up when pressing <Esc> to leave insert mode followed
" too quickly by j or k as cursor movements.  With a long ttimeoutlen,
" these were being interpreted as Alt-j and Alt-k.  Experimentally,
" it seems that ttimeoutlen=5 is short enough to avoid this error
" without causing other problems.
set ttimeout ttimeoutlen=5

" Configure the inactivity timeout.  After this amount of idleness, the
" CursorHold autocmd will be invoked.  Many plugins use this autocmd to perform
" some processing that would be too expensive to perform on each change or
" movement.  The default value is 4000; reducing this lowers the latency for
" plugins to refresh certain slow operations (e.g., airline's tagbar will update
" out-of-date tag names during CursorHold).
set updatetime=1000

" Disallow octal numbers for increment/decrement (CTRL-a/CTRL-x).
set nrformats-=octal

" Enable "virtual" space (beyond end-of-line) when in visual-block mode.
" This is useful for making a rectangular selection at the end of the longest
" line in a set of lines of varying lengths.
set virtualedit=block

" Apple has patched out support for ``diffopt=internal`` in some versions of
" Vim that they ship, so our previous test for has('patch-8.1.0360') is
" unreliable for detecting that feature.  See, for example:
" https://github.com/thoughtbot/dotfiles/issues/655
" https://www.micahsmith.com/blog/2019/11/fixing-vim-invalid-argument-diffopt-iwhite/
"
" As a result, this probe detects support for ``diffopt=internal``.
" Note that Apple's patch removes ``internal`` as a valid option for
" ``diffopt``, but the default value of ``diffopt`` still contains ``internal``.
" This means that ``set diffopt+=SomeValidOption`` has the effect of doing
" ``set diffopt=internal,OtherDefaults,SomeValidOption``, which fails with E474
" regardless of having support for ``SomeValidOption``.  Therefore, the function
" below has the side-effect of removing ``internal`` from ``diffopt`` on builds
" of Vim that lack internal diff support, allowing subsequent statements such as
" ``set diffopt+=SomeValidOption`` to work.
function! HasInternalDiff()
    let parts = split(&diffopt, ',')
    let using_internal = (count(parts, 'internal') == 1)
    try
        set diffopt+=internal
        if !using_internal
            set diffopt-=internal
        endif
        return 1
    catch /E474:/
        set diffopt-=internal
        return 0
    endtry
endfunction

if HasInternalDiff()
    " Use the new internal diff feature with options:
    " - indent-heuristic: uses indentation to improve diffs.
    " - algorithm:histogram: an improved patience algorithm as used in Git.
    set diffopt+=internal
    set diffopt+=indent-heuristic
    set diffopt+=algorithm:histogram
endif

" Perform vertically split diffs by default.
set diffopt+=vertical

" Unfortunately, do to some redirection that Vim uses underneath the hood, it
" can hide an error status of a command.  This helps to preserve the error
" status so v:shell_error and the command can be tested for the success.
if $SHELL =~# "zsh"
    let &shellpipe='2>&1 | tee "%s" ; exit ${pipestatus[1]}'
elseif $SHELL =~# "bash"
    let &shellpipe='2>&1 | tee "%s" ; exit ${PIPESTATUS[0]}'
endif

" -------------------------------------------------------------
" File settings
" -------------------------------------------------------------

" Where file browser's directory should begin:
"   last    - same directory as last file browser
"   buffer  - directory of the related buffer
"   current - current directory (pwd)
"   {path}  - specified directory
" Neovim has not yet implemented this feature.
if exists('+browsedir')
    set browsedir=buffer
endif

" -------------------------------------------------------------
" Display settings
" -------------------------------------------------------------

" Show "ruler" at bottom (cursor position et al.).
set ruler

" Show initial characters of pending incomplete command.
set showcmd

" Use a taller command line to reduce need for pressing ENTER.
set cmdheight=2

" Show a visual bell instead of beeping.
set visualbell

" What to do when opening a new buffer. May be empty or may contain
" comma-separated list of the following words:
"   useopen   - use existing windows if possible.
"   usetab    - like useopen but also checks other tabs
"   split     - split current window before loading a buffer
" 'useopen' may be useful for re-using QuickFix window.
set switchbuf=

" -------------------------------------------------------------
" Setup wrapping for long lines
" -------------------------------------------------------------

" Enable wrapping of long lines.
set wrap

" Use the prompt ">   " for wrapped lines.
let &showbreak="    "

" Break lines at reasonable places instead of mid-word.
set linebreak

" The 'breakat' variable determines good places to break.
" Defaults to line below:
" set breakat=\ \^I!@*-+;:,./?

" How far to scroll sideways when wrapping is off (:set nowrap).
" When zero (the default), will scroll to the middle of the screen.
" May use a small non-zero number for fast terminals.
set sidescroll=0

" Enable 'list' mode (:set list) to see non-visibles a la "reveal codes"
" in the old Word Perfect.  In list mode, 'listchars' indicates
" what to show.  Defaults to "eol:$", but has lots of features
" (see :help 'listchars).
" The "trail" setting means trailing whitespace.
" The feature is too disconcerting to leave on, but pre-configure
" listchars so :set list will do the right thing.
" set list
set listchars=trail:·,nbsp:·,extends:>,precedes:<,eol:$

" -------------------------------------------------------------
" Menu settings
" -------------------------------------------------------------

anoremenu 10.332 &File.Close\ All<Tab>:%bdelete :%bdelete<CR>
anoremenu 10.355 &File.Save\ A&ll<Tab>:wall :wall<CR>

" Configure the use of the Alt key to access menus.
"   no - never use Alt key for menus; all Alt-key combinations are mappable.
"   yes - always use Alt key for menus; cannot map Alt-key combinations.
"   menu - Alt-key combinations not used by menus are mappable.
set winaltkeys=no

" -------------------------------------------------------------
" Key settings
" -------------------------------------------------------------

" Define some convenient mapping commands.
command! -nargs=* -bar Noxmap  nmap <args>|omap <args>|xmap <args>
command! -nargs=* -bar Nxmap  nmap <args>|xmap <args>

" Avoid the following key settings for maximum portability across terminal
" types.  "No codes" means the terminal generates nothing for the given keys.
" "Aliased code" means the key generates the same code as another key, making
" the two keys indistinguishable (and the aliased key useless).
"
" gnome-terminal (TERM=xterm, COLORTERM=gnome-terminal):
" - No codes:
"   <F10>       (reserved for menu)
"   <S-F10>     (reserved for context menu)
"   <S-Home>    (reserved for scrollback)
"   <S-End>     (reserved for scrollback)
"
" Linux console (TERM=linux):
" - No codes:
"   <S-F9>
"   <S-F10>
"   <S-F11>
"   <S-F12>
" - Aliased codes:
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" PuTTY (all except "SCO" mode) (TERM=putty, TERM=putty-256color):
" - Aliased codes:
"   <S-F1>      (same as <F11>)
"   <S-F2>      (same as <F12>)
"   <S-F11>     (same as <F11>)
"   <S-F12>     (same as <F12>)
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" PuTTY "SCO" mode (TERM=putty-sco):
" - Aliased codes:
"   <Delete>    (same as <Backspace>)
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" rxvt (TERM=rxvt, TERM=rxvt-unicode):
" - No codes:
"   <S-Home>    (reserved for scrollback for rxvt-unicode only)
"   <S-End>     (reserved for scrollback for rxvt-unicode only)
" - Aliased codes:
"   <S-F1>      (same as <F11>)
"   <S-F2>      (same as <F12>)

" Undo compiled-in mappings
silent! unmap <C-x>
silent! unmap <C-Del>
silent! unmap <S-Del>
silent! unmap <C-Insert>
silent! unmap <S-Insert>
silent! unmap! <S-Insert>

" Execute "make" in current directory.
nnoremap <F9> :wall<bar>make<CR>
inoremap <F9> <ESC>:wall<bar>make<CR>

" Execute current buffer.
nnoremap <F5> :wall<bar>! %:p<CR>
inoremap <F5> <ESC>:wall<bar>! %:p<CR>

" Return escaped path of directory containing current file.
function! EscapedFileDir()
    return shellescape(expand("%:p:h"))
endfunction

" Signal .fifo using fifosignal script.
nnoremap <F12> :silent! wall<bar>
        \call system("fifosignal " . EscapedFileDir())<CR>
inoremap <F12> <ESC>:wall<bar>call system("fifosignal " . EscapedFileDir())<CR>

" Signal .fifo2 using fifosignal script.
nnoremap <F11> :silent! wall<bar>
        \call system("fifosignal .fifo2")<CR>
inoremap <F11> <ESC>:wall<bar>call system("fifosignal .fifo2")<CR>

" -------------------------------------------------------------
" Support routines
" -------------------------------------------------------------

" Vim 7.4.242 introduced support for the third argument to getreg()
" (which indicates that a list should be returned).  7.4.243 added corresponding
" support to setreg().

if v:version > 704 || v:version == 704 && has("patch242") && has("patch243")
    let g:GetSetRegWithLists = 1
else
    let g:GetSetRegWithLists = 0
endif

" Return regContents=[regValueAsList, regType] for given register reg.
" Note: For Vim versions before 7.4.243 that do not support register values as
" lists, the return value will be [regValueAsString, regType].
function! GetReg(reg)
    if g:GetSetRegWithLists
        let regVal = getreg(a:reg, 1, 1)
    else
        let regVal = getreg(a:reg, 1)
    endif
    return [regVal, getregtype(a:reg)]
endfunction

" Work around bug in setreg() prior to Vim 7.4.725.
" In previous versions, invoking setreg() with an empty list for the value
" would cause an internal error.
function! SetRegWrapper(reg, value, options)
    if g:GetSetRegWithLists && len(a:value) == 0
        call setreg(a:reg, '', a:options)
    else
        call setreg(a:reg, a:value, a:options)
    endif
endfunction

" Set register reg to regContents as returned from GetReg().
" NOTE: Avoids changing the unnamed register '"' when reg != '"' (this is
" an unfortunate side-effect of setting other registers).
function! SetReg(reg, regContents)
    let saveUnnamed = GetReg('"')
    call SetRegWrapper(a:reg, a:regContents[0], a:regContents[1])
    if a:reg != '"'
        call SetRegWrapper('"', saveUnnamed[0], saveUnnamed[1])
    endif
endfunction

" This implements a "stack" for saving values (typically registers).
let s:Stack = []

function! Push(value)
    let s:Stack += [a:value]
endfunction

function! Pop()
    let i = len(s:Stack) - 1
    if i >= 0
        let value = s:Stack[i]
        unlet s:Stack[i]
        return value
    else
        throw 'Stack Underflow'
    endif
endfunction

" Push register 'a' onto stack; must be followed by a subsequent PopA().
function! PushA()
    call Push(GetReg('a'))
endfunction

" Pop register 'a' from stack as pushed by PushA().
function! PopA()
    call SetReg('a', Pop())
endfunction

" Return last visually selected text (as defined by `< and `>).
function! SelectedText()
    call PushA()
    normal! gv"ay
    let text = @a
    call PopA()
    return text
endfunction

" Return true if line is blank (i.e., contains only whitespace).
function! IsBlank(line)
    return a:line =~# '^\s*$'
endfunction

" Indent function that leaves things unchanged.
" Existing (i.e., non-blank) lines keep their current indentation.
" New (blank) lines keep the indentation level of the previous non-blank line.
" Use via:
"   set indentexpr=StatusQuoIndent()
function! StatusQuoIndent()
    " Leave non-blank lines alone at their current indentation.
    let thisLine = getline(v:lnum)
    if !IsBlank(thisLine)
        return indent(thisLine)
    endif

    let lnum = prevnonblank(v:lnum - 1)
    if lnum == 0
        return -1
    endif

    return indent(getline(lnum))
endfunction

function! NumCpus()
    " Mostly taken from:
    "   http://vim.wikia.com/wiki/Auto-detect_number_of_cores_for_parallel_build
    "
    " Tweaked to work for Mac OS X and BSD

    if !empty($NUMBER_OF_PROCESSORS)
        " this works on Windows and provides a convenient override mechanism
        " otherwise
        let n = $NUMBER_OF_PROCESSORS + 0
    elseif filereadable('/proc/cpuinfo')
        " this works on most Linux systems
        let n = system('grep -c ^processor /proc/cpuinfo') + 0
    elseif executable('/usr/sbin/psrinfo')
        " this works on Solaris
        let n = system('/usr/sbin/psrinfo -p') + 0
    elseif executable('/usr/sbin/sysctl')
        " this works on FreeBSD and Mac OS X
        let n = system('/usr/sbin/sysctl -n hw.ncpu') + 0
    else
        " default to single process if we can't figure it out automatically
        let n = 1
    endif

    return n
endfunction

" -------------------------------------------------------------
" Tab page support
" -------------------------------------------------------------

" CTRL-PageUp/CTRL-PageDown are pre-defined to switch between tabs;
" now adding SHIFT will move the current tab.

nnoremap <silent> <C-S-PageUp>   :-tabmove<CR>
nnoremap <silent> <C-S-PageDown> :+tabmove<CR>

" -------------------------------------------------------------
" QuickFix/Location List support
" -------------------------------------------------------------

" Shorten filenames in all buffers.
" E.g., /home/mike/somefile => ~/somefile
function! ShortenFilenames()
    " Using "cd ." (or "lcd .") will cause Vim to invoke internal
    " function shorten_fnames().
    if haslocaldir()
        lcd .
    else
        cd .
    endif
endfunction

" Shorten filenames when QuickFix window changes.
augroup local_QuickFix
    autocmd!
    autocmd QuickfixCmdPost * call ShortenFilenames()
augroup END

" Return 1 if current window is the QuickFix window.
function! IsQuickFixWin()
    if &buftype == "quickfix"
        " This is either a QuickFix window or a Location List window.
        " Try to open a location list; if this window *is* a location list,
        " then this will succeed and the focus will stay on this window.
        " If this is a QuickFix window, there will be an exception and the
        " focus will stay on this window.
        "
        " Unfortunately, the above technique broke with newer versions of Vim
        " as lopen was considered to be editing the buffer.  Instead, we'll use
        " the new win_getid() to grab the window id and then use that to check
        " the window information to see if it's a quickfix window.  The entry
        " 'quickfix' is true for both QuickFix and Location List windows.  The
        " entry 'loclist' is true only for Location List windows.  In addition,
        " the earliest implementations of getwininfo() didn't have these fields,
        " so check their existence before using them.
        if exists('*win_getid') && exists('*getwininfo')
            let info = getwininfo(win_getid())[0]
            if has_key(info, 'quickfix') && has_key(info, 'loclist')
                return info['loclist'] == 0
            endif
        endif

        try
            noautocmd lopen
        catch /E776:/
            " This was a QuickFix window.
            return 1
        endtry
    endif
    return 0
endfunction

" Return 1 if current window is a Location List window.
function! IsLocListWin()
    return (&buftype == "quickfix" && !IsQuickFixWin())
endfunction

" Return window number of QuickFix buffer (or zero if not found).
function! GetQuickFixWinNum()
    let qfWinNum = 0
    let curWinNum = winnr()
    for winNum in range(1, winnr("$"))
        execute "noautocmd " . winNum . "wincmd w"
        if IsQuickFixWin()
            let qfWinNum = winNum
            break
        endif
    endfor
    execute "noautocmd " . curWinNum . "wincmd w"
    return qfWinNum
endfunction

" Return 1 if the QuickFix window is open.
function! QuickFixWinIsOpen()
    return GetQuickFixWinNum() > 0
endfunction

" Return 1 if current window's location list window is open.
function! LocListWinIsOpen()
    let curWinNum = winnr()
    let numOpenWindows = winnr("$")
    " Assume location list window is already open.
    let isOpen = 1
    try
        noautocmd lopen
    catch /E776:/
        " No location list available; nothing was changed.
        let isOpen = 0
    endtry
    if numOpenWindows != winnr("$")
        " We just opened a new location list window.  Revert to original
        " window and close the newly opened window.
        noautocmd wincmd p
        noautocmd lclose
        let isOpen = 0
    endif
    return isOpen
endfunction

" Open Quickfix window.
"   If already open, leave size alone; otherwise, open with standard size.
function! Copen()
    if QuickFixWinIsOpen()
        copen
    else
        execute "silent botright copen " . g:QuickFixWinHeight
    endif
endfunction

" Open QuickFix window using standard position and height.
command! -bar Copen  call Copen()

" Open Location List window.
"   If already open, leave size alone; otherwise, open with standard size.
function! Lopen()
    if LocListWinIsOpen()
        lopen
    else
        execute "silent lopen " . g:LocListWinHeight
    endif
endfunction

" Open Location List window using standard height.
command! -bar Lopen  call Lopen()

" Return 1 is location list is "preferred" to QuickFix list.
function! LocListIsPreferred()
    let locOpen = LocListWinIsOpen()
    let qfOpen = QuickFixWinIsOpen()

    " Prefer open windows to closed windows;
    " Otherwise, prefer the location list if it is non-empty;
    " Otherwise, use the QuickFix list.
    if locOpen != qfOpen
        let useLocList = locOpen
    else
        let useLocList = len(getloclist(0)) > 0
    endif
    return useLocList
endfunction

" Goto previous or next QuickFix or Location List message.
"   messageType = "c" (for QuickFix) or "l" (for Location List).
"   whichMessage = "previous" or "next".
" Return 1 on successful move.
function! GotoMessage(messageType, whichMessage)
    try
        execute a:messageType . a:whichMessage
    catch /:E42:\|:E553:/
        try
            " We've run out of messages in this direction, so close the
            " QuickFix window for convenience.
            execute a:messageType . 'close'
            execute a:messageType . a:messageType
        catch /:E16:\|:E42:\|:E553:/
            " E16 is "Invalid range".  This surprising error is thrown when the
            " command ``:cc`` is executed when the QuickFix list has never been
            " populated.
            let typeName = (a:messageType == 'c') ? "QuickFix" : "Location List"
            echo "No " . a:whichMessage . " " . typeName . " message"
            return 0
        endtry
    endtry
    " Echo empty line to clear possible previous message.
    echo ""
    normal zz
    return 1
endfunction

" Goto previous "thing" (diff, Location List message, QuickFix message).
function! GotoPrev()
    if &diff
        normal [czz
    elseif LocListIsPreferred()
        call GotoMessage("l", "previous")
    else
        call GotoMessage("c", "previous")
    endif
endfunction

" Goto next "thing" (diff, Location List message, QuickFix message).
function! GotoNext()
    if &diff
        normal ]czz
    elseif LocListIsPreferred()
        call GotoMessage("l", "next")
    else
        call GotoMessage("c", "next")
    endif
endfunction

" Setup previous/next browsing using F4/Shift-F4.
inoremap <silent> <F4> <C-o>:call GotoNext()<CR>
nnoremap <silent> <F4>      :call GotoNext()<CR>
inoremap <silent> <S-F4> <C-o>:call GotoPrev()<CR>
nnoremap <silent> <S-F4>      :call GotoPrev()<CR>

function! s:Qf2Args()
    let l:files={}
    argdo argdelete %
    for l:lineDict in getqflist()
        if l:lineDict.bufnr > 0
            let l:files[bufname(l:lineDict.bufnr)]=1
        endif
    endfor
    for l:file in keys(l:files)
        execute "silent argadd " . l:file
    endfor
endfunction

command! -bar Qf2Args call s:Qf2Args()

" Setup n and N for browsing to next or previous search match with automatic
" scrolling to the center of the window.
" Unfortunately, the ``zz`` cancels the message ``[n/m]`` that gets echoed when
" 'shortmess' does not contain ``S``.  To restore that, move back (or
" forward) one character and repeat the ``n`` (or ``N``) operation.
nnoremap n      nzz<BS>n
nnoremap N      Nzz<Space>N

" Move current line up one line (called from normal mode)
function! NMoveUp()
    if line(".") > 1
        let curCol = virtcol('.')
        move .-2
        exe ':silent normal ' . curCol . '|'
    endif
endfunction

" Move current line down one line (called from normal mode)
function! NMoveDown()
    if line(".") < line("$")
        let curCol = virtcol('.')
        move .+1
        exe ':silent normal ' . curCol . '|'
    endif
endfunction

" Move visual range up one line (called from normal mode)
function! VMoveUp()
    if line("'<") > 1
        silent '<,'>move '<-2
    endif
    " restore visual selection
    silent normal! gv
endfunction

" Move visual range down one line (called from normal mode)
function! VMoveDown()
    if line("'>") < line("$")
        silent '<,'>move '>+1
    endif
    " restore visual selection
    silent normal! gv
endfunction

nnoremap <silent> <M-Up>   :call NMoveUp()<CR>
nnoremap <silent> <M-Down> :call NMoveDown()<CR>
nnoremap <silent> <M-k>    :call NMoveUp()<CR>
nnoremap <silent> <M-j>    :call NMoveDown()<CR>

inoremap <silent> <M-Up>   <C-\><C-o>:call NMoveUp()<CR>
inoremap <silent> <M-Down> <C-\><C-o>:call NMoveDown()<CR>
inoremap <silent> <M-k>    <C-\><C-o>:call NMoveUp()<CR>
inoremap <silent> <M-j>    <C-\><C-o>:call NMoveDown()<CR>

xnoremap <silent> <M-Up>   <C-c>:call VMoveUp()<CR>
xnoremap <silent> <M-Down> <C-c>:call VMoveDown()<CR>
xnoremap <silent> <M-k>    <C-c>:call VMoveUp()<CR>
xnoremap <silent> <M-j>    <C-c>:call VMoveDown()<CR>
xnoremap <silent> -        <C-c>:call VMoveUp()<CR>
xnoremap <silent> +        <C-c>:call VMoveDown()<CR>

" Invoke as:
"   WithShiftWidth(1, "normal gv<gv")
"   WithShiftWidth(1, ":'<,'>>")
function! WithShiftWidth(shiftWidth, toExec)
    let save_sw = &sw
    let &sw = a:shiftWidth
    execute a:toExec
    let &sw = save_sw
endfunction

" Derived from John Little's Vbs() function, posted in vim_use
" 9/8/2010 with Subject "Re: formating".
function! VMoveLeft()
    if visualmode() == "\<C-v>"
        let s = getpos("'<")
        let e = getpos("'>")
        let fl = min([s[1], e[1]])
        let fc = min([s[2], e[2]])
        let ll = max([s[1], e[1]])
        let lc = max([s[2] + s[3], e[2] + e[3]])
        let save_virtualedit = &virtualedit
        let &virtualedit = "all"
        call setpos(".", [0, fl, lc - (lc == 1 ? 0 : 1), 0])
        execute "normal \<C-v>"
        call setpos(".", [0, ll, lc - (lc == 1 ? 0 : 1), 0])
        normal x
        call setpos(".", [0, fl, fc - (fc == lc && fc != 1 ? 1 : 0), 0])
        execute "normal \<C-v>"
        call setpos(".", [0, ll, lc - (fc == lc && lc == 1 ? 0 : 1), 0])
        let &virtualedit = save_virtualedit
    else
        call WithShiftWidth(1, ":'<,'><")
        normal gv
    endif
endfunction

function! VMoveRight()
    if visualmode() == "\<C-v>"
        execute "normal gvI\<Space>\<esc>"
        normal gvl
    else
        call WithShiftWidth(1, ":'<,'>>")
        normal gv
    endif
endfunction

nnoremap <silent> <M-Left>     :call WithShiftWidth(1, ":<")<CR>
nnoremap <silent> <M-Right>    :call WithShiftWidth(1, ":>")<CR>
nnoremap <silent> <M-h>        :call WithShiftWidth(1, ":<")<CR>
nnoremap <silent> <M-l>        :call WithShiftWidth(1, ":>")<CR>

inoremap <silent> <M-Left>     <C-\><C-o>:call WithShiftWidth(1, ":<")<CR>
inoremap <silent> <M-Right>    <C-\><C-o>:call WithShiftWidth(1, ":>")<CR>
inoremap <silent> <M-h>        <C-\><C-o>:call WithShiftWidth(1, ":<")<CR>
inoremap <silent> <M-l>        <C-\><C-o>:call WithShiftWidth(1, ":>")<CR>

xnoremap <silent> <M-Left>     <C-c>:call VMoveLeft()<CR>
xnoremap <silent> <M-Right>    <C-c>:call VMoveRight()<CR>
xnoremap <silent> <M-h>        <C-c>:call VMoveLeft()<CR>
xnoremap <silent> <M-l>        <C-c>:call VMoveRight()<CR>

" Strip whitespace from the left.
function! Lstrip(s)
    return substitute(a:s, '^\s\+', '', "")
endfunction

" Strip whitespace from the right.
function! Rstrip(s)
    return substitute(a:s, '\s\+$', '', "")
endfunction

" Truncate string to at most length characters.
function! TruncStr(str, length)
    if len(a:str) < a:length
        return a:str
    elseif a:length > 0
        return a:str[:(a:length - 1)]
    else
        return ''
    endif
endfunction

" Return leading whitespace characters for string.
function! LeadingWhitespace(str)
    let remaining = Lstrip(a:str)
    let whiteLen = len(a:str) - len(remaining)
    return TruncStr(a:str, whiteLen)
endfunction

" Return longest common prefix of two strings s1 and s2.
function! CommonPrefix(s1, s2)
    let i = 0
    while i < len(a:s1) && i < len(a:s2) && a:s1[i] == a:s2[i]
        let i += 1
    endwhile
    return TruncStr(a:s1, i)
endfunction

" Given a paragraph (string with embedded newlines), remove the largest common
" whitespace prefix from each line.
function! DedentParagraph(para)
    " Track trailing newline separately, since we allow split() to remove it.
    if a:para =~# '\n$'
        let finalNewline = "\n"
    else
        let finalNewline = ''
    endif
    let lines = split(a:para, "\n")
    let nonEmptyLines = filter(copy(lines), 'v:val !~# ''^\s*$''')
    if len(nonEmptyLines) > 0
        let prefixes = map(copy(nonEmptyLines), 'LeadingWhitespace(v:val)')
        let longestPrefix = prefixes[0]
        let i = 1
        while i < len(prefixes)
            let longestPrefix = CommonPrefix(longestPrefix, prefixes[i])
            let i = i + 1
        endwhile
        let skipLen = len(longestPrefix)
        call map(lines, 'v:val[skipLen:]')
    endif
    return join(lines, "\n") . finalNewline
endfunction

" Yank-related mappings.

" Yank to end-of-line instead of entire line (use "yy" for yanking a line).
nnoremap <silent> Y      y$

" Yank and dedent the visual selection.
" TODO For now, assumes yanking to register 0 and that * and + are destinations.
" Someday this should take into account the actual destination register and
" whether such a yank should influence the clipboard.
xnoremap <silent> Y y:let @0=DedentParagraph(@0)<CR>:let @+=@0<CR>:let @*=@0<CR>


" Remove "rubbish" whitespace (from Andy Wokula posting).

nnoremap <silent> drw :<C-u>call DeleteRubbishWhitespace()<CR>

function! DeleteRubbishWhitespace()
    " Reduce many spaces or blank lines to one.
    let saveVirtualEdit = [&virtualedit]
    set virtualedit=
    let line = getline(".")
    if line =~ '^\s*$'
        let savePos = winsaveview()
        let saveFoldEnable = &foldenable
        setlocal nofoldenable
        normal! dvip0D
        let savePos.lnum = line(".")
        let &l:foldenable = saveFoldEnable
        call winrestview(savePos)
    elseif line[col(".")-1] =~ '\s'
        normal! zvyiw
        if @@ != " "
            normal! dviwr m[
            " m[ is just to avoid a trailing space
        endif
    endif
    let [&ve] = saveVirtualEdit
    silent! call repeat#set("drw")
endfunction

function! StripTrailingWhitespace()
    let savePos = winsaveview()
    let saveFoldEnable = &foldenable
    setlocal nofoldenable
    %substitute /\s\+$//ge
    let &l:foldenable = saveFoldEnable
    call winrestview(savePos)
endfunction
command! -bar StripTrailingWhitespace  call StripTrailingWhitespace()

nnoremap <Leader><Leader>$  :StripTrailingWhitespace<CR>
Noxmap   <Space>xdw         :StripTrailingWhitespace<CR>


" Remap Q from useless "Ex" mode to "gq" re-formatting command.
nnoremap Q gq
xnoremap Q gq
onoremap Q gq

" Paragraph re-wrapping, similar to Emacs's Meta-Q and TextMate's Ctrl-Q.
function! RewrapParagraphExpr()
    if &tw == 0
        " Mark position, join lines, return to marked position.
        return "m`vip:join\<CR>``"
    elseif &formatexpr == '' && &formatprg == ''
        " Using internal algorithm.  Use ``gwip`` which correctly leaves the
        " cursor unmoved.
        return 'gwip'
    else
        " Not using internal algorithm.  Preserving the cursor position is
        " too hard (marks can disappear, and even when they don't the marked
        " position isn't very correct).  Since external algorithm use isn't very
        " common, we don't bother trying to preserve the cursor position.
        return 'gqip'
    endif
endfunction

function! RewrapParagraphExprVisual()
    return (&tw > 0 ? "gq"   :    ":join\<CR>") . "$"
endfunction

function! RewrapParagraphExprInsert()
    " Include undo point via CTRL-g u.
    return "\<C-g>u\<Esc>" . RewrapParagraphExpr() . "a"
endfunction

nnoremap <expr> <M-q>      RewrapParagraphExpr()
nnoremap <expr> <Leader>q  RewrapParagraphExpr()
xnoremap <expr> <M-q>      RewrapParagraphExprVisual()
xnoremap <expr> <Leader>q  RewrapParagraphExprVisual()
inoremap <expr> <M-q>      RewrapParagraphExprInsert()

function! ClosestPos(positions)
    let closestLine = 0
    let closestCol = 0
    for p in a:positions
        if p[0] > 0
            if closestLine == 0 || closestLine > p[0] ||
                    \ (closestLine == p[0] && closestCol > p[1])
                let closestLine = p[0]
                let closestCol = p[1]
            endif
        endif
    endfor
    return [closestLine, closestCol]
endfunction

function! ClosestCurly()
    return searchpairpos('{', '\<break\s*\zs;', '}', 'nW')
endfunction

function! ClosestParen()
    return searchpairpos('(', '', ')', 'nW')
endfunction

function! ClosestBracket()
    return searchpairpos('[', '', ']', 'nW')
endfunction

function! MoveTo(position)
    if a:position[0] > 0
        exec "normal " . a:position[0] . "gg"
        exec "normal " . a:position[1] . "|"
    endif
endfunction

function! MoveToClosest()
    call MoveTo(ClosestPos([ClosestCurly(), ClosestParen(), ClosestBracket()]))
endfunction

" Go "out" to the next closest containing thingy.
inoremap <silent> <C-o><C-o>  <ESC>:call MoveToClosest()<CR>a
vnoremap <silent> <C-o><C-o>  <ESC>:call MoveToClosest()<CR>a

" Map CTRL-o o in visual modes to be the same as in insert mode
" (which opens a new line below this one even when currently mid-line).
vnoremap <silent> <C-o>o  <ESC>o

" Append ;<CR> to current line.
inoremap <silent> <C-o>;  <ESC>A;<CR>
vnoremap <silent> <C-o>;  <ESC>A;<CR>

" Append :<CR> to current line.
inoremap <silent> <C-o>:  <ESC>A:<CR>
vnoremap <silent> <C-o>:  <ESC>A:<CR>

" Append .<CR> to current line.
inoremap <silent> <C-o>.  <ESC>A.<CR>
vnoremap <silent> <C-o>.  <ESC>A.<CR>

" Append .<CR> to current line unless overridden by filetype-specific mapping.
inoremap <silent> <C-o><CR>  <ESC>A.<CR>
vnoremap <silent> <C-o><CR>  <ESC>A.<CR>

" To leave Visual or Select mode at start or end of selected text.
snoremap <silent> <C-o><C-h> <C-g>o<C-\><C-n>i
xnoremap <silent> <C-o><C-h>      o<C-\><C-n>i
vnoremap <silent> <C-o><C-l>       <C-\><C-n>a

" Strip whitespace left of cursor (only if non-blank at or after cursor).
function! StripWhiteLeftOfCursor()
    let c = col(".")
    if c > 1
        let s = getline(line("."))
        let unstrippedLeftS = s[0 : c-2]
        let leftS = Rstrip(unstrippedLeftS)
        let rightS = s[c - 1 : ]
        if leftS != unstrippedLeftS && !IsBlank(rightS)
            " Setting left-side first brings cursor over as needed.
            call setline(line("."), leftS)
            call setline(line("."), leftS . rightS)
        endif
    endif
    " Return empty string so it may be called from insert mode via <C-r>=.
    return ""
endfunction

" Use <C-r>=FunctionCall()<CR> idiom to avoid leaving insert mode.  Using
" <C-o>:call FunctionCall()<CR> clobbers the virtual indentation that gets
" added as part of automatic indentation.
" Avoid remapping this because the "endwise" plugin will append to this
" definition when it loads, and after a :source of this file, an unconditional
" :inoremap disables endwise's hook.
if !hasmapto('<CR>', 'i')
    inoremap <CR>  <C-r>=StripWhiteLeftOfCursor()<CR><CR>
endif


" Move vertically by screen lines instead of physical lines.
" Exchange meanings for physical and screen motion keys.

" When the popup menu is visible (pumvisible() is true), the up and
" down arrows should not be mapped in order to preserve the expected
" behavior when navigating the popup menu.  See :help ins-completion-menu
" for details.

" Down
nnoremap j           gj
xnoremap j           gj
nnoremap <Down>      gj
xnoremap <Down>      gj
inoremap <silent> <Down> <C-r>=pumvisible() ? "\<lt>Down>" : "\<lt>C-o>gj"<CR>
nnoremap gj          j
xnoremap gj          j

" Up
nnoremap k           gk
xnoremap k           gk
nnoremap <Up>        gk
xnoremap <Up>        gk
inoremap <silent> <Up>   <C-r>=pumvisible() ? "\<lt>Up>" : "\<lt>C-o>gk"<CR>
nnoremap gk          k
xnoremap gk          k

" Start of line
nnoremap 0           g0
xnoremap 0           g0
nnoremap g0          0
xnoremap g0          0
nnoremap ^           g^
xnoremap ^           g^
nnoremap g^          ^
xnoremap g^          ^

" End of line
nnoremap $           g$
xnoremap $           g$
nnoremap g$          $
xnoremap g$          $

" Navigate conflict markers.
function! GotoConflictMarker(direction, beginning)
    if a:beginning
        call search('^<\{7}<\@!', a:direction ? 'W' : 'bW')
    else
        call search('^>\{7}>\@!', a:direction ? 'W' : 'bW')
    endif
endfunction

nnoremap [n :call GotoConflictMarker(0, 1)<CR>
nnoremap [N :call GotoConflictMarker(0, 0)<CR>
nnoremap ]n :call GotoConflictMarker(1, 1)<CR>
nnoremap ]N :call GotoConflictMarker(1, 0)<CR>

" Command-line editing.
" To match Bash, setup Emacs-style command-line editing keys.
" This loses some Vim functionality.  The original functionality can
" be had by pressing CTRL-o followed by the original key.  E.g., to insert
" all matching filenames (originally <C-a>), do <C-o><C-a>.
cnoremap <C-a>      <Home>
cnoremap <C-b>      <Left>
cnoremap <C-d>      <Del>
cnoremap <C-f>      <Right>
cnoremap <C-n>      <Down>
cnoremap <C-p>      <Up>
cnoremap <M-b>      <S-Left>
cnoremap <M-f>      <S-Right>

cnoremap <C-o><C-a> <C-a>
cnoremap <C-o><C-b> <C-b>
cnoremap <C-o><C-d> <C-d>
cnoremap <C-o><C-f> <C-f>
cnoremap <C-o><C-n> <C-n>
cnoremap <C-o><C-p> <C-p>

" Original meanings:
" <C-a>   Insert all matching filenames.
" <C-b>   <Home>.
" <C-d>   List matching names
" <C-f>   Edit command-line history.
" <C-n>   Next match after wildchar, or recall next command-line history.
" <C-o>   Nothing.
" <C-p>   Prev. match after wildchar, or recall prev. command-line history.

function! RefreshScreen()
    if &diff
        diffupdate
    endif
endfunction
command! RefreshScreen :call RefreshScreen()
nnoremap <silent> <C-l> :RefreshScreen<CR>:nohlsearch<CR><C-l>

" Work-around slow pasting to command-line; avoid a command-line
" re-draw on every character entered by turning off Arabic shaping
" (which is reportedly poorly implemented).
if has("arabic")
    set noarabicshape
endif

" =============================================================
" Behavior
" =============================================================

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

" Use Visual mode and avoid "Select" mode.
set selectmode=

" Don't move to start-of-line on page up/down, H, M, L, gg, G, etc.
set nostartofline

" Right-click sets cursor position and pop up a menu.
set mousemodel=popup_setpos
" @todo Setup the menu that pops up.

" With 'startsel' included, shifted "special" keys (arrows, home, end,
" page up/down) start a selection.
" With 'stopsel' included, unshifted "special" keys stop a selection.
set keymodel=startsel

" 'inclusive' indicates to include the last character in a selection.
" 'exclusive' excludes the final character in a selection.
set selection=inclusive

" Allow left/right movement keys to "wrap" to the previous/next line.
" b - backspace key
" s - space key
" h - "h" (not recommended)
" l - "l" (not recommended)
" ~ - "~"
" < - left arrow  (normal and visual modes)
" > - right arrow (normal and visual modes)
" [ - left arrow  (insert and replace modes)
" ] - right arrow (insert and replace modes)
set whichwrap=b,s,<,>,[,]

" Keep `signcolumn` on all the time, rather than allow it to disconcertingly
" come and go as errors are detected.  Make this independent of ALE or other
" plugins.
if exists('&signcolumn')
    set signcolumn=yes
endif

" Setup command-line completion (inside of Vim's ':' command line).
" Controlled by two options, 'wildmode' and 'wildmenu'.
" `wildmode=full` completes the full word
" `wildmode=longest` completes the longest unambiguous substring
" `wildmode=list` lists all matches when ambiguous
" When more than one mode is given, tries first mode on first keypress,
" and subsequent modes thereafter.
" `wildmode=longest,list` matches longest unambiguous, then shows list
"   of matches on next keypress if match didn't grow longer.
" If wildmenu is set, it will be used only when wildmode=full.

set wildmode=longest,list

" Notes about 'wildignore' patterns:
" - ``*`` matches directory characters (unlike for shell); there is no ``**``.
"
" - A pattern without a slash will be compared against basename; with a slash,
"   it will be compared against the expanded (absolute) path.  So in the absence
"   of a slash in the pattern, ``*`` will never be presented a slash character
"   to match against, which makes ``*`` equivalent to what the shell provides in
"   this specific case.
" - To prevent descent into a directory named DIRNAME, it is sufficient to
"   use the bare name DIRNAME (without slashes or asterisks).  This allows
"   the user to explicitly visit paths within DIRNAME if desired, e.g., with
"   a directory named 'top' containing only 'DIRNAME/somefile', then:
"
"     echo glob('top/*') -> returns nothing
"     echo glob('top/DIRNAME/*') -> returns /.../top/DIRNAME/somefile
"
" - To permanently ban DIRNAME from appearing as a directory component in a
"   longer path, use '*/DIRNAME/*', but note that it won't match the directory
"   DIRNAME itself (with no following slash); for that, you must use a bare
"   DIRNAME in addition, e.g.::
"
"     set wildignore=DIRNAME,*/DIRNAME/*
"
"   Generally, just using the bare DIRNAME is preferred.

" Setup 'wildignore' property.  This is used for many kinds of filename matching
" in Vim.  In particular, it's used by some VCS plugins to detect the presence
" of .git/.hg/etc directories, so those directories shouldn't be ignored using
" 'wildignore'.

" *NOTE* When changing 'wildignore' below, consider making corresponding changes
" to $VIMFILES/etc/agignore.

" Ignore some Vim-related artifacts.
set wildignore+=*.swp,tags,cscope.out

" Ignore common file backup extensions.
set wildignore+=*~,*.bak

" Ignore some binary build artifacts for Unix.
set wildignore+=*.o,*.a,*.so,*.elf

" Ignore some binary build artifacts for Windows.
set wildignore+=*.obj,*.lib,*.exe,*.opt,*.ncb,*.plg,*.ilk

" Ignore some build-related directories.
set wildignore+=build,_build,export,pkgexp

" Ignore some Python artifacts.
set wildignore+=*.pyc,*.egg-info

" Ignore some Linux-kernel artifacts.
set wildignore+=*.ko,*.mod.c,*.order,modules.builtin

" Ignore some Java and Clojure-related files.
set wildignore+=*.class,classes,*.jar,.lein-*

" Ignore debug symbols on Mac OS X.
set wildignore+=*.dSYM

" Ignore Rust target/ directory.
set wildignore+=target

" Ignore Meson build-related directories:
set wildignore+=builddir,bindir,subprojects

" Ignore Python virtual environments:
set wildignore+=venv

" Want sessionoptions to contain:
"   blank - save unnamed buffers.
"   buffers - save buffers.
"   curdir - save current directory.
"   folds - any manually set folds.
"   help - any open help windows.
"   resize - restore lines, columns.
"   slash - replace backslashes with forward slashes in file names.
"   tabpages - all tabpages at once.
"   unix - save session file in Unix line endings.
"   winpos - position of entire Vim window.
"   winsize - sizes of windows.
"
" Don't want:
"   localoptions - all local options.
"   options - all global options.
"   sesdir - change directory to that of the session file.

set sessionoptions=blank,buffers,curdir,folds,help,resize,slash
        \,tabpages,unix,winpos,winsize


" Setup undofile capability if available.
if has('persistent_undo')
    if !exists('g:UndoDirectory')
        let s:oldUndoDirectory = expand('$VIMFILES/.undo')
        if has('nvim-0.5')
            " New undofile format in https://github.com/neovim/neovim/pull/13973
            " (f42e932, 2021-04-13).
            let g:UndoDirectory = expand('$VIM_CACHE_DIR/undo2')
        elseif isdirectory(s:oldUndoDirectory)
            let g:UndoDirectory = s:oldUndoDirectory
        else
            let g:UndoDirectory = expand('$VIM_CACHE_DIR/undo')
        endif
    endif
    if !isdirectory(g:UndoDirectory)
        silent! call mkdir(g:UndoDirectory, 'p')
    endif
    let &undodir=g:UndoDirectory
    set undofile
endif

" -------------------------------------------------------------
" Completion
" -------------------------------------------------------------

" Complete longest unambiguous match, show menu even if only one match.
" Include extra "preview" information in menu.
" menu - use a popup menu to show completions.
" menuone - use menu even when only one match.
" longest - only insert longest common text of matches.
" preview - use preview window to show extra information.
" noinsert - do not insert text until the user selects from menu.
" noselect - force the user to select from the menu.
set completeopt=menu,menuone

if (v:version == 704 && has('patch775')) || v:version > 704
    set completeopt+=noselect,noinsert
endif

" 'complete' controls which types of completion may be initiated by
" pressing CTRL-n and CTRL-p.
" . - Scans current buffer.
" w - Scans buffers from other windows.
" b - Scans loaded buffers in the buffer list.
" u - Scans unloaded buffers in the buffer list.
" U - Scans buffers not in the buffer list.
" k - Scans the files given with the 'dictionary' option.
" kspell - Use the active spell checking.
" k{dict} - Scan the file {dict}.
" s - Scan the files given with the 'thesaurus' option.
" s{tsr} - Scan the file {tsr}.
" i - Scan current and included files.
" d - Scan current and included files for a defined name or macro.
" ] - Tag completion.
" t - Same as "]".
" Default: .,w,b,u,t,i

set complete=.,w,b,u,t

" -------------------------------------------------------------
" Begin "inspired by mswin.vim"
" -------------------------------------------------------------

" Backspace in Visual mode does NOT delete selection (used for
" shifting left).

" SHIFT-Del is Cut
nnoremap <S-Del>            "+dd
vnoremap <S-Del>            "+d
inoremap <S-Del>            <C-o>"+dd

" CTRL-Insert is Copy
nnoremap <C-Insert>         "+yy
vnoremap <C-Insert>         "+y
inoremap <C-Insert>         <C-o>"+yy

" SHIFT-Insert is Paste
" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.

nnoremap <S-Insert>         "+gP
exe 'vnoremap <script> <S-Insert>' paste#paste_cmd['v']
exe 'inoremap <script> <S-Insert>' paste#paste_cmd['i']
cnoremap <S-Insert>         <C-r>+

" CTRL-SHIFT-Insert is Paste from primary selection ("* register)
nnoremap <C-S-Insert>       "*gP
vnoremap <C-S-Insert>       "*gP
inoremap <C-S-Insert>       <C-\><C-o>"*gP
cnoremap <C-S-Insert>       <C-r>*

" Perform "undo" operation via Alt-Z, remaining in original mode if possible.
nnoremap <M-z>  u
vnoremap <M-z>  <ESC>ugv
inoremap <M-z>  <C-o>u

" Use <M-u><M-u> as an alias for "undo", as it's intended as an
" easier-to-remember, easier-to-type alternative.
nnoremap <M-u><M-u>  u
vnoremap <M-u><M-u>  <ESC>ugv
inoremap <M-u><M-u>  <C-o>u

nmap <M-x>      <S-Del>
vmap <M-x>      <S-Del>
imap <M-x>      <S-Del>
nmap <M-c>      <C-Insert>
vmap <M-c>      <C-Insert>
imap <M-c>      <C-Insert>
nmap <M-v>      <S-Insert>
vmap <M-v>      <S-Insert>
imap <M-v>      <S-Insert>
noremap  <M-a>      ggVG
inoremap <M-a> <ESC>ggVG

" Mapping M-a separately for visual and select modes to always end up
" in visual mode; otherwise, with a single :vnoremap, pressing M-a in
" select mode selects all but switches back to select mode when done.
snoremap <M-a> <ESC>ggVG
xnoremap <M-a> <ESC>ggVG

" On Windows, Alt-Space brings up system menu.
if has("win32")
    nnoremap <M-Space> :simalt ~<CR>
endif

" -------------------------------------------------------------
" End "inspired by mswin.vim"
" -------------------------------------------------------------

" -------------------------------------------------------------
" Window-related mappings
" -------------------------------------------------------------

" Map window-related operations that start with CTRL-w onto equivalents
" starting with <Space>w.
nmap     <Space>w           <C-w>

" -------------------------------------------------------------
" Miscellaneous mappings
" -------------------------------------------------------------

" Visually select the text that was last edited/pasted.
nnoremap gV `[v`]

" Break undo for some insert-mode deletion operations otherwise, an undo will
" just remove all text from the current insert operation instead of bringing
" back the deleted text.
inoremap <C-w>  <C-g>u<C-w>
inoremap <C-u>  <C-g>u<C-u>

" Put from most recent yank instead of scratch register.
xnoremap P "0P

" =============================================================
" Search-related configuration
" =============================================================

" Enable incremental searching (searching as you type).
set incsearch

" Make searching case-insensitive, but enable "smartcase" that will
" turn case sensitivity back on when uppercase letters are present.
" (Note: Use \C in pattern to force case sensitivity again.)
set ignorecase
set smartcase

" For tag lookup, the default is `tagcase=followic`, meaning it follows the
" `ignorecase` setting.  But generally tag lookup shouldn't ignore case, as most
" of the time tags are looked up by pointing the cursor on a tag and pressing
" CTRL-].  When case is ignored, the binary search optimization for sorted
" tagfiles can't be done, and tag searches with large `tags` files are very
" slow.
"
" Note that using a regular expression for tag lookup causes the `ignorecase`
" setting to be honored again.  So:
"
"   " `sometag` must match the case exactly:
"   :tag sometag
"
"   " `sometag` is treated like a regex, so it matches case-insensitively.
"   " Note that this is a substring match as well, so it would match
"   " `anothersometag` as well:
"   :tag /sometag

" Require case-sensitive matching for tags:
if exists('&tagcase')
    set tagcase=match
endif

" Do not wrap around buffer when searching.
set nowrapscan

" Trivial file completion implementation.  It's not as good as the built-in
" "file" completion option, but it will not muck with the command string.  The
" built-in file completion ("-complete=file") does these undesirable things:
" - Always expands certain special strings unless they are backslash-escaped,
"   even if they are inside shell quotes (e.g., $ENVIRONMENT_VARIABLES,
"   characters such as '%' and '#', `backticks`, etc.).
" - Uses backslashes to escape spaces in filenames even though that's not useful
"   with system() on Windows.
" Unfortunately, it's not possible to replicate the good features of the
" built-in file completion using ``-complete=customlist``, since Vim will always
" generate the "argLead" argument based on its own model of generic argument
" splitting.  Therefore, when the user types "some/path/<Tab>", the list
" of completions will always have "some/path/" at the start (e.g.,
" "some/path/file1", "some/path/file2", etc.), unlike the built-in completion
" that knows to start the effective "argLead" value after the final path
" separator yielding shorter completions (e.g., "file1", "file2", etc.).  Fixing
" this would require changes to the core Vim completion model.
function! FileCompleteList(argLead, cmdLine, cursorPos)
    let pathsep = '/'
    if exists("+shellslash") && !&shellslash
        let pathsep = '\'
    endif
    let comps = glob(a:argLead . '*', 0, 1)
    call map(comps,'isdirectory(v:val) ? v:val . pathsep : v:val')
    return sort(comps)
endfunction

" =============================================================
" findx-related commands
" =============================================================

function! GrepperWrapper(tool, query)
    Copen
    execute 'Grepper -noprompt -noopen -tool ' . a:tool . ' -query ' . a:query
endfunction

command! -nargs=* -complete=customlist,FileCompleteList Findx
        \ call GrepperWrapper('findx', <q-args> == '' ? '.' : <q-args>)
command! -nargs=* -complete=customlist,FileCompleteList FFX
        \ call GrepperWrapper('ffx', <q-args> == '' ? '.' : <q-args>)
command! -nargs=+ -complete=customlist,FileCompleteList FFG
        \ call GrepperWrapper('ffg', '-n ' . <q-args>)

" =============================================================
" ack utility
" =============================================================

" Default to using "ack" from vimfiles, as we aim to keep it at least as
" up-to-date as any system-provided "ack" executable.  This will avoid picking
" up old 1.x versions of "ack" that might be found on the system.
if !exists('g:UseSystemAck')
    if executable('perl') == 1 && g:PythonExecutable != ''
        " We've got enough to reliably use the "ack" in vimfiles.
        let g:UseSystemAck = 0
    else
        " Better use the system-supplied ack.
        " TODO: Should allow for "perl without python, no system ack" case.
        let g:UseSystemAck = 1
    endif
endif

if !exists('g:AckExecutable')
    let g:AckExecutable = ''
    if g:UseSystemAck
        if executable('ack') == 1
            let g:AckExecutable = 'ack'
        elseif executable('ack-grep') == 1
            let g:AckExecutable = 'ack-grep'
        endif
    elseif executable('perl') == 1
        " Use the "ack" executable shipped in vimfiles.  Strawberry Perl and
        " ActivePerl both have problems with certain arguments containing
        " quotes.  A work-around is to chain through Python (which parses these
        " quoted arguments correctly), as long as Python is available.
        " Without Python, the following invocation of :Ack::
        "   :Ack "x = ""hello"";"
        " fails to match this line::
        "   x = "hello";
        " With the Python work-around, the invocation works.
        if g:PythonExecutable != ''
            let g:AckExecutable = g:PythonExecutable . ' '
                    \ . $VIMFILES . '/tool/execargs.py '
        else
            let g:AckExecutable = ''
        endif
        let g:AckExecutable .= 'perl ' . $VIMFILES . '/tool/ack'
    endif
endif

" =============================================================
" Grep tool
" =============================================================

if !exists('g:DefaultGrepTool')
    if executable('rg') == 1
        let g:DefaultGrepTool = 'rg'
    elseif executable('ag') == 1
        let g:DefaultGrepTool = 'ag'
    elseif executable('ffg') == 1
        let g:DefaultGrepTool = 'ffg'
    elseif g:AckExecutable != ''
        let g:DefaultGrepTool = 'ack'
    else
        let g:DefaultGrepTool = ''
    endif
endif

" Run "best" full-featured grep tool.
function! RunGrep(args)
    " Invoke indirectly in case of a raised exception; without this, our
    " "endif" below gets skipped when an exception occurs.
    if g:DefaultGrepTool != ''
        Copen
        execute 'Grepper -noprompt -noopen -tool ' . g:DefaultGrepTool
                \ . ' -query ' . a:args
    else
        throw 'Grep Tool unavailable'
    endif
endfunction

" Run "best" grep tool against arguments.
command! -nargs=* -complete=customlist,FileCompleteList G
        \ call RunGrep(<q-args>)

" =============================================================
" Search naming conventions
" =============================================================

" "Search" is for built-in Vim search like :vimgrep.
" "Grep" is the common dialect in many tools (ag, ack, rg, perl, ...).
" "Posix" is POSIX regular expressions.
" "Egrep" is POSIX extended regular expressions as found in egrep.

" Escape chars in str, then replace newlines with '\n'.
function! EolEscape(str, chars)
    return substitute(escape(a:str, a:chars), '\n', '\\n', 'g')
endfunction

" Escape a pattern for use with a /search/.  Escapes slashes so that
" any embedded slashes don't halt the pattern.
" E.g.:
"   'path/filename'
" ==>
"   'path\/filename'
function! SearchEscape(pattern)
    return escape(a:pattern, '/')
endfunction

" Escape for use with shell commands.
" Basically this will be a bug-fixed implementation of shellescape().
function! ShellEscape(str)
    return shellescape(a:str)
endfunction

" Escape for use with the :Regrep command.
function! ShellEscapeForRegrep(str)
    " TODO Deal with <cword> also.
    return escape(a:str, ' %#')
endfunction

" Patterns:
" Literal       (any literal string converted to a pattern that matches)
" Word          (Any_kind_ofWord_CouldBeHere2)
" Lmc           (lowerMixedCase)
" Umc           (UpperMixedCase)
" Underscore    (underscore_separated_lowercase_with_numbers25)
"
" "Word" words comprise letters, numbers, and underscores, starting with a
" non-digit.
"
" Lmc words comprise characters limited to letters and numbers, starting with a
" lowercase letter and containing at least one uppercase letter.
"
" Umc words comprise characters limited to letters and numbers, starting with an
" uppercase letter and containing at least one lowercase letter and one
" additional uppercase letter.
"
" Underscore words comprise characters limited to lowercase letters, numbers,
" and underscores, containing at least one lowercase letter and one number.

" Create raw Search pattern for literal string.
function! SearchRawLiteralPattern(str)
    return EolEscape(a:str, '\^$.*[]~')
endfunction

" Create Search pattern for literal string.
function! SearchLiteralPattern(str)
    return SearchEscape(SearchRawLiteralPattern(a:str))
endfunction

" Create raw Grep pattern for literal string.
function! GrepRawLiteralPattern(str)
    return EolEscape(a:str, '\^$.*+?()[]{}|')
endfunction

" Create Grep pattern for literal string.
function! GrepLiteralPattern(str)
    return ShellEscape(GrepRawLiteralPattern(a:str))
endfunction

" Create raw Egrep pattern for literal string.
function! EgrepRawLiteralPattern(str)
    " @todo Can't egrep for \n.
    return EolEscape(a:str, '\^$.*+?()[]{}|')
endfunction

" Create Egrep pattern for literal string.
function! EgrepLiteralPattern(str)
    return ShellEscapeForRegrep(EgrepRawLiteralPattern(a:str))
endfunction

" Create raw Search pattern for a "Word".
function! SearchRawWordPattern()
    return '\v\C<%(\l|\u|_)%(\l|\u|\d|_)*>'
endfunction

" Create Search pattern for a "Word".
function! SearchWordPattern()
    return SearchEscape(SearchRawWordPattern())
endfunction

" Create raw Grep pattern for a "Word".
function! GrepRawWordPattern()
    return '\b[a-zA-Z_][a-zA-Z0-9_]*\b'
endfunction

" Create Grep pattern for a "Word".
function! GrepWordPattern()
    return ShellEscape(GrepRawWordPattern())
endfunction

" Create raw Search pattern for lowerMixedCase identifiers.
function! SearchRawLmcPattern()
    return '\v\C<\l(\l|\d)*\u(\a|\d)*>'
endfunction

" Create Search pattern for lowerMixedCase identifiers.
function! SearchLmcPattern()
    return SearchEscape(SearchRawLmcPattern())
endfunction

" Create raw Grep pattern for lowerMixedCase identifiers.
function! GrepRawLmcPattern()
    return '\b[a-z][a-z0-9]*[A-Z][a-zA-Z0-9]*\b'
endfunction

" Create Grep pattern for lowerMixedCase identifiers.
function! GrepLmcPattern()
    return ShellEscape(GrepRawLmcPattern())
endfunction

" Create raw Search pattern for UpperMixedCase identifiers.
function! SearchRawUmcPattern()
    return '\v\C<\u(\u|\d)*\l(\l|\d)*\u(\a|\d)*>'
endfunction

" Create Search pattern for UpperMixedCase identifiers.
function! SearchUmcPattern()
    return SearchEscape(SearchRawUmcPattern())
endfunction

" Create raw Grep pattern for UpperMixedCase identifiers.
function! GrepRawUmcPattern()
    return '\b[A-Z][A-Z0-9]*[a-z][a-z0-9]*[A-Z][a-zA-Z0-9]*\b'
endfunction

" Create Grep pattern for UpperMixedCase identifiers.
function! GrepUmcPattern()
    return ShellEscape(GrepRawUmcPattern())
endfunction

" Create raw Search pattern for underscore_separated identifiers.
function! SearchRawUnderscorePattern()
    return '\v\C<\l*_+\l(\l|_)*>'
endfunction

" Create Search pattern for underscore_separated identifiers.
function! SearchUnderscorePattern()
    return SearchEscape(SearchRawUnderscorePattern())
endfunction

" Create raw Grep pattern for underscore_separated identifiers.
function! GrepRawUnderscorePattern()
    return '\b[a-z]*_+[a-z][a-z_]*\b'
endfunction

" Create Grep pattern for underscore_separated identifiers.
function! GrepUnderscorePattern()
    return ShellEscape(GrepRawUnderscorePattern())
endfunction


" Setup @/ to given pattern, enable highlighting and add to search history.
function! SetSearch(pattern)
    let @/ = a:pattern
    call histadd("search", a:pattern)
    set hlsearch
    " Without redraw, pressing '*' at startup fails to highlight.
    redraw
endfunction

" Set search to a pattern for the given literal string.
function! SetSearchLiteral(literal)
    call SetSearch(SearchLiteralPattern(a:literal))
endfunction

" Set search to a pattern for the given word (matching on word boundaries).
function! SetSearchLiteralWord(word)
    call SetSearch('\<' . SearchLiteralPattern(a:word) . '\>')
endfunction

" Set search register @/ to unnamed ("scratch") register and highlight.
command! -bar MatchScratch
        \ call SetSearch(SearchLiteralPattern(@"))
command! -bar MatchScratchWord
        \ call SetSearch('\<' . SearchLiteralPattern(@") . '\>')

" Map '*' to just highlight, not search for next.
" The extra <Space>N at the end moves forward one space and then searches
" backward again for the word, allowing the [n/m] search message to be displayed
" (assuming 'shortmess' does not contain ``S``).  This an edge case with the
" cursor on the last character of a word at the end of the file.  When this
" happens, the <Space> can't move forward, so Vim aborts the mapping with an
" error.  Most of the work is done correctly, but in this rare case the [n/m]
" message won't be displayed.
nnoremap <silent>
        \* :call SetSearchLiteralWord(expand('<cword>'))<CR><Space>N

nnoremap <silent>
        \g* :call SetSearchLiteral(expand('<cword>'))<CR><Space>N

xnoremap <silent>
        \* <Esc>:call SetSearchLiteral(GetSelectedText())<CR><Space>N

" :Regrep of word under cursor, matching on word boundaries.
nnoremap <F3>
        \ :let g:temporary_text=expand('<cword>')<CR>
        \:call SetSearchLiteralWord(g:temporary_text)<CR>
        \:Regrep \<<C-r>=EgrepLiteralPattern(g:temporary_text)<CR>\>

" :Regrep of visual selection.
xnoremap <F3>
        \ <Esc>:let g:temporary_text=GetSelectedText()<CR>
        \:call SetSearchLiteral(g:temporary_text)<CR>
        \:Regrep <C-r>=EgrepLiteralPattern(g:temporary_text)<CR>

" :G of word under cursor, matching on word boundaries.
nnoremap #
        \ :let g:temporary_text=expand('<cword>')<CR>
        \:call SetSearchLiteralWord(g:temporary_text)<CR>
        \:G <C-r>=GrepLiteralPattern(g:temporary_text)<CR> -w

" :G of visual selection.
xnoremap #
        \ <Esc>:let g:temporary_text=GetSelectedText()<CR>
        \:call SetSearchLiteral(g:temporary_text)<CR>
        \:G <C-r>=GrepLiteralPattern(g:temporary_text)<CR>

function! SearchWord(...)
    if a:0 == 0
        let regex = SearchWordPattern()
    else
        let regex = '\v\C<' . join(a:000, '>|<') . '>'
    endif
    call SetSearch(regex)
endfunction
command! -nargs=* SearchWord  call SearchWord(<f-args>)

command! -bar SearchLmc  call SetSearch(SearchLmcPattern())
command! -bar SearchUmc  call SetSearch(SearchUmcPattern())
command! -bar SearchUnderscore  call SetSearch(SearchUnderscorePattern())

" Run :G with regex for lowerMixedCase identifiers.
command! -nargs=* GrepLmc
        \ SearchLmc<bar>call RunGrep(GrepLmcPattern() . ' ' . <q-args>)

" Run :G with regex for UpperMixedCase identifiers.
command! -nargs=* GrepUmc
        \ SearchUmc<bar>call RunGrep(GrepUmcPattern() . ' ' . <q-args>)

" Run :G with regex for underscore_separated identifiers.
command! -nargs=* GrepUnderscore
        \ SearchUnderscore<bar>
        \ call RunGrep(GrepUnderscorePattern() . ' ' . <q-args>)


" =============================================================
" Folding
" =============================================================

function! FoldShowExpr()
    let maxLevel = 2
    let level = 0
    while level < maxLevel
        if getline(v:lnum - level) =~ @/
            break
        endif
        if level != 0 && (getline(v:lnum + level) =~ @/)
            break
        endif
        let level = level + 1
    endwhile
    return level
endfunction

function! FoldHideExpr()
    return (getline(v:lnum) =~ @/) ? 1 : 0
endfunction

function! FoldRegex(foldExprFunc, regex)
    if a:regex != ""
        let @/=a:regex
        call histadd("search", a:regex)
    endif
    let &l:foldexpr = a:foldExprFunc . '()'
    setlocal foldmethod=expr
    setlocal foldlevel=0
    setlocal foldcolumn=0
    setlocal foldminlines=0
    setlocal foldenable

    " Return to manual folding now that folds have been applied.
    setlocal foldmethod=manual
endfunction

" Search (and "show") regex; fold everything else.
command! -nargs=? FoldSearch    call FoldRegex('FoldShowExpr', <q-args>)

" Fold matching lines ("hide" the matches).
command! -nargs=? Fold          call FoldRegex('FoldHideExpr', <q-args>)

" Fold away comment lines (including blank lines).
" TODO: Extend for more than just shell comments.
command! -nargs=? FoldComments  Fold ^\s*#\|^\s*$

" 'foldexpr' for extracting folding information from QuickFix buffer.
" pattern - used to extract portion of QuickFix path from line.
function! FoldQuickFixPatternFoldExpr(pattern)
    let thisLine = getline(v:lnum)
    let nextLine = getline(v:lnum + 1)
    let thisKey = matchstr(thisLine, a:pattern)
    let nextKey = matchstr(nextLine, a:pattern)
    if thisKey != nextKey
        return '<1'
    else
        return '1'
    endif
endfunction

function! FoldQuickFixDirsFoldExpr()
    return FoldQuickFixPatternFoldExpr('\v^.*[/\\]')
endfunction

" Fold QuickFix window entries by directory.
"   level - initial foldlevel (0 => fold everything, 1 => expand all folds)
function! FoldQuickFixDirs(level)
    let &l:foldlevel = a:level
    setlocal foldcolumn=1
    setlocal foldmethod=expr
    setlocal foldexpr=FoldQuickFixDirsFoldExpr()
endfunction
command! -count=0 FoldQuickFixDirs  call FoldQuickFixDirs(<count>)

function! FoldQuickFixFilesFoldExpr()
    return FoldQuickFixPatternFoldExpr('\v^[^|]*')
endfunction

" Fold QuickFix window entries by filename.
"   level - initial foldlevel (0 => fold everything, 1 => expand all folds)
function! FoldQuickFixFiles(level)
    let &l:foldlevel = a:level
    setlocal foldcolumn=1
    setlocal foldmethod=expr
    setlocal foldexpr=FoldQuickFixFilesFoldExpr()
    setlocal foldenable
endfunction
command! -count=0 FoldQuickFixFiles  call FoldQuickFixFiles(<count>)

" Convert certain unicode characters to ASCII equivalents in range
" from firstLine to lastLine, included.
function! ToAscii(firstLine, lastLine)
    let prefix = "silent " . a:firstLine . "," . a:lastLine . "s"

    " Spaces of non-zero width.
    execute prefix . '/[\u2000-\u200a\u202f]/ /ge'

    " Zero-width spaces and joiners.
    execute prefix . '/[\u200b-\u200d]//ge'

    " "M" dash converts to a double-dash.
    execute prefix . '/[\u2014]/--/ge'

    " Remaining hyphens and short dashes.
    execute prefix . '/[\u2010-\u2015\u2027]/-/ge'

    " Apostrophes.
    execute prefix . '/[\u2018-\u201b]/' . "'" . '/ge'

    " Double-quotes.
    execute prefix . '/[\u201c-\u201f]/"/ge'

    " Bullets.
    execute prefix . '/[\u2022-\u2023\u204c\u204d]/-/ge'

    " One-dot leader.
    execute prefix . '/[\u2024]/./ge'

    " Two-dot leader.
    execute prefix . '/[\u2025]/../ge'

    " Ellipsis.
    execute prefix . '/[\u2026]/.../ge'

    " Prime.
    execute prefix . '/[\u2032]/' . "'" . '/ge'

    " Double-prime.
    execute prefix . '/[\u2033]/' . "''" . '/ge'

    " Triple-prime.
    execute prefix . '/[\u2034]/' . "'''" . '/ge'

    " Reversed Prime.
    execute prefix . '/[\u2035]/`/ge'

    " Reversed double-prime.
    execute prefix . '/[\u2036]/``/ge'

    " Reversed triple-prime.
    execute prefix . '/[\u2037]/```/ge'

    " Caret
    execute prefix . '/[\u2038]/^/ge'

    " Left angle quotation mark.
    execute prefix . '/[\u2039]/</ge'

    " Right angle quotation mark.
    execute prefix . '/[\u203a]/>/ge'

    " Double exclamation mark.
    execute prefix . '/[\u203c]/!!/ge'

endfunction

" Convert certain unicode characters to ASCII equivalents.
command! -range=% ToAscii  call ToAscii(<line1>, <line2>)


function! ExecInPlace(cmd)
    let pos = winsaveview()
    execute a:cmd
    call winrestview(pos)
endfunction

" SubInPlace(pattern, replacement, flags?, line1?, line2?)
" Performs "in-place" substitution of pattern to replacement.
" Defaults: flags='g', line1='1', line2='$'.
function! SubInPlace(pattern, replacement, ...)
    let args = VarArgs(3, a:000)
    let flags = ListPop(args, 'g')
    let line1 = ListPop(args, '1')
    let line2 = ListPop(args, '$')
    let cmd = line1 . ',' . line2 . 's/'
    let cmd .= a:pattern . '/' . a:replacement . '/' . flags
    call ExecInPlace(cmd)
    call histdel("/", -1)
endfunction


" Convert lowerMixedCase to underscore_separated_lowercase, e.g.:
"   "multiWordVariable" ==> "multi_word_variable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Underscore()/g
function! Underscore(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C([A-Z]+)([A-Z][a-z])', '\1_\2', "g")
    let word = substitute(word, '\v\C([a-z\d])([A-Z])', '\1_\2', "g")
    let word = tolower(word)
    return word
endfunction


" Convert underscore_separated_lowercase to UpperMixedCase, e.g.:
"   "multi_word_variable" ==> "MultiWordVariable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Umc()/g
function! Umc(...)
    let word = OptArg(a:000, submatch(0))
    " Algorithm taken from Python inflection package:
    " https://github.com/jpvanhal/inflection/blob/master/inflection.py
    let word = substitute(word, '\v\C(^|_)(.)', '\u\2', "g")
    return word
endfunction


" Convert underscore_separated_lowercase to lowerMixedCase, e.g.:
"   "multi_word_variable" ==> "multiWordVariable"
" If no argument is supplied, submatch(0) is assumed, allowing uses like this:
"   :s//\=Lmc()/g
function! Lmc(...)
    let word = Umc(OptArg(a:000, submatch(0)))
    return tolower(word[:0]) . word[1:]
endfunction


function! SubArgsOrCword(line1, line2, args, replacement)
    if len(a:args) == 0
        let regex = '\v\C<' . expand('<cword>') . '>'
    else
        let regex = '\v\C<' . join(a:args, '>|<') . '>'
    endif
    call SubInPlace(regex, a:replacement, 'g', a:line1, a:line2)
endfunction

command! -bar -range=% -nargs=* ToUnderscore
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Underscore()')

command! -bar -range=% -nargs=* ToUmc
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Umc()')

command! -bar -range=% -nargs=* ToLmc
        \ call SubArgsOrCword(<line1>, <line2>, [<f-args>], '\=Lmc()')

command! -bar -range=% LmcToUnderscore
        \ call SubInPlace(SearchLmcPattern(), '\=Underscore()', 'g',
        \ <line1>, <line2>)

" Refactor/rename identifer under cursor.
nnoremap <M-r>iu :ToUnderscore<CR>
nnoremap <M-r>iU :ToUmc<CR>
nnoremap <M-r>il :ToLmc<CR>

" Inc() function to provide incrementation of the global variable ``i``.
" Add an argument (can be negative, default 1) to global variable i.
" Return value of i before the change.
" E.g.::
"   let i = 1
"   Inc() -> 1
"   Inc() -> 2
"   Inc(3) -> 5
"   Inc(3) -> 8
" To change all ``abc`` strings into ``xyz_#`` where ``#`` increments:
"   :let i = 1 | %s/abc/\='xyz_' . Inc()/g
function Inc(...)
  let result = g:i
  let g:i += a:0 > 0 ? a:1 : 1
  return result
endfunction

" -------------------------------------------------------------
" Buffer manipulation
" -------------------------------------------------------------

" Allow buffers to be hidden even if they have changes.
set hidden

" -------------------------------------------------------------
" Paste setup
" -------------------------------------------------------------

" Setup a key to toggle "paste" mode (toggles between :set paste
" and :set nopaste by executing :set invpaste).
" Neovim has removed the `pastetoggle` option, with the motto "Just Paste It".
if exists('+pastetoggle')
    set pastetoggle=<S-F12>
endif

" For smoother integration with typical applications that use the clipboard,
" set both "unnamed" and "unnamedplus".  This causes yanks to go to both
" the system clipboard (because of "unnamedplus") and the X11 primary selection
" (because of "unnamed"); in addition, puts use the clipboard as their default
" source (because "unnamedplus" takes priority over "unnamed" for puts).
" Disable "autoselect" mode, as that option makes it hard to create a selection
" and then overwrite it with something from the clipboard.
" Use "^=" to prepend these new settings to ensure they come before a possible
" "exclude" option that must be last.
" Note that the "unnamedplus" feature was added in Vim 7.3.74.
set clipboard-=autoselect
set clipboard^=unnamed
if has('unnamedplus')
    set clipboard^=unnamedplus
endif

" -------------------------------------------------------------
" :redir helpers
" -------------------------------------------------------------

" Redirect to register "x":
"   Redir @x
" Redirect to global variable "v":
"   Redir => v
" Disable previous redirection (any of these):
"   Redir
"   Redir end
"   Redir END
" While redirected, the 'more' option is reset to avoid the need
" to press <Space> after each screen of output.
command! -nargs=* -bar Redir
        \ if <q-args> == "" || <q-args> ==? "end" |
        \   set more |
        \   redir END |
        \ else |
        \   redir <args> |
        \   set nomore |
        \ endif

" -------------------------------------------------------------
" Tags
" -------------------------------------------------------------

if !exists('g:Local_ctags_bins')
    let g:Local_ctags_bins = []
    " Prefer Universal Ctags (the maintained fork of Exuberant Ctags).
    let g:Local_ctags_bins += ['ctags-universal']
    let g:Local_ctags_bins += ['universal-ctags']

    " Remaining options taken from `tagbar/autoload/tagbar.vim`:
    let g:Local_ctags_bins += ['ctags-exuberant'] " Debian
    let g:Local_ctags_bins += ['exuberant-ctags']
    let g:Local_ctags_bins += ['exctags'] " FreeBSD, NetBSD
    let g:Local_ctags_bins += ['/usr/local/bin/ctags'] " Homebrew
    let g:Local_ctags_bins += ['/opt/local/bin/ctags'] " Macports
    let g:Local_ctags_bins += ['ectags'] " OpenBSD
    let g:Local_ctags_bins += ['ctags']
    let g:Local_ctags_bins += ['ctags.exe']
    let g:Local_ctags_bins += ['tags']
endif

if !exists('g:Local_ctags_bin')
    for name in g:Local_ctags_bins
        if executable(name)
            let g:Local_ctags_bin = name
            break
        endif
    endfor
endif

" The semicolon gives permission to search up toward the root
" directory.  When followed by a path, the upward search terminates
" at this "stop directory"; otherwise, the search terminates at the root.
" Relative paths starting with "./" begin at Vim's current
" working directory or the directory of the currently open file.
" See :help file-searching for more details.
"
" Additional directories may be added, e.g.:
" set tags+=/usr/local/share/ctags/qt4
"
" Start at working directory or directory of currently open file
" and search upward, stopping at $HOME.  Secondly, search for a
" tags file upward from the current working directory, but stop
" at $HOME.
set tags=./tags;$HOME,tags;$HOME

" Use the following settings in a .ctags file.  With the
" --extra=+f, filenames are tags, too, so the following
" mappings will work when a file isn't in the path.

nnoremap <silent> gf         :<c-u>call <sid>gf("gf")<cr>
nnoremap <silent> <c-w>f     :<c-u>call <sid>gf("\<lt>c-w>f")<cr>
nnoremap <silent> <c-w>gf    :<c-u>call <sid>gf("\<lt>c-w>gf")<cr>
nmap     <silent> <C-w><C-f> <C-w>f

nnoremap <silent> gF         :<c-u>call <sid>gf("gF")<cr>
nnoremap <silent> <c-w>F     :<c-u>call <sid>gf("\<lt>c-w>F")<cr>
nnoremap <silent> <c-w>gF    :<c-u>call <sid>gf("\<lt>c-w>gF")<cr>

function s:gf(map)
    try
        execute 'normal! ' . a:map
    catch /^Vim\%((\a\+)\)\=:E447/
        try
            if a:map ==# "gf" || a:map ==# "gF"
                execute 'tjump ' . expand('<cfile>:t')
            elseif a:map ==# "\<c-w>f" || a:map ==# "\<c-w>F"
                execute 'ptjump ' . expand('<cfile>:t')
            elseif a:map ==# "\<c-w>gf" || a:map ==# "\<c-w>gF"
                execute 'ptjump ' . expand('<cfile>:t')
            endif
        catch /^Vim\%((\a\+)\)\=:E\%(426\|433\)/
            echo 'Error: neither path nor tag for this file name found!'
        endtry
    endtry
endfunction

" Convenience for building tag files in current directory.
command! -bar Ctags :wall|silent! !gentags

if !exists("g:SwapTagKeys")
let g:SwapTagKeys = 0
endif

if g:SwapTagKeys
    " Historically these remappings were always done; but the built-in
    " defaults are actually more convenient than originally thought.
    " The defaults are:
    "
    " - `CTRL-]` jumps to the definition directly, saving the navigation of a
    "   menu in this common case.
    " - `g ]` always results in a menu for matching tags.
    " - `g CTRL-]` makes a menu unless there's only one matching tag.

    nnoremap g<C-]>   <C-]>
    xnoremap g<C-]>   <C-]>
    nnoremap  <C-]>  g<C-]>
    xnoremap  <C-]>  g<C-]>

    nnoremap g<LeftMouse>   g<C-]>
    xnoremap g<LeftMouse>   g<C-]>
    nnoremap <C-LeftMouse>  g<C-]>
    xnoremap <C-LeftMouse>  g<C-]>
endif

" Helper for adding tag files from your $HOME/.tags folder.  Useful within
" .lvimrc files.
function! AddTags(...)
    let index = 1
    while index <= a:0
        let tagPath = expand("$HOME/.tags/") . a:{index} . ".tags"
        if filereadable(tagPath) == 1
            execute 'setlocal tags+=' . escape(tagPath, ' \')
        endif
        let index = index + 1
    endwhile
endfunction

" -------------------------------------------------------------
" Cscope
" -------------------------------------------------------------

if has('cscope') && !has('nvim')
    set cscopeprg=/usr/bin/cscope
    " 0 ==> search cscope database(s) first, then tag file(s) if no matches.
    " 1 ==> search tag file(s) first, then cscope database(s) if no matches.
    set cscopetagorder=0

    " Do not set 'cscopetag'.  This option is intended to be a convenient way
    " to cause :tag, CTRL-], and "vim -t" to use the :cstag command and thus
    " consider cscope tags in addition to standard tags, but there are
    " side-effects that are hard to work around.  In particular, the :cstag
    " command behaves like :tjump, which is mostly a good thing in that a menu
    " pops up whenever there are multiple matching tags.  But this breaks the
    " ability to jump to the nth tag using ":{count}tag {ident}", and since the
    " change is hard-coded into the :tag command, there is no decent
    " work-around for certain scripts (such as the CtrlP plugin) that want to
    " programmatically select the nth tag.  Instead of setting 'cscopetag', use
    " mappings to avoid this unintentional breakage while still getting the
    " beneficial behavior of :tjump.

    " Because the system vimrc may turn on 'cscopetag', turn it off here.
    set nocscopetag

    " Turn off warnings for default cscope.out files.
    set nocscopeverbose
    " Add a database in current directory, or mentioned in CSCOPE_DB.
    if filereadable("cscope.out")
        cs add cscope.out
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    " Turn warnings back on for future "cs add" commands.
    set cscopeverbose

    " Setup which queries use the QuickFix window.
    " Flags:
    "   + Append results to QuickFix window.
    "   - Clear QuickFix window before appending results.
    "   0 Don't use QuickFix window.
    " Search types:
    " a - assigns:  find all assignments to the symbol.
    " c - calls:    find all calls to the function name.
    " d - called:   find functions called by given function name.
    " e - egrep:    egrep search for text.
    " f - file:     open a filename.
    " g - global:   find global definition(s) for symbol.
    " i - includes: find files that include given filename.
    " s - symbol:   find all references to symbol.
    " t - text:     find all instances of the text.
    set cscopequickfix=a-,c-,d-,e-,i-,s-,t-

    nnoremap <Space>ca :cs find a <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <Space>cb :!cscope -f ./cscope.out -bqkv<CR>
    nnoremap <Space>cc :cs find c <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <Space>cd :cs find d <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <Space>ce :cs find e <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <Space>cf :cs find f <C-r>=expand("<cfile>")<CR><CR>
    nnoremap <Space>cg :cs find g <C-r>=expand("<cword>")<CR><CR>
    nnoremap <Space>ci :cs find i ^<C-r>=expand("<cfile>")<CR>$<CR>:Copen<CR>
    nnoremap <Space>cs :cs find s <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <Space>ct :cs find t <C-r>=expand("<cword>")<CR><CR>:Copen<CR>
endif

" -------------------------------------------------------------
" Window manipulation
" -------------------------------------------------------------

" Desired height of QuickFix window.
let g:QuickFixWinHeight = 10

" Desired height of a Location List window.
let g:LocListWinHeight = 5

" Desired width in columns of each window (as laid out by :L, :L2, etc.).
let g:WindowWidth = 80

" Extra columns per window (e.g., to allow room for the two :sign columns).
let g:ExtraWindowWidth = 2

" Return number of windows that have 'relativenumber' or 'number' (or both) set.
function! NumWindowsWithLineNumbers()
    " Note that a local variable won't work with the :Windo command.
    let s:numWindows = 0
    if exists("+number")
        Windo let s:numWindows += &number
    endif
    if exists("+relativenumber")
        Windo let s:numWindows += &relativenumber
    endif
    return s:numWindows
endfunction

" Return number of windows using 'diff' mode.
function! NumWindowsWithDiffMode()
    " Note that a local variable won't work with the :Windo command.
    let s:numWindows = 0
    if exists("+diff")
        Windo let s:numWindows += &diff
    endif
    return s:numWindows
endfunction

" Return minimum required value of 'numberwidth' to support all windows.
function! MinNumberWidth()
    " Note that a local variable won't work with the :Windo command.
    let s:minNumberWidth = 0

    " For 'number', the minimum width is based on biggest line number;
    " for 'relativenumber', it's based on window height.
    " With relativeNumber,
    Windo let s:minNumberWidth = max([
            \ s:minNumberWidth,
            \ max([
            \     (exists("+relativenumber") && &relativenumber) *
            \       strlen(string(winheight(0))),
            \     (exists("+number") && &number) * strlen(string(line("$")))
            \     ])
            \ ])

    if s:minNumberWidth > 0
        " Account for the blank column separating the number from the buffer.
        let s:minNumberWidth += 1

        " Don't drop below 'numberwidth' (or a default if it doesn't exist).
        if exists("+numberwidth")
            let s:minNumberWidth = max([s:minNumberWidth, &numberwidth])
        else
            " Vim's default number width is 4.
            let s:minNumberWidth = max([s:minNumberWidth, 4])
        endif
    endif
    return s:minNumberWidth
endfunction

" Return desired width of a single standard window.
" May be redefined in vimrc-after.vim to customize the logic.
function! GetWindowWidth()
    let width = g:WindowWidth + g:ExtraWindowWidth
    if NumWindowsWithLineNumbers() > 0
        let width += MinNumberWidth()
    endif
    if NumWindowsWithDiffMode() > 0
        let width += 2
    endif
    return width
endfunction

" Re-layout windows in standard fashion.
" If zero arguments are passed, leaves number of columns unchanged.
" If one argument is passed, it's considered the number of window columns.
" Passing two or more arguments is illegal.
" May be redefined in vimrc-after.vim to customize the logic.
function! LayoutWindows(...)
    if a:0 > 1
        echoerr "Invalid number of columns in LayoutWindows"
        return
    elseif a:0 > 0
        let winColumns = a:1
    else
        let winColumns = 0
    endif
    if winColumns > 0
        let winWidth = GetWindowWidth()
        let scrColumns = (winWidth + 1) * winColumns - 1
        let &columns = scrColumns
        redraw
        if &columns != scrColumns
            echoerr "Truncated; try spanning monitor boundary first"
        endif
        if winColumns == 1
            " Put current window at the top.
            wincmd K
        endif
    endif

    " Push QuickFix window (if any) to the bottom with standard size.
    let qfWinNum = GetQuickFixWinNum()
    if qfWinNum > 0
        let startedInQuickFixWin = (qfWinNum == winnr())
        if !startedInQuickFixWin
            execute qfWinNum . "wincmd w"
        endif
        wincmd J
        execute g:QuickFixWinHeight . "wincmd _"
        if !startedInQuickFixWin
            wincmd p
        endif
    endif

    " Resize any Location List windows to standard size.
    let llCmd = g:LocListWinHeight . "wincmd _"
    call WinDo("if IsLocListWin() | " . llCmd . " | endif")

    " Make other windows equally large.
    execute "normal \<C-w>="
endfunction
command! -nargs=? L call LayoutWindows(<f-args>)

" Make 1-column-wide layout.
command! -bar L1 call LayoutWindows(1)

" Make 2-column-wide layout.
command! -bar L2 call LayoutWindows(2)

" Make 3-column-wide layout.
command! -bar L3 call LayoutWindows(3)

" Make 4-column-wide layout.
command! -bar L4 call LayoutWindows(4)

" Make 5-column-wide layout.
command! -bar L5 call LayoutWindows(5)

" Toggle QuickFix window.
function! QuickFixWinToggle()
    let numOpenWindows = winnr("$")
    if IsQuickFixWin()
        " Move to previous window before closing QuickFix window.
        wincmd p
    endif
    cclose
    if numOpenWindows == winnr("$")
        " Window was already closed, so open it.
        Copen
    endif
endfunction
nnoremap <silent> <C-q><C-q> :call QuickFixWinToggle()<CR>
nnoremap <silent> <Space>qq  :call QuickFixWinToggle()<CR>
command! -bar QuickFixWinToggle :call QuickFixWinToggle()

" Toggle location list window.
function! LocListWinToggle()
    let numOpenWindows = winnr("$")
    " TODO: For now, don't use autocmd when closing a location list window,
    " because otherwise when the location list window is focused,
    " :lclose will fight with Syntastic's autocmd feature to reopen it.
    noautocmd lclose
    if numOpenWindows == winnr("$")
        " Window was already closed, so open it.
        silent! Lopen
    endif
endfunction
nnoremap <silent> <C-q><C-l> :call LocListWinToggle()<CR>
nnoremap <silent> <Space>ql  :call LocListWinToggle()<CR>
command! -bar LocListWinToggle :call LocListWinToggle()

" Like windo but restore the current window.
function! WinDo(command)
    let curWinNum = winnr()
    execute 'windo ' . a:command
    execute curWinNum . 'wincmd w'
endfunction
command! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" Like bufdo but restore the current buffer.
function! BufDo(command)
    let currBuff=bufnr("%")
    execute 'bufdo if &bt==""|set ei-=Syntax|' . a:command . '|endif'
    execute 'buffer ' . currBuff
endfunction
command! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

" Like tabdo but restore the current tab.
function! TabDo(command)
    let currTab=tabpagenr()
    execute 'tabdo ' . a:command
    execute 'tabn ' . currTab
endfunction
command! -nargs=+ -complete=command Tabdo call TabDo(<q-args>)

" Force current window to be the only window (like <C-w>o).
" Avoids "Already only one window" error if only one window is showing.
function! OneWindow()
    if winnr("$") > 1
        wincmd o
    endif
endfunction
command! -bar OneWindow call OneWindow()

" Avoid "Already only one window" errors.
nnoremap <silent> <C-w><C-o> :OneWindow<CR>
nnoremap <silent> <C-w>o     :OneWindow<CR>

" -------------------------------------------------------------
" Diff-related
" -------------------------------------------------------------

" Taken from :help :DiffOrig.  Shows unsaved differences between
" this buffer and original file.
function! DiffOrig()
    OneWindow
    vertical new
    set buftype=nofile
    " When this scratch buffer leaves the window, wipe it out.
    setlocal bufhidden=wipe
    read ++edit #
    0d_
    diffthis
    wincmd p
    diffthis
    wincmd L
endfunction
command! -bar DiffOrig silent call DiffOrig()

" Return list of window numbers for all diff windows (in descending order).
function! GetDiffWinNums()
    let diffWinNums = []
    let curWinNum = winnr()
    for winNum in range(winnr("$"), 1, -1)
        execute "noautocmd " . winNum . "wincmd w"
        if &diff
            let diffWinNums += [winNum]
        endif
    endfor
    execute "noautocmd " . curWinNum . "wincmd w"
    return diffWinNums
endfunction

" Diff current window and "next" window or a newly split file.
function! Diff(filename)
    if a:filename != ""
        execute "vsplit " . a:filename
    endif
    if winnr("$") >= 2
        diffthis
        wincmd w
        diffthis
        wincmd p
    endif
endfunction
command! -bar -nargs=? Diff  call Diff(<q-args>)

" =============================================================
" Python venv support
" =============================================================

" Display information about any active Python virtual environment.
command! -bar Venvinfo call vimf#venv#info()

" Deactivate any active Python virtual environment.
command! -bar Venvdeactivate call vimf#venv#deactivate()

" Activate a Python virtual environment given on the command line.
" E.g.:
"   Venvactivate ../.venv
" Will probe first for `.venv` and `venv` subdirectories below the
" given directory; therefore, these are equivalent:
"   Venvactivate ../.venv
"   Venvactivate ..
" With no argument, will scan upward from the directory of current file,
" probing for virtual environments (checking for `.venv`, `venv`, and `.`).
command! -bar -nargs=? -complete=file
        \ Venvactivate call vimf#venv#activate(<q-args>)

" =============================================================
" Plugins
" =============================================================

" -------------------------------------------------------------
" Ack
" -------------------------------------------------------------

" Default to using "ack" from vimfiles, as we aim to keep it at least as
" up-to-date as any system-provided "ack" executable.  This will avoid picking
" up old 1.x versions of "ack" that might be found on the system.
if !exists("g:UseSystemAck")
    let g:UseSystemAck = 0
endif

" Setup default Ack options.  Unfortunately this must be done in duplication of
" the settings in ack.vim, because they have to be part of g:ackprg which we'd
" like to set here.  Even if g:UseSystemAck is true, we set these options here
" to ensure they are the same regardless of which executable is chosen.
if !exists("g:ack_default_options")
    let g:ack_default_options = " -s -H --nocolor --nogroup --column"
            \ . " --smart-case --follow"
endif

let g:ackprg = g:AckExecutable . g:ack_default_options

" Disable QuickFix/LocationList mappings.
let g:ack_apply_qmappings = 0
let g:ack_apply_lmappings = 0

" -------------------------------------------------------------
" Ag
" -------------------------------------------------------------

let g:agprg="ag --column --smart-case"

function! AgCall(ackFunc, cmd, argString)
    try
        let old_ackprg = g:ackprg
        let g:ackprg = g:agprg
        call {a:ackFunc}(a:cmd, a:argString)
    finally
        let g:ackprg = old_ackprg
    endtry
endfunction

command! -bang -nargs=* -complete=file Ag
        \ call AgCall('ack#Ack', 'grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgAdd
        \ call AgCall('ack#Ack', 'grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFromSearch
        \ call AgCall('ack#AckFromSearch', 'grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAg
        \ call AgCall('ack#Ack', 'lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAgAdd
        \ call AgCall('ack#Ack', 'lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFile
        \ call AgCall('ack#Ack', 'grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=help AgHelp
        \ call AgCall('ack#AckHelp', 'grep<bang>', <q-args>)
command! -bang -nargs=* -complete=help LAgHelp
        \ call AgCall('ack#AckHelp', 'lgrep<bang>', <q-args>)
command! -bang -nargs=*                AgWindow
        \ call AgCall('ack#AckWindow', 'grep<bang>', <q-args>)
command! -bang -nargs=*                LAgWindow
        \ call AgCall('ack#AckWindow', 'lgrep<bang>', <q-args>)

" -------------------------------------------------------------
" Airline
" -------------------------------------------------------------

if g:EnableAirline
" Default sections (from documentation):
"   g:airline_section_a       (mode, crypt, paste, spell, iminsert)
"   g:airline_section_b       (hunks, branch)
"   g:airline_section_c       (bufferline or filename)
"   g:airline_section_gutter  (readonly, csv)
"   g:airline_section_x       (tagbar, filetype, virtualenv)
"   g:airline_section_y       (fileencoding, fileformat)
"   g:airline_section_z       (percentage, line number, column number)
"   g:airline_section_error   (ycm_error_count, syntastic, eclim)
"   g:airline_section_warning (ycm_warning_count, syntastic-warn, whitespace)

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif


function! AirlineInit()
    " Remove parts that are redundant or which don't change often enough to
    " warrant perpetual space taken in the status line.

    " Default sections: ['tagbar', 'gutentags', 'grepper', 'filetype']
    " Remove 'filetype'.
    let g:airline_section_x = airline#section#create(
            \['tagbar', 'gutentags', 'grepper'])

    " Default sections: ['ffenc']
    " Remove 'ffenc'.
    let g:airline_section_y = ''

    " Default sections are a function of initial window width:
    " >  80:  ['windowswap', 'obsession', '%3p%%'.spc,
    "          'linenr', 'maxlinenr', spc.':%3v']
    " <= 80:  ['%3p%%'.spc, 'linenr',  ':%3v']
    " To save space:
    " - Use 2-character percentage ('%2p%%')
    " - Use fancy "LN" symbol for line number
    " - Skip display of maximum line number
    " - Use 2-character left-justified virtual column number ('%-2v')
    " - Skip Obsession and Windowswap fields (unless/until these
    "   plugins are used)
    let g:airline_section_z = airline#section#create([
        \ 'windowswap', '%2p%% ',
        \ '%{g:airline_symbols.linenr} %#__accent_bold#%3l%#__restore__#',
        \ ':%-2v'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()

" Skip any empty airline sections, eliminating spurious '<' symbols and spaces.
let g:airline_skip_empty_sections = 1

" Avoid "SPELL" indicator.
let g:airline_detect_spell = 0

" Disable word counting; it takes too much space.  "g CTRL-G" checks on-demand.
let g:airline#extensions#wordcount#enabled = 0

" Types of whitespace violations:
" - indent:            mixed indent within a line
" - long:              overlong lines
" - trailing:          trailing whitespace
" - mixed-indent-file: different indentation in different lines
" Default checks: ['indent', 'trailing', 'mixed-indent-file']
let g:airline#extensions#whitespace#checks = [
        \ 'indent', 'trailing', 'mixed-indent-file']

" Don't display a message on whitespace issues.
" let g:airline#extensions#whitespace#show_message = 0

" Configure short whitespace indicators.
let airline#extensions#whitespace#trailing_format = '$%.0s'
let g:airline#extensions#whitespace#mixed_indent_format = 'mix%.0s'
let g:airline#extensions#whitespace#long_format = '+%.0s'
let g:airline#extensions#whitespace#mixed_indent_file_format = '\t%.0s'

" Configure format for SyntasticStatuslineFlag() (which generates the
" text for airline's Syntastic support).
let g:syntastic_stl_format = '%E{%ee}%B{ }%W{%ww}'

" Provide short forms of mode names.
let g:airline_mode_map = {
      \ '__' : '-',
      \ 'n'  : 'N',
      \ 'i'  : 'I',
      \ 'R'  : 'R',
      \ 'c'  : 'C',
      \ 'v'  : 'V',
      \ 'V'  : 'V⋅LINE',
      \ "\<C-v>" : 'V⋅BLOCK',
      \ 's'  : 'SELECT',
      \ 'S'  : 'S⋅LINE',
      \ "\<C-s>" : 'S⋅BLOCK',
      \ }
else
    " Airline will not load if this variable is defined:
    let g:loaded_airline = 1
endif


" -------------------------------------------------------------
" ALE
" -------------------------------------------------------------

if g:EnableAle
    " Setting this to 1 causes ALE to automatically pop up a completion
    " menu.  Unfortunately, this causes some keystrokes to be swallowed
    " (especially Enter), impeding text entry.  Use CTRL-X CTRL-O to manually
    " invoke the omnicompletion menu instead.
    " let g:ale_completion_enabled = 1

    let g:ale_sign_column_always = 1

    " NOTE: Also see configuration adjustments in vim-lsp section.

    " 'rls' - Rust Language Server.
    let g:ale_linters = {}
    let g:ale_linters['rust'] = ['analyzer', 'cargo']
    " Note: Python linters will be replaced by `vim-lsp` if available.
    " See `vim-lsp` configuration section.
    if executable('ruff')
        let g:ale_linters['python'] = ['ruff', 'mypy']
    else
        let g:ale_linters['python'] = ['flake8', 'mypy']
    endif
    let g:ale_linters['c'] = ['cc', 'clangtidy', 'cppcheck', 'flawfinder']
    let g:ale_linters['cpp'] = ['cc', 'clangtidy', 'cppcheck', 'flawfinder']
    let g:ale_linters['zig'] = ['zls']

    " Pylint is too picky to be on by default.
    let g:ale_linters_ignore = { 'python': ['pylint'] }

    if !exists('g:AleFlake8Ignores')
        " Flake8 warnings:
        " "E203 whitespace before ':'" goes against PEP8.
        " "I202 Additional newline in a group of imports"
        " "N811 constant imported as non constant"
        " "N812 lowercase imported as non lowercase"
        " "N813 camelcase imported as lowercase"
        " "N814 camelcase imported as constant"
        " "W503" enforces breaking after operator, which goes against PEP8's
        " current (weak) recommendation to break before operators.
        let g:AleFlake8Ignores = split('E203 I202 N811 N812 N813 N814 W503')
    endif

    if !exists('g:ale_python_flake8_options')
        let g:ale_python_flake8_options = ''
        let g:ale_python_flake8_options .= ' --inline-quotes=double'
        " Match python-language-server default McCabe complexity.
        let g:ale_python_flake8_options .= ' --max-complexity=15'
    endif

    if len(g:AleFlake8Ignores) > 0
        let g:ale_python_flake8_options .= ' --extend-ignore='
                \ . join(g:AleFlake8Ignores, ',')
    endif

    " Any `~/.mdlrc` file will take precedence; if this file does not exist,
    " then point to `$VIMFILES/etc/mdl-style.rb`.
    " To use the above style file when using `mdl` from the command line, create
    " `~/.mdlrc` with contents:
    "
    "   style "#{File.dirname(__FILE__)}/.vim/etc/mdl-style.rb"
    if !exists('g:ale_markdown_mdl_options') &&
            \ !filereadable(expand('$HOME/.mdlrc'))
        let g:ale_markdown_mdl_options =
            \ '--style ' . ale#Escape($VIMFILES . '/etc/mdl-style.rb')
    endif

    " Experiment with disabling the extra-picky info messages out of rstcheck.
    let g:ale_rst_rstcheck_options =
            \ '--ignore-messages ' . ale#Escape(join([
            \   'Duplicate implicit target name:',
            \   'Possible incomplete section title',
            \   'Enumerated list start value not ordinal-1',
            \ ], '|'))

    " Setup shellcheck for shell scripting.
    " Warnings:
    "   SC1090: Can't follow non-constant source.
    "   SC2016: Expressions don't expand in single quotes.
    " Join warnings to ignore with commas (e.g., 'SC2034,SC2154').
    let g:ale_sh_shellcheck_exclusions = 'SC1090,SC2016'

    " Setup shfmt for shell scripting.
    " Invoke via:  ALEFix shfmt
    " -p        - posix-compatible source
    " -i UINT   - setup for indentation with UNIT spaces.
    " -sr       - redirect operators will be followed by a space.
    " (The `-p` option will be added based on filetype detection.)
    let g:ale_sh_shfmt_options = '-sr -i 4'

    " Use pre-processor with assembly files.
    let g:ale_asm_gcc_options = '-Wall -x assembler-with-cpp'

    let g:ale_fixers = {
        \ 'c': ['clang-format'],
        \ 'cpp': ['clang-format'],
        \ 'python': ['black', 'isort'],
        \ 'ruby': ['rubocop'],
        \ 'rust': ['rustfmt'],
        \ 'sh': ['shfmt'],
        \ }
    let g:ale_python_black_options = '-l 79'
    let g:ale_python_isort_options = '--profile black'

    " If `ruff` is installed, prefer it to `black` and `isort`.
    if executable('ruff')
        let g:ale_fixers['python'] = ['ruff_format']
    endif

    " Use ALE fixer on the current buffer.
    nmap <Space>=  <Plug>(ale_fix)
endif

" -------------------------------------------------------------
" Align
" -------------------------------------------------------------

" Use `\|` as the prefix for AlignMaps.
let g:Align_mapleader = '\|'

" -------------------------------------------------------------
" BufExplorer
" -------------------------------------------------------------

let g:bufExplorerShowRelativePath = 1
let g:bufExplorerShowNoName = 1
let g:bufExplorerFindActive = 0

" -------------------------------------------------------------
" bufkill
" -------------------------------------------------------------

" Don't define the slew of extra mappings built into this plugin.
let g:BufKillCreateMappings = 0

" If the buffer you are attempting to kill in one window is also displayed
" in another, you may not want to kill it afterall.  This option lets you
" decide how this situation should be handled, and can take one of the following
" values:
"   'kill' - kill the buffer regardless, always
"   'confirm' - ask for confirmation before removing it
"   'cancel' - don't kill it
let g:BufKillActionWhenBufferDisplayedInAnotherWindow = 'kill'

" Wipeout the current buffer.
nnoremap <Space>bd          :BW<CR>

" Wipeout the current buffer, even if there are changes.
nnoremap <Space>bD          :BW!<CR>

" -------------------------------------------------------------
" bufmru
" -------------------------------------------------------------

" TODO: Temporary work-around for bug introduced in Vim 8.2.0851:
" https://github.com/vim/vim/issues/6457
nmap <c-6> <c-^>
nmap <c-s-^> <c-^>

" Set key to enter BufMRU mode (override this in vimrc-before.vim).
if !exists("g:bufmru_switchkey")
    " NOTE: <C-^> (CTRL-^) also works without shift (just pressing CTRL-6).
    let g:bufmru_switchkey = "<C-^>"
endif

" Use <Space><Space> as an additional map for BufMRU mode, aiming to be
" closer to the original muscle memory of pressing a single <Space>.
exec "nmap <Space><Space> " . g:bufmru_switchkey

" Set to 1 to pre-load the number marks into buffers.
" Set to 0 to avoid this pre-loading.
let g:bufmru_nummarks = 0

function! BufmruUnmap()
    " Remove undesirable mappings, keeping the bare minimum for fast buffer
    " switching without needing the press <Enter> to exit bufmru "mode".
    nunmap <Plug>bufmru....e
    nunmap <Plug>bufmru....!
    nunmap <Plug>bufmru....<Esc>
    nunmap <Plug>bufmru....y
endfunction

augroup local_bufmru
    autocmd!
    autocmd VimEnter * call BufmruUnmap()
augroup END

" -------------------------------------------------------------
" cpsm (matcher for CtrlP)
" -------------------------------------------------------------

" Pressing this delimiter causes later characters to be placed before earlier.
" E.g., setting this to <Space> means that this string:
"   "foo bar qux"
" will be matched as if it were this string:
"   "quxbarfoo"
" Useful for matching on a file extension first, then the name, e.g.:
"   ".c file path"
" is the same as:
"   "pathfile.c"
if !exists('g:cpsm_query_inverting_delimiter')
    let g:cpsm_query_inverting_delimiter = ' '
endif

if !exists('g:ctrlp_match_func')
    " Use cpsm matcher for CtrlP if the compiled "cpsm_cli" executable exists.
    " See `:help notes_cpsm` for instructions on compiling cpsm.
    if glob($VIMFILES . '/bundle/cpsm/bin/cpsm_cli*') != ''
        let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
    endif
endif

" -------------------------------------------------------------
" CtrlP
" -------------------------------------------------------------

" No default mappings.
let g:ctrlp_map = ''

" If available, use ripgrep to list files within a Git repository.
" Ripgrep honors .gitignore automatically.  With ``--hidden``, ripgrep
" will display files starting with ``.``.  Undesired files will typically
" either be binary (which ripgrep ignores by default), or will be ignored
" by the .gitignore file.
if executable('rg')
    let g:ctrlp_user_command = {
        \ 'types': {
                \ 1: ['.git', 'cd %s && rg -g "!.git/" --files --hidden'],
                \ },
        \ }
endif

" Configure `ctags` executable for `CtrlPBufTag` support.
if !exists('g:ctrlp_buftag_ctags_bin') && exists('g:Local_ctags_bin')
    let g:ctrlp_buftag_ctags_bin = g:Local_ctags_bin
endif

" Directory mode for launching ':CtrlP' with no directory argument:
"   0 - Don't manage the working directory (Vim's CWD will be used).
"       Same as ':CtrlP $PWD'.
let g:ctrlp_working_path_mode = 0

" Set to list of marker directories used for ':CtrlPRoot'.
" A marker signifies that the containing parent directory is a "root".  Each
" marker is probed from current working directory all the way up, and if
" the marker is not found, then the next marker is checked.
let g:ctrlp_root_markers = []

" Don't open multiple files in vertical splits.  Just open them, and re-use the
" buffer already at the front.
let g:ctrlp_open_multiple_files = '1vr'

" Don't try to jump to another window or tab; instead, open the desired
" buffer in the current window.  By default, this variable is undefined, which
" is equivalent to a value of "Et":
" "E" - On <CR>, jump to open window on any tab.
" "t" - On <C-t>, jump to open window on current tab.
let g:ctrlp_switch_buffer=""

" The default of 10,000 files isn't enough, but as Jim points out, 640K
" ought to be enough for anybody :-)
let g:ctrlp_max_files = 640000

" :C [path]  ==> :CtrlP [path]
command! -n=? -com=dir C CtrlP <args>

" :CD [path]  ==> :CtrlPDir [path]
command! -n=? -com=dir CD CtrlPDir <args>

" Define prefix mapping for CtrlP plugin so that buffer-local mappings
" for CTRL-p (such as in Tagbar) will override all CtrlP plugin mappings.
nmap <C-p> <SNR>CtrlP.....

" An incomplete mapping should do nothing.
nnoremap <SNR>CtrlP.....      <Nop>

nnoremap <SNR>CtrlP.....<C-b> :<C-u>CtrlPBookmarkDir<CR>
nnoremap <SNR>CtrlP.....c     :<C-u>CtrlPChange<CR>
nnoremap <SNR>CtrlP.....C     :<C-u>CtrlPChangeAll<CR>
nnoremap <SNR>CtrlP.....<C-d> :<C-u>CtrlPDir<CR>
nnoremap <SNR>CtrlP.....<C-f> :<C-u>CtrlPCurFile<CR>
nnoremap <SNR>CtrlP.....<C-l> :<C-u>CtrlPLine<CR>
nnoremap <SNR>CtrlP.....<C-m> :<C-u>CtrlPMRU<CR>
nnoremap <SNR>CtrlP.....m     :<C-u>CtrlPMixed<CR>

" Mnemonic: "open files"
nnoremap <SNR>CtrlP.....<C-o> :<C-u>CtrlPBuffer<CR>
nnoremap <SNR>CtrlP.....<C-p> :<C-u>CtrlP<CR>
nnoremap <SNR>CtrlP.....<C-q> :<C-u>CtrlPQuickfix<CR>
nnoremap <SNR>CtrlP.....q     :<C-u>CtrlPQuickfix<CR>
nnoremap <SNR>CtrlP.....<C-r> :<C-u>CtrlPRoot<CR>
nnoremap <SNR>CtrlP.....<C-t> :<C-u>CtrlPTag<CR>
nnoremap <SNR>CtrlP.....t     :<C-u>CtrlPBufTag<CR>
nnoremap <SNR>CtrlP.....T     :<C-u>CtrlPBufTagAll<CR>
nnoremap <SNR>CtrlP.....<C-u> :<C-u>CtrlPUndo<CR>

" Select from open buffers.
nnoremap <Space>bb          :<C-u>CtrlPBuffer<CR>

" Select files relative to the current file.
nnoremap <Space>ff          :<C-u>CtrlPCurFile<CR>

" Select files relative to the project root directory.
nnoremap <Space>pf          :<C-u>CtrlPRoot<CR>

" Duplicative, but easier to type.
" Select files relative to the project root directory.
nnoremap <Space>pp          :<C-u>CtrlPRoot<CR>


" Adjust move and history binding pairs:
" - For consistency with other plugins that use <C-n>/<C-p> for moving around.
" - Because <C-j> is bound to the tmux prefix key, it's best to avoid the use
"   of that key.  But for backward compatibility, <C-j>/<C-k> have been retained
"   as aliases.
let g:ctrlp_prompt_mappings = {
        \ 'PrtSelectMove("j")':   ['<C-n>', '<down>'],
        \ 'PrtSelectMove("k")':   ['<C-p>', '<up>'],
        \ 'PrtHistory(-1)':       ['<M-n>', '<C-j>'],
        \ 'PrtHistory(1)':        ['<M-p>', '<C-k>'],
        \ }

" Maximum height of filename window.
let g:ctrlp_max_height = 50

" Reuse the current window when opening new files.
let g:ctrlp_open_new_file = 'r'

" Symlinks:
" 0 - Do not follow symlinks.
" 1 - Follow non-looped symlinks.
" 2 - Follow all symlinks.
let g:ctrlp_follow_symlinks = 1

" -------------------------------------------------------------
" DiffChar
" -------------------------------------------------------------

" 0 : hl-DiffText (default)
" 1 : hl-DiffText + up to 3 other highlights
" 2 : hl-DiffText + up to 7 other highlights
" 3 : hl-DiffText + up to 15 other highlights
let g:DiffColors = 2

" 0 : disable
" 1 : highlight with hl-Cursor (default)
" 2 : highlight with hl-Cursor + echo in the command line
" 3 : highlight with hl-Cursor + popup/floating window at cursor position
" 4 : highlight with hl-Cursor + popup/floating window at mouse position
let g:DiffPairVisible = 3

" -------------------------------------------------------------
" Easy-Align
" -------------------------------------------------------------

xmap <Leader>a <Plug>(EasyAlign)
nmap <Leader>a <Plug>(EasyAlign)

" Setup custom alignment characters.
"   \ - Align on backslash (such as for C/C++ line continuations).
let g:easy_align_delimiters = {
        \ '\':
        \   {
        \       'pattern':         '\\$',
        \   },
        \ }

" -------------------------------------------------------------
" easymotion
" -------------------------------------------------------------

" Don't use the default maps, as there are too many deviations from
" the defaults.
let g:EasyMotion_do_mapping = 0

" Lowercase keys will match either lowercase or uppercase buffer text.
let g:EasyMotion_smartcase = 1

" Set keys for targets (removing semi-colon from default).
let g:EasyMotion_keys = "asdghklqwertyuiopzxcvbnmfj"

Noxmap   <Space>jj          <Plug>(easymotion-s)
Noxmap   <Space>jJ          <Plug>(easymotion-s2)
Noxmap   <Space>jl          <Plug>(easymotion-sol-bd-jk)

" Setup target locations for single-line "anywhere".
let g:EasyMotion_re_line_anywhere = '\v' .
        \ '^$'                . '|' .
        \ '<.'                . '|' .
        \ '>.'                . '|' .
        \ '\l\zs\u'           . '|' .
        \ '_\zs.'             . '|' .
        \ '#\zs.'

" Setup target locations for "anywhere".
let g:EasyMotion_re_anywhere = '\v' .
        \ '^$'                . '|' .
        \ '<.'                . '|' .
        \ '>.'                . '|' .
        \ '\l\zs\u'           . '|' .
        \ '_\zs.'             . '|' .
        \ '#\zs.'

" -------------------------------------------------------------
" eunuch
" -------------------------------------------------------------

" Undocumented way to disable mapping of <CR>.  The default mapping of <CR>
" is supposed to help re-write a shebang line with an interpreter and redetect
" the filetype.
let g:eunuch_no_maps = 1

" -------------------------------------------------------------
" fswitch
" -------------------------------------------------------------

" dst - value for b:fswitchdst
" locs - value for b:fswitchlocs
" ... - value for b:fswitchfnames (if provided)
function! SetFswitchVars(dst, locs, ...)
    if a:0 == 1
        let fnames = a:1
        if !exists("b:fswitchfnames")
            let b:fswitchfnames = fnames
        endif
    elseif a:0 > 1
        echoerr "Invalid argument count"
        return
    endif

    if !exists("b:fswitchdst")
        let b:fswitchdst = a:dst
    endif
    if !exists("b:fswitchlocs")
        let b:fswitchlocs = a:locs
    endif
endfunction

augroup local_fswitch
    autocmd!
    " There are lots more options - :help fswitch.  We use SetFswitchVars()
    " because we don't want to override values set by a .lvimrc file.
    autocmd BufEnter *.h call SetFswitchVars(
            \ 'c,cpp',
            \  'reg:@\v/(pubinc|include|inc|Iface)($|/.*$)@/src@'
            \.',reg:@\v/(pubinc|include|inc|Iface)($|/.*$)@/src/**@'
            \.',../src'
            \)
    autocmd BufEnter *.c,*.cpp call SetFswitchVars(
            \ 'h',
            \  'reg:@\v/src($|/.*$)@/pubinc@'
            \.',reg:@\v/src($|/.*$)@/include@'
            \.',reg:@\v/src($|/.*$)@/inc@'
            \.',reg:@\v/src($|/.*$)@/Iface@'
            \.',reg:@\v/src($|/.*$)@/pubinc/**@'
            \.',reg:@\v/src($|/.*$)@/include/**@'
            \.',reg:@\v/src($|/.*$)@/inc/**@'
            \.',reg:@\v/src($|/.*$)@/Iface/**@'
            \.',../pubinc'
            \.',../include'
            \.',../inc'
            \.',../Iface'
            \)
    autocmd BufEnter *.snippets call SetFswitchVars(
            \ 'snippets.py',
            \ '.')
    autocmd BufEnter *.snippets.py call SetFswitchVars(
            \ 'snippets',
            \ '.',
            \ '/.snippets$//')
augroup END

" Switch to the file and load it into the current window.
nmap <silent> <Leader>of :FSHere<cr>

" Switch to the file and load it into the window on the right.
nmap <silent> <Leader>ol :FSRight<cr>

" Switch to the file and load it into a new window split on the right.
nmap <silent> <Leader>oL :FSSplitRight<cr>

" Switch to the file and load it into the window on the left.
nmap <silent> <Leader>oh :FSLeft<cr>

" Switch to the file and load it into a new window split on the left.
nmap <silent> <Leader>oH :FSSplitLeft<cr>

" Switch to the file and load it into the window above.
nmap <silent> <Leader>ok :FSAbove<cr>

" Switch to the file and load it into a new window split above.
nmap <silent> <Leader>oK :FSSplitAbove<cr>

" Switch to the file and load it into the window below.
nmap <silent> <Leader>oj :FSBelow<cr>

" Switch to the file and load it into a new window split below.
nmap <silent> <Leader>oJ :FSSplitBelow<cr>

" Compatibility for old Alternate.vim plugin.
command! -bar A FSHere

" -------------------------------------------------------------
" Grep
" -------------------------------------------------------------

let Grep_Skip_Dirs = '.svn .bzr .git .hg build bak export .undo'
let Grep_Skip_Files = '*.bak *~ .*.swp tags *.opt *.ncb *.plg ' .
        \ '*.o *.elf cscope.out *.ecc *.exe *.ilk *.out *.pyc ' .
        \ 'build.out doxy.out'

" -------------------------------------------------------------
" Grepper
" -------------------------------------------------------------

let g:grepper = {}

" Grepper will stop after this many results.  The default (5000) is too small.
let g:grepper.stop = 20000

" These are the default tools.  It's a shame there's not a smoother way to
" extend the list without pasting it here.
let g:grepper.tools = ['rg', 'ag', 'ack', 'grep', 'findstr', 'pt', 'git']

" The Silver Searcher (ag).
let g:grepper.ag = {}
let g:grepper.ag.grepprg =
        \ 'ag --nogroup --filename --numbers --column'

" prargs (just for debugging quoting issues).
let g:grepper.tools += ['prargs']
let g:grepper.prargs = {}
let g:grepper.prargs.grepprg = 'prargs'
let g:grepper.prargs.escape = ''

" ffg.
let g:grepper.tools += ['ffg']
let g:grepper.ffg = {}
let g:grepper.ffg.grepprg = 'ffg -Pn'
let g:grepper.ffg.escape = '\^$.*+?()[]|'

" ffx.
let g:grepper.tools += ['ffx']
let g:grepper.ffx = {}
let g:grepper.ffx.grepprg = 'ffx'
let g:grepper.ffx.grepformat = '%f'

" findx.
let g:grepper.tools += ['findx']
let g:grepper.findx = {}
let g:grepper.findx.grepprg = 'findx'
let g:grepper.findx.grepformat = '%f'

" Ripgrep (rg).
let g:grepper.rg = {}
let g:grepper.rg.grepprg =
        \ 'rg -H --no-heading --line-number --column --smart-case --sort path'

" -------------------------------------------------------------
" HiLinkTrace
" -------------------------------------------------------------

" Disable default mappings by having a pre-existing (but useless)
" mapping to <Plug>HiLinkTrace.
nmap <SID>DisableHiLinkTrace <Plug>HiLinkTrace

" -------------------------------------------------------------
" indent-guides
" -------------------------------------------------------------

let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:IndentGuides = 0
let g:IndentGuidesMap = {}

function! AdjustIndentGuideColors()
    if hlexists("IndentGuidesEven") && hlexists("IndentGuidesOdd")
        let g:indent_guides_auto_colors = 0
    else
        let g:indent_guides_auto_colors = 1
    endif
endfunction

function! IndentGuidesForBuffer()
    if !g:IndentGuides
        return
    endif

    let key = LookupKey("b:IndentGuidesType", "g:IndentGuidesMap")

    if key == "<on>"
        call indent_guides#enable()
    else
        call indent_guides#disable()
    endif
endfunction

function! FixupIndentGuidesAutocommands()
    " We clear out the indent guides autocmds because they don't implement the
    " behavior that we desire.
    augroup indent_guides
      autocmd!
    augroup END
endfunction

augroup local_indent_guides
    autocmd!
    autocmd BufEnter * call IndentGuidesForBuffer()

    autocmd ColorScheme * call AdjustIndentGuideColors()
    autocmd VimEnter * call FixupIndentGuidesAutocommands()
augroup END

if exists("g:colors_name")
    call AdjustIndentGuideColors()
endif

" -------------------------------------------------------------
" localvimrc
" -------------------------------------------------------------

" Enable persistence of our decisions.
set viminfo+=!

" 0 - Don't store and restore any decisions.
" 1 - Store and restore decisions only for uppercase answers (Y/N/A).
" 2 - Store and restore all decisions.
let g:localvimrc_persistent = 1

" Since localvimrc files require confirmation, don't require :sandbox.
let g:localvimrc_sandbox = 0

" -------------------------------------------------------------
" lookupfile
" -------------------------------------------------------------

let g:LookupFile_MinPatLength = 0

" -------------------------------------------------------------
" LustyExplorer
" -------------------------------------------------------------

" g:LustyExplorerSuppressRubyWarning - if missing Ruby, don't complain
let g:LustyExplorerSuppressRubyWarning = 1

" -------------------------------------------------------------
" LustyJuggler
" -------------------------------------------------------------

" Show letters before filenames.
let g:LustyJugglerShowKeys = 'a'

" Prevents warning if Ruby not compiled in.
let g:LustyJugglerSuppressRubyWarning = 1

" Use alt-tab mode support.  Re-launching the juggler when it is already
" active will cycle through the most-recently-used list of buffers.
let g:LustyJugglerAltTabMode = 1

" Launch Lusty Juggler (also used for cycling through MRU buffers).
" This is in addition to \lj (the default mapping).
nnoremap <silent> <M-s> :LustyJuggler<CR>

" -------------------------------------------------------------
" Man support
" -------------------------------------------------------------

" Source Vim's ftplugin to define the :Man command:
runtime ftplugin/man.vim

" Use ``:Man`` when ``K`` is pressed:
set keywordprg=:Man

" -------------------------------------------------------------
" Matchup
" -------------------------------------------------------------

" Some plugins detect the presence of matchit by checking if `loaded_matchit` is
" true; if detected, they setup some matchit-related variables that matchup can
" automatically use.  Therefore, define this variable so these plugins will work
" with matchup.
let g:loaded_matchit = 1

" -------------------------------------------------------------
" Mundo
" -------------------------------------------------------------

nnoremap <Space>qu  :MundoToggle<CR>
let g:mundo_close_on_revert = 1

" There is more horizontal viewing room with the preview at the bottom.
let g:mundo_preview_bottom = 1

" -------------------------------------------------------------
" netrw
" -------------------------------------------------------------

" Setup xdg-open as the tool to open urls whenever we can, if nothing is set up.
" This makes using 'gx' a little more sane environments outside of Gnome and
" KDE.
function! SetupBrowseX()
    if !exists("g:netrw_browsex_viewer")
        if executable("xdg-open")
            let g:netrw_browsex_viewer = "xdg-open"
        elseif executable("rundll32")
            " This is what netrw wants to use natively for Windows, but setting
            " it explicitly here will bypass the annoying message:
            "   ``Press <cr> to continue``
            let g:netrw_browsex_viewer = "rundll32 url.dll,FileProtocolHandler"
        endif
    endif
endfunction

augroup local_netrw
    autocmd!
    autocmd VimEnter * call SetupBrowseX()
augroup END

" Get selected text in visual mode.  Taken from xolox's answer in
" <http://stackoverflow.com/a/6271254/683080>.
function! s:GetSelectedText()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

if g:Python != ''
    " Turn off netrw's gx.
    let g:netrw_nogx = 1

    function! ExtractUrl(text)
    execute g:Python . ' << endpython'
import re
text = vim.eval("a:text")
vim.command("let l:result = ''")

# Regex from:
#   <http://daringfireball.net/2010/07/improved_regex_for_matching_urls>
# Updated version:
#   <https://gist.github.com/gruber/249502/>
urlRe = re.compile(
    r"(?i)\b("
    r"(?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|"
        r"[a-z0-9.\-]+[.][a-z]{2,4}/)"
    r"(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+"
    r"(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|"
        r"""[^\s`!()\[\]{};:'".,<>?"""
             u"\u00AB\u00BB\u201C\u201D\u2018\u2019]"
        r""")"""
    r")")

m = urlRe.search(text)
if m:
    vim.command("let l:result = '" + m.group(1).replace("'", "''") + "'")
endpython

        return l:result
    endfunction

    function! s:SmartOpen(mode) range
        if a:mode ==# 'n'
            let uri = ExtractUrl(expand("<cWORD>"))
            if uri == ""
                return
            endif
        else
            let uri = s:GetSelectedText()
        endif

        try
            " In Vim v7.4.567, `netrw#NetrwBrowseX()` was renamed to
            " `netrw#BrowseX()`, at the same time as the function
            " `netrw#CheckIfRemote()` was introduced.  Use the existence of
            " `netrw#CheckIfRemote()` to indicate which browse function to call.
            call netrw#CheckIfRemote(uri)
            call netrw#BrowseX(uri, 0)
        catch
            call netrw#NetrwBrowseX(uri, 0)
        endtry
    endfunction

    nnoremap gx :call <SID>SmartOpen('n')<CR>
    xnoremap gx <C-c>:call <SID>SmartOpen('v')<CR>
endif

nnoremap <silent> <Leader>fe :Explore<CR>

" -------------------------------------------------------------
" OmniCppComplete
" -------------------------------------------------------------

" 'OmniCpp_SelectFirstItem'
"   0 ==> initially deselects first item in the menu.
"   1 ==> initially selects first item in the menu.
" default: let OmniCpp_SelectFirstItem = 0


" -------------------------------------------------------------
" Powerline
" -------------------------------------------------------------

" Detect if Powerline-related configuration is out-of-date such that
" we need to clear the cache.

" Determine "required" version of Powerline cached information.
" This may be set in |VIMRC_BEFORE| files for a per-user tag field; if
" not, the value defaults to "none".
" If you change any Powerline-related settings, update this variable
" to ensure the stale cached data will be deleted.  For example::
"   let g:PowerlineRequiredCacheTag = "2013-11-11"
if !exists("g:PowerlineRequiredCacheTag")
    let g:PowerlineRequiredCacheTag = "none"
endif

" Append Powerline cache tag for global vimrc settings.
" Generally, this will be a colon, the date, and optionally a dot and a one-up
" sequence number appended in case of multiple changes in a single day.
" E.g.:
"   :2013-11-11
"   :2013-11-11.1
" This vimfiles-wide setting will be appended to whatever value may have been
" set via a |VIMRC_BEFORE| file.
let g:PowerlineRequiredCacheTag .= ":2015-09-11"

" This file records the current Powerline "tag".
let g:PowerlineCacheTagFile = expand('$VIM_CACHE_DIR/PowerlineCacheTag')

" Location of desired Powerline cache directory.
let g:PowerlineDesiredCacheDir = expand('$VIM_CACHE_DIR/PowerlineCache')

" Write a tag to track the "version" of the Powerline cache.
function! PowerlineCacheTagWrite(tag)
    call writefile([a:tag], g:PowerlineCacheTagFile)
endfunction

" Read back the stored Powerline tag value.
" Return "" if not found or couldn't read.
function! PowerlineCacheTagRead()
    if filereadable(g:PowerlineCacheTagFile)
        let lines = readfile(g:PowerlineCacheTagFile, "", 1)
        if len(lines) == 1
            return lines[0]
        endif
    endif
    return ""
endfunction

if g:EnablePowerline
    " Nail down directory for Powerline's cache so we know where it lives.
    if !isdirectory(g:PowerlineDesiredCacheDir)
        call mkdir(g:PowerlineDesiredCacheDir, "p")
    endif
    if isdirectory(g:PowerlineDesiredCacheDir)
        " We've got a cache directory, so tell Powerline about it.
        let g:Powerline_cache_dir = g:PowerlineDesiredCacheDir
        if PowerlineCacheTagRead() != g:PowerlineRequiredCacheTag
            " Wipe out all Powerline cache files.
            for p in split(glob(g:Powerline_cache_dir .
                    \ "/Powerline_*.cache", 1), '\n')
                silent! call delete(p)
            endfor
            call PowerlineCacheTagWrite(g:PowerlineRequiredCacheTag)
        endif
    else
        echomsg "Why is " . g:PowerlineDesiredCacheDir . " not available?"
    endif
    " Remove segments that are redundant (like "mode_indicator") or
    " which are essentially static indicators that don't warrant taking
    " up room.
    call Pl#Theme#RemoveSegment('mode_indicator')
    call Pl#Theme#RemoveSegment('fileformat')
    call Pl#Theme#RemoveSegment('fileencoding')
    call Pl#Theme#RemoveSegment('filetype')

    " Move 'fileinfo' and 'syntastic:errors' after the Truncate() to keep the
    " basename of the file visible as long as possible.  If we start using
    " the Syntastic plugin, this may have to be adjusted so that syntastic
    " output is truncated first.  This preserves the order found in Powerline's
    " autoload/Powerline/Themes/default.vim file.
    call Pl#Theme#RemoveSegment('fileinfo')
    call Pl#Theme#InsertSegment('fileinfo', 'before', 'tagbar:currenttag')
    call Pl#Theme#RemoveSegment('syntastic:errors')
    call Pl#Theme#InsertSegment('syntastic:errors', 'before',
            \                   'tagbar:currenttag')

    " Add some non-default segments.

    " Indicate trailing whitespace in file.
    call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')

    " Provide short forms of mode names, if a user adds back in the
    " mode_indicator.
    let g:Powerline_mode_n = 'N'
    let g:Powerline_mode_i = 'I'
    let g:Powerline_mode_R = 'R'
    let g:Powerline_mode_v = 'V'
    let g:Powerline_mode_V = 'V⋅LINE'
    let g:Powerline_mode_cv = 'V⋅BLOCK'
    let g:Powerline_mode_s = 'SELECT'
    let g:Powerline_mode_S = 'S⋅LINE'
    let g:Powerline_mode_cs = 'S⋅BLOCK'
else
    " Powerline will not load if this variable is defined:
    let g:Powerline_loaded = 1
endif

" -------------------------------------------------------------
" Project
" -------------------------------------------------------------

" 'g:proj_window_width'
"   Width of project window (default 24).
" 'g:proj_window_increment'
"   Increment by which to increase Window when pressing <Space> (default 100).

" Remove 'b' flag from default 'imstb' to turn off broken browse()-based
" directory selection on Linux.
" g:proj_flags meanings (subset of flags - see help for others):
"   b - use browse() for dirs (bad on Windows, Linux).
"   c - close Project Window when selecting a file.
"   F - float Project Window.
"   g - create <F12> mapping for toggling Project Window.
"   i - display filename and working directory in command line.
"   m - modify CTRL-w_o to keep Project Window visible too.
"   s - use syntax highlighting in Project Window.
"   S - sorting for refresh and create.
"   t - toggle size of window instead of increase-only.
"   T - put subproject folds at top of fold when refreshing.
"   v - use vimgrep instead of grep.
let g:proj_flags = 'csStTv'
let g:proj_window_width = 40
nmap <silent> <F8>        <Plug>ToggleProject
nmap <silent> <C-q><C-p>  <Plug>ToggleProject
nmap <silent> <C-q>p      <Plug>ToggleProject
nmap <silent> <Space>qp   <Plug>ToggleProject

" -------------------------------------------------------------
" Quickfix-reflector
" -------------------------------------------------------------

" Join changes within each buffer for easier :undo.
let g:qf_join_changes = 1
augroup local_quickfix_reflector
    "First, remove all autocmds in this group.
    autocmd!

    " New QuickFix results have arrived.  By definition, the user has not yet
    " edited the contents of the QuickFix buffer, but because Vim tries to reuse
    " QuickFix buffers, any pre-existing "modified" status will be carried over
    " for these new results.  Quickfix-reflector's BufReadPost autocmd invokes
    " its OnWrite() function in an attempt to set the buffer's filename.  When
    " the buffer's status is "nomodified", this function does nothing;
    " unfortunately, if "modified" is carried over from a previous buffer,
    " exceptions are thrown and bad things happen; therefore, we clear
    " "modified" to avoid problems.
    " (Ideally, Quickfix-reflector would ":set nomodified" itself.)
    autocmd BufReadPost quickfix set nomodified
augroup END

" -------------------------------------------------------------
" Rainbow Parentheses
" -------------------------------------------------------------

" Adapt rainbow parentheses colors for background color.
" TODO this is not fully dynamic; the colors become permanent when the
" plugin first loads.
function! AdaptRainbow()
    if &background == "dark"
        let g:rbpt_colorpairs = g:rbpt_colorpairs_dark
    else
        let g:rbpt_colorpairs = g:rbpt_colorpairs_light
    endif
    let g:rbpt_max = len(g:rbpt_colorpairs)
endfunction

if &t_Co >= 256 || has("gui_running")
    let g:rbpt_colorpairs_dark = [
            \ [129,         'purple'],
            \ ['magenta',   'magenta1'],
            \ [111,         'slateblue1'],
            \ ['cyan',      'cyan1'],
            \ [48,          'springgreen1'],
            \ ['green',     'green1'],
            \ [154,         'greenyellow'],
            \ ['yellow',    'yellow1'],
            \ [214,         'orange1'],
            \ ]
    " TODO Choose better light-background colors for rainbow parentheses.
    let g:rbpt_colorpairs_light = [
            \ [129,         'purple'],
            \ ['magenta',   'magenta1'],
            \ [111,         'slateblue1'],
            \ ['cyan',      'cyan1'],
            \ [48,          'springgreen1'],
            \ ['green',     'green1'],
            \ [154,         'greenyellow'],
            \ ['yellow',    'yellow1'],
            \ [214,         'orange1'],
            \ ]
else
    let g:rbpt_colorpairs_dark = [
            \ ['magenta',   'purple'],
            \ ['cyan',      'magenta1'],
            \ ['green',     'slateblue1'],
            \ ['yellow',    'cyan1'],
            \ ['red',       'springgreen1'],
            \ ['magenta',   'green1'],
            \ ['cyan',      'greenyellow'],
            \ ['green',     'yellow1'],
            \ ['yellow',    'orange1'],
            \ ]
    " TODO Choose better light-background colors for rainbow parentheses.
    let g:rbpt_colorpairs_light = [
            \ ['magenta',   'purple'],
            \ ['cyan',      'magenta1'],
            \ ['green',     'slateblue1'],
            \ ['yellow',    'cyan1'],
            \ ['red',       'springgreen1'],
            \ ['magenta',   'green1'],
            \ ['cyan',      'greenyellow'],
            \ ['green',     'yellow1'],
            \ ['yellow',    'orange1'],
            \ ]
endif
call AdaptRainbow()

" Adapt colors of rainbow parentheses when colorscheme changes.
augroup local_rainbow
    autocmd!
    autocmd ColorScheme * call AdaptRainbow()
augroup END


" -------------------------------------------------------------
" RunView
" -------------------------------------------------------------

" Setup Bash as default view to run.
let g:runview_filtcmd="bash"


" -------------------------------------------------------------
" Session
" -------------------------------------------------------------

let g:session_directory = $VIM_CACHE_DIR . '/sessions'
let g:session_autoload = 'yes'
let g:session_autosave = 'no'
let g:session_verbose_messages = 0
let g:session_command_aliases = 1
let g:session_persist_font = 0

" Lifted from session.
function! s:unescape(s)
    " Undo escaping of special characters (preceded by a backslash).
    let s = substitute(a:s, '\\\(.\)', '\1', 'g')
    " Expand any environment variables in the user input.
    let s = substitute(s, '\(\$[A-Za-z0-9_]\+\)', '\=expand(submatch(1))', 'g')
    return s
endfunction

function! SaveSessionNoDefault(name, bang, command) abort
    " Normally, don't let session save to the default session, unless:
    "   * The session is already active, or
    "   * The user ran the command with '!', or
    "   * The default session already exists.
    if a:bang != '!'
        let name = s:unescape(a:name)
        if empty(name)
            let name = xolox#session#find_current_session()
        endif
        if empty(name)
            let defaultSessionFound = 0
            for session in xolox#session#get_names(0)
                if session ==? g:session_default_name
                    let defaultSessionFound = 1
                    break
                endif
            endfor
            if defaultSessionFound != 1
                call xolox#misc#msg#warn("Please provide a session name.")
                return
            endif
        endif
    endif

    call xolox#session#save_cmd(a:name, a:bang, a:command)
endfunction

function! OverrideSaveSession()
    command! -bar -bang -nargs=?
            \ -complete=customlist,xolox#session#complete_names
            \ SaveSession
            \ call SaveSessionNoDefault(<q-args>, <q-bang>, 'SaveSession')
    if g:session_command_aliases
        command! -bar -bang -nargs=?
                \ -complete=customlist,xolox#session#complete_names
                \ SessionSave
                \ call SaveSessionNoDefault(
                \   <q-args>, <q-bang>, 'SessionSave')
    endif
endfunction

augroup local_session
    autocmd!
    autocmd VimEnter * call OverrideSaveSession()
augroup END

" -------------------------------------------------------------
" Signature
" -------------------------------------------------------------

" Disable toggling of marks and markers.
let g:SignatureForceMarkPlacement = 1
let g:SignatureForceMarkerPlacement = 1

" Disable maps that hide valuable Vim built-in functionality for jumping to
" the start or end of recent yanks or changes:
"   '[, '], `[, and `]
" To restore this functionality, unlet g:SignatureMap in your vimrc-after.vim
" file.
let g:SignatureMap = {
        \ 'GotoNextLineAlpha'  :  "",
        \ 'GotoPrevLineAlpha'  :  "",
        \ 'GotoNextSpotAlpha'  :  "",
        \ 'GotoPrevSpotAlpha'  :  "",
        \ }

" -------------------------------------------------------------
" Syntastic
" -------------------------------------------------------------

function! SyntasticBufferMode(...)
    if a:0 == 0
        let bufferMode = GetVar("b:syntastic_mode", "inherited")
        echo "Buffer mode=" . bufferMode
    else
        let bufferMode = a:1
        if ListContains(split("active passive inherited"), bufferMode)
            if bufferMode == "inherited"
                unlet! b:syntastic_mode
            else
                let b:syntastic_mode = bufferMode
            endif
            SyntasticReset
        else
            echoerr "Invalid mode " . bufferMode
        endif
    endif
endfunction

function! SyntasticBufferModeComplete(argLead, cmdLine, cursorPos)
    return "active\npassive\ninherited"
endfunction

command! -n=? -bar -complete=custom,SyntasticBufferModeComplete
        \ SyntasticBufferMode call SyntasticBufferMode(<f-args>)


function! SyntasticBufferChecking(...)
    if a:0 == 0
        if !exists("b:syntastic_skip_checks")
            let checkingMode = "inherited"
        else
            let checkingMode = b:syntastic_skip_checks ? "off" : "on"
        endif
        echo "Buffer checking=" . checkingMode
    else
        let checkingMode = a:1
        if ListContains(split("on off inherited"), checkingMode)
            if checkingMode == "inherited"
                unlet! b:syntastic_skip_checks
            else
                let b:syntastic_skip_checks = (checkingMode == "off")
                if b:syntastic_skip_checks
                    SyntasticReset
                endif
            endif
        else
            echoerr "Invalid argument " . checkingMode
        endif
    endif
endfunction

function! SyntasticBufferCheckingComplete(argLead, cmdLine, cursorPos)
    return "on\noff\ninherited"
endfunction

command! -n=? -bar -complete=custom,SyntasticBufferCheckingComplete
        \ SyntasticBufferChecking call SyntasticBufferChecking(<f-args>)


" Sadly, if b:syntastic_quiet_messages is defined, Syntastic will completely
" ignore g:syntastic_quiet_messages rather than merging the two dictionaries
" together and giving priority to the buffer-local keys.  This means we can't
" truly provide an "inherited" functionality for each key.  Instead, the first
" time the buffer-local dictionary is required, we copy the global dictionary in
" its entirety.  Any changed made to the buffer-local dictionary work as
" expected, except that settings intended to make a given key be "inherited"
" simply copy the current setting from the global dictionary into the
" buffer-local dictionary.  Subsequent changes to the global settings will not
" automatically be reflected into the buffer-local settings.

function! SyntasticBufferQuietMessages()
    let qm = GetVar("b:syntastic_quiet_messages",
            \ deepcopy(g:syntastic_quiet_messages))
    return qm
endfunction

function! SyntasticBufferQuietGet(varName, defaultValue)
    let qm = SyntasticBufferQuietMessages()
    return DictGet(qm, a:varName, a:defaultValue)
endfunction

function! SyntasticBufferQuietSet(varName, strValue)
    let qm = SyntasticBufferQuietMessages()
    " Unlet to avoid errors if we are changing the variable's type.
    call DictUnlet(qm, a:varName)
    let qm[a:varName] = a:strValue
    let b:syntastic_quiet_messages = qm
endfunction

function! SyntasticBufferQuietInherit(varName)
    let qm = SyntasticBufferQuietMessages()
    if has_key(g:syntastic_quiet_messages, a:varName)
        let qm[a:varName] = g:syntastic_quiet_messages[a:varName]
    else
        call DictUnlet(qm, a:varName)
    endif
    let b:syntastic_quiet_messages = qm
endfunction

function! SyntasticBufferQuietIsInherited(varName)
    let gqm = g:syntastic_quiet_messages
    let bqm = SyntasticBufferQuietMessages()
    let ghk = has_key(gqm, a:varName)
    let bhk = has_key(bqm, a:varName)
    if ghk != bhk
        " One has the key, the other doesn't ==> not inherited.
        return 0
    elseif !ghk
        " Neither one has the key ==> inherited.
        return 1
    else
        " Both have the key ==> inherited if the values are the same.
        return type(gqm[a:varName]) == type(bqm[a:varName]) &&
                \ gqm[a:varName] == bqm[a:varName]
    endif
endfunction


function! SyntasticBufferIgnoreLevel(...)
    if a:0 == 0
        let level = SyntasticBufferQuietGet("level", "")
        if type(level) == type([])
            if level == []
                let levelString = ""
            elseif level == ["warning"]
                let levelString = "warning"
            else
                " This ignores cases where level is a list containing both
                " "warning" and "error", but in those cases it's equivalent to
                " just disabling checking entirely, which would be much more
                " efficient.  We presume nobody is doing that.
                let levelString = "error"
            endif
            unlet level
            let level = levelString
        endif
        if level == ""
            let level = "nothing"
        endif
        if SyntasticBufferQuietIsInherited("level")
            let level = level . " [inherited]"
        endif
        echo "Buffer ignore level=" . level
    else
        let level = a:1
        if ListContains(split("warnings errors nothing inherited"), level)
            if level == "inherited"
                call SyntasticBufferQuietInherit("level")
            else
                if level == "nothing"
                    let level = ""
                endif
                call SyntasticBufferQuietSet("level", level)
            endif
            SyntasticReset
        else
            echoerr "Invalid level " . level
        endif
    endif
endfunction

function! SyntasticBufferIgnoreLevelComplete(argLead, cmdLine, cursorPos)
    return "warnings\nerrors\nnothing\ninherited"
endfunction

command! -n=? -bar -complete=custom,SyntasticBufferIgnoreLevelComplete
        \ SyntasticBufferIgnoreLevel
        \ call SyntasticBufferIgnoreLevel(<f-args>)


function! SyntasticBufferIgnoreRegex(...)
    if a:0 == 0
        let regex = SyntasticBufferQuietGet("regex", [])
        if type(regex) == type([])
            if regex == []
                let regexString = "<nothing>"
            else
                let regexString = regex[0]
            endif
            unlet regex
            let regex = regexString
        endif
        if SyntasticBufferQuietIsInherited("regex")
            let regex = regex . " [inherited]"
        endif
        echo "Ignore regex (use . for <nothing>, .. to inherit): " . regex
    else
        let regex = a:1
        if regex == ".."
            call SyntasticBufferQuietInherit("regex")
        elseif regex == "."
            call SyntasticBufferQuietSet("regex", [])
        else
            call SyntasticBufferQuietSet("regex", regex)
        endif
        SyntasticReset
    endif
endfunction

function! SyntasticBufferIgnoreRegexComplete(argLead, cmdLine, cursorPos)
    let regex = SyntasticBufferQuietGet("regex", "..")
    if type(regex) == type("") && regex == ""
        let regex = "."
    endif
    return regex
endfunction

command! -n=? -complete=custom,SyntasticBufferIgnoreRegexComplete
        \ SyntasticBufferIgnoreRegex
        \ call SyntasticBufferIgnoreRegex(<f-args>)


" category is one of: "active", "passive", "default"
" ... is a list of filetypes; "*" means "all" (for use with "default" category).
function! SyntasticFiletypeCommand(category, ...)
    let mm = GetVar("g:syntastic_mode_map", {})
    let cats = {}
    let cats["active"] = uniq(sort(DictGet(mm, "active_filetypes", [])))
    let cats["passive"] = uniq(sort(DictGet(mm, "passive_filetypes", [])))
    let cats["default"] = []
    if len(a:000) == 0
        echo a:category . ": " . join(cats[a:category], " ")
        return
    endif
    for ftype in a:000
        call add(cats[a:category], ftype)
        for c in keys(cats)
            " TODO: This is not quite right, but it's close.  This is the
            " right semantic for changing "default", because it will clear
            " everybody else.  It's also correct when the Syntastic mode
            " matches a:category, but it's not right when the command goes
            " the other way (e.g., when mode is passive and "active" is set
            " to "*", which ought to put all known filetypes into the "active"
            " list).  Revisit this if it proves that this case is valuable.
            " The main use case here is to set "default" to "*", clearing
            " out the lists.
            if ftype == "*"
                let cats[c] = []
            elseif c != a:category
                let cats[c] = filter(cats[c], 'v:val != ftype')
            endif
        endfor
    endfor
    let mm["active_filetypes"] = uniq(sort(cats["active"]))
    let mm["passive_filetypes"] = uniq(sort(cats["passive"]))
    let g:syntastic_mode_map = mm
endfunction

command! -n=* -bar SyntasticFiletypeActive
        \ call SyntasticFiletypeCommand("active", <f-args>)

command! -n=* -bar SyntasticFiletypePassive
        \ call SyntasticFiletypeCommand("passive", <f-args>)

command! -n=* -bar SyntasticFiletypeDefault
        \ call SyntasticFiletypeCommand("default", <f-args>)

" Python's "future" package imports some builtins that aren't always used, but
" it's important to import the entire list to avoid the evils of
" "from builtins import *" and to avoid the maintenance problems of adding
" and removing modules from the import line.

" List of imports that should be ignored by Flake8.
let g:Flake8IgnoredImports = split(
        \ 'ascii bytes chr dict filter hex input ' .
        \ 'int map next oct open pow range round ' .
        \ 'str super zip')

" Convert list of unused imports into ignore regex.
function! Flake8IgnoredImportsRegex(unused_imports)
    let rex = '\<\(' . join(a:unused_imports, '\|')  . '\)\>.*\[F401\]'
    return rex
endfunction

function! SyntasticBufferSetup(style)
    let unknownCombination = 0
    let setupFunc = "SyntasticBufferSetup_" . &filetype . "_" . a:style
    if exists("*" . setupFunc)
        echomsg "found setupFunc = " . setupFunc
        call {setupFunc}()
    elseif a:style == "inherited"
        SyntasticBufferIgnoreLevel inherited
        SyntasticBufferIgnoreRegex ..
        unlet! b:syntastic_checkers
    elseif &filetype == "ruby"
        let b:syntastic_checkers = ["mri", "rubocop"]
    elseif &filetype == "python"
        setlocal tw=79
        let regex = Flake8IgnoredImportsRegex(g:Flake8IgnoredImports)
        " "E203 whitespace before ':'" goes against PEP8.
        " "W503" enforces breaking after operator, which goes against PEP8's
        " current (weak) recommendation to break before operators.
        if regex != ''
            let regex .= '\|'
        endif
        let regex .= '\[\(E203\|W503\)\]'
        if a:style == "very_strict"
            SyntasticBufferIgnoreLevel nothing
            execute 'SyntasticBufferIgnoreRegex ' . regex
            let b:syntastic_checkers = ["python", "flake8", "pylint"]
        elseif a:style == "strict" || a:style == "strict_except_case"
            SyntasticBufferIgnoreLevel nothing
            let b:syntastic_checkers = ["python", "flake8"]
            if a:style == "strict_except_case"
                " Ignore flake8 warnings about lowerMixedCase names.
                if regex != ''
                    let regex .= '\|'
                endif
                let regex .= '\[\(N802\|N803\|N806\)\]'
            endif
            execute 'SyntasticBufferIgnoreRegex ' . regex
        elseif a:style == "lax"
            setlocal tw=80
            SyntasticBufferIgnoreLevel nothing
            SyntasticBufferIgnoreRegex .
            let b:syntastic_checkers = ["python"]
        else
            let unknownCombination = 1
        endif
    else
        let unknownCombination = 1
    endif
    if unknownCombination
        echoerr "Unknown setup type '" . a:style .
                \ "' for filetype '" . &filetype . "'"
    else
        SyntasticReset
    endif
endfunction

function! SyntasticBufferSetupComplete(argLead, cmdLine, cursorPos)
    return "very_strict\nstrict\nstrict_except_case\nlax\ninherited"
endfunction

command! -n=1 -bar -complete=custom,SyntasticBufferSetupComplete
        \ SyntasticBufferSetup
        \ call SyntasticBufferSetup(<f-args>)


if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    let g:syntastic_error_symbol='✘'
    let g:syntastic_warning_symbol='⚠'
endif

let g:syntastic_enable_balloons = 1
let g:syntastic_enable_highlighting = 0

" Options:
"   " Disable warnings globally.
"   let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_quiet_messages = {}

" 0: no automatic open or close of the location list.
" 1: automatically open and close the location list.
" 2: automatically close but not open the location list.
" Note: Setting to 1 (auto-open/close) causes problems toggling the location
" list via :lclose when the location list is focused.  It works when another
" window is focused, though.  Using LocListWinToggle works because it uses
" :noautocmd lclose.  Someday we may look into Syntastic more closely to see if
" its logic can change to avoid this problem.
let g:syntastic_auto_loc_list = 2
let g:syntastic_always_populate_loc_list = 1

" Remove pylint from Syntastic's default list of checkers (it's too picky).
let g:syntastic_python_checkers = ['python', 'flake8']

let g:syntastic_rst_rst2pseudoxml_quiet_messages = { 'level': [] }
let g:syntastic_rst_rstsphinx_quiet_messages = { 'level': [] }
let g:syntastic_rst_rstsphinx_args_before = '-j ' . NumCpus()

function! ReplacePowerlineSyntastic()
    if !g:EnablePowerline || !g:EnableSyntastic
        return
    endif
    function! Powerline#Functions#syntastic#GetErrors(line_symbol) " {{{
        if ! exists('g:syntastic_stl_format')
            " Syntastic hasn't been loaded yet
            return ''
        endif

        " Temporarily change syntastic output format
        let old_stl_format = g:syntastic_stl_format
        if exists('g:Powerline_syntastic_stl_format')
            let g:syntastic_stl_format = g:Powerline_syntastic_stl_format
        else
            let g:syntastic_stl_format = '%E{%ee}%B{ }%W{%ww}'
        endif

        let ret = SyntasticStatuslineFlag()

        let g:syntastic_stl_format = old_stl_format

        return ret
    endfunction " }}}
endfunction

function! SyntasticFinalSetup()
    let g:syntastic_loc_list_height = g:LocListWinHeight
    call ReplacePowerlineSyntastic()
endfunction

" Consider these for inclusion in active_filetypes:
"   c cpp go haskell html javascript less sh vim zsh
let g:syntastic_mode_map = {
        \ 'mode': 'passive',
        \ 'active_filetypes': ['python', 'ruby', 'rst'],
        \ 'passive_filetypes': []
        \ }

augroup local_syntastic
    autocmd!
    autocmd VimEnter * call SyntasticFinalSetup()
augroup END

" -------------------------------------------------------------
" surround
" -------------------------------------------------------------

" Use `S` (ASCII code 83) as a custom character to surround with
" double-backticks (especially useful for reStructuredText).
" The carriage return (`\r`) is where the surrounded text will land.
" See `:help surround-customizing` for details.
let g:surround_83 = "``\r``"

" -------------------------------------------------------------
" Tagbar
" -------------------------------------------------------------

" Must have ctags of some kind or keep plugin from running.
if !exists('g:tagbar_ctags_bin') && exists('g:Local_ctags_bin')
    let g:tagbar_ctags_bin = g:Local_ctags_bin
endif
let usingTagbar = exists('g:tagbar_ctags_bin')
if !usingTagbar
    " Tagbar doesn't actually care about the value... only the existence
    " of the variable.
    let g:loaded_tagbar = 'no'
endif

" Tagbar settings
let g:tagbar_width = 40
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0

nnoremap <silent> <S-F8>     :TagbarToggle<CR>
nnoremap <silent> <C-q><C-t> :TagbarToggle<CR>
nnoremap <silent> <C-q>t     :TagbarToggle<CR>
nnoremap <silent> <Space>qt  :TagbarToggle<CR>

" Support for reStructuredText, if available.
if executable("rst2ctags")
    let g:rst2ctags = 'rst2ctags'
else
    let g:rst2ctags = $VIMFILES . '/tool/rst2ctags/rst2ctags.py'
endif

" Local tagbar settings.  Assign g:tagbar_type_rst to this value to enable
" support for .rst files in tagbar.
let g:local_tagbar_type_rst = {
        \ 'ctagstype': 'rst',
        \ 'ctagsbin' : g:rst2ctags,
        \ 'ctagsargs' : '-f - --sort=yes --sro=»',
        \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
        \ ],
        \ 'sro' : '»',
        \ 'kind2scope' : {
        \ 's' : 'section',
        \ },
        \ 'sort': 0,
        \ }

" Enable support for .rst files in tagbar by default.  Disable if desired in
" your |VIMRC_AFTER| file via:
"   unlet g:tagbar_type_rst.
let g:tagbar_type_rst = g:local_tagbar_type_rst

" Support for markdown, if available.
if executable("markdown2ctags")
    let g:markdown2ctags = 'markdown2ctags'
else
    let g:markdown2ctags = $VIMFILES . '/tool/markdown2ctags/markdown2ctags.py'
endif

" Local tagbar settings.  Assign g:tagbar_type_markdown to this value to enable
" support for markdown files in tagbar.
let g:local_tagbar_type_markdown = {
        \ 'ctagstype': 'markdown',
        \ 'ctagsbin' : g:markdown2ctags,
        \ 'ctagsargs' : '-f - --sort=yes --sro=»',
        \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
        \ ],
        \ 'sro' : '»',
        \ 'kind2scope' : {
        \ 's' : 'section',
        \ },
        \ 'sort': 0,
        \ }

" Enable support for markdown files in tagbar by default.  Disable if desired in
" your |VIMRC_AFTER| file via:
"   unlet g:tagbar_type_markdown.
let g:tagbar_type_markdown = g:local_tagbar_type_markdown

" -------------------------------------------------------------
" tcomment
" -------------------------------------------------------------

" Don't comment blank lines.
let g:tcomment#blank_lines = 0

" Turn off the <C-_> and <Leader>_ mappings.
let g:tcomment_mapleader1 = ''
let g:tcomment_mapleader2 = ''

" Setup better linewise comments for Java.
let g:tcomment_types = {
        \ 'java': '// %s',
        \ 'kscript': '# %s',
        \ }

" -------------------------------------------------------------
" textobj-diff
" -------------------------------------------------------------

" Don't use the many default global mappings.
let g:textobj_diff_no_default_key_mappings = 1

" Create buffer-local mappings for desired functionality.
function! CreateTextobjDiffLocalMappings()
    " Make file- and hunk-selection mappings for diffs.
    for m in ['x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute cmd . 'adf <Plug>(textobj-diff-file)'
        execute cmd . 'idf <Plug>(textobj-diff-file)'
        execute cmd . 'adh <Plug>(textobj-diff-hunk)'
        execute cmd . 'idh <Plug>(textobj-diff-hunk)'
    endfor
    " Map ]] and friends to textobj-diff for jumping between hunks.
    for m in ['n', 'x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute cmd . '[] <Plug>(textobj-diff-hunk-P)'
        execute cmd . ']] <Plug>(textobj-diff-hunk-n)'
        execute cmd . '[[ <Plug>(textobj-diff-hunk-p)'
        execute cmd . '][ <Plug>(textobj-diff-hunk-N)'
    endfor
endfunction


" -------------------------------------------------------------
" UltiSnips
" -------------------------------------------------------------

" Paths found earlier in runtimepath have higher snippet priority.
" In order to remove snippets distributed with UltiSnips, the
" directory "pre-bundle/clearsnippets" will be earlier in the
" runtimepath.

let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"

" Do not use UltiSnips's algorithm for removing select-mode mappings.  It
" should be restricted to just those mappings that start with printable
" characters, but it removes too much (so, for example, the desirable
" select-mode mapping for <M-z> gets unmapped).
let g:UltiSnipsRemoveSelectModeMappings = 0

" Use a:ultiSnipsSnippetDirectories as buffer-local value for UltiSnips's
" global g:ultiSnipsSnippetDirectories.  Typically invoked from a .lvimrc
" file as:
"   call SetLocalSnippetDirectories(["UltiSnips", "UltiSnips/Project"])
" where "UltiSnips/Project" will take precedence over snippets that live
" directly in "UltiSnips" directories.
function! SetLocalSnippetDirectories(ultiSnipsSnippetDirectories)
    let b:UltiSnipsSnippetDirectories = a:ultiSnipsSnippetDirectories
endfunction

" Helper to be called from your .lvimrc.
function! AppendSnippetDirs(snippetDirs)
    if !exists("b:UltiSnipsSnippetDirectories")
        let b:UltiSnipsSnippetDirectories = copy(g:UltiSnipsSnippetDirectories)
    endif

    if type(a:snippetDirs) == type([])
        let b:UltiSnipsSnippetDirectories += a:snippetDirs
    else
        let b:UltiSnipsSnippetDirectories += [a:snippetDirs]
    endif
endfunction

function! FindSnippetTemplate()
    " Searches for a template in this order:
    "
    " - template_<filetype>.<filename>
    " - template_<filetype>.<ext>, where <ext> is successively trimmed
    "   attempting to match the most specific extension.  For example,
    "   foo.snippets.py would result in looking for template_python.snippets.py
    "   followed by template_python.py.
    " - template_<filetype>
    "
    " As soon as a match is made, the snippet name is returned.  If nothing
    " matches, an empty string is returned.
    "
    " If the buffer has no name, we'll only look for template_<filetype>.  If
    " there's no filetype set for the buffer, we'll return an empty string since
    " it doesn't make sense to try and look up a template.
    let l:snippets = UltiSnips#SnippetsInCurrentScope()
    let l:filename = expand("%:t")

    " There's no use proceeding if there's no filetype set.
    if &filetype == ""
        return ""
    endif

    if len(l:filename) != 0
        let l:start = 0
        let l:idx = 0

        while l:idx >= 0
            let l:snippetName = "template_" . &filetype .
                    \ "." . strpart(l:filename, l:idx)

            if has_key(l:snippets, l:snippetName)
                return l:snippetName
            else
                let l:start = l:idx
                let l:idx = stridx(l:filename, ".", l:start+1)
                if l:idx >= 0
                    let l:idx = l:idx + 1
                endif
            endif
        endwhile
    endif

    let l:snippetName = "template_" . &filetype
    if has_key(l:snippets, l:snippetName)
        return l:snippetName
    endif

    return ""
endfunction

function! TriggerSnippetTemplate()
    " Looks for a snippet named "template_<filetype>.<ext>", and expands it
    " if it exists.  See FindSnippetTemplate() for details about the lookup.
    " The idea here is to provide a good default template for various file
    " types.
    let l:filename = expand("%:t")

    if len(l:filename) == 0
        return 0
    endif

    let l:snippetName = FindSnippetTemplate()
    if l:snippetName != ""
        startinsert
        call feedkeys(l:snippetName .
                \ eval('"\' . g:UltiSnipsExpandTrigger . '"'))
        return 1
    endif

    echo "No template found"
    return 0
endfunction

" Attempt the "skel" pseudo-snippet if a:skelPermitted.
" a:ultiResult comes from UltiSnips#ExpandSnippet() or
" UltiSnips#ExpandSnippetOrJump(); it will be returned unless "skel" succeeds.
function! TrySkel(skelPermitted, ultiResult)
    let result = a:ultiResult
    if a:skelPermitted && getline(".") == "skel"
        let curPos = getpos(".")
        call setline(".", "")
        if TriggerSnippetTemplate()
            " Skeleton found.
            let result = ""
        else
            " Didn't work; put back the line.
            call setline(".", "skel")
            call setpos(".", curPos)
        endif
    endif
    return result
endfunction

function! ExpandSnippetOrSkel()
    let ultiResult = UltiSnips#ExpandSnippet()
    return TrySkel(g:ulti_expand_res == 0, ultiResult)
endfunction

function! ExpandSnippetOrJumpOrSkel()
    let ultiResult = UltiSnips#ExpandSnippetOrJump()
    return TrySkel(g:ulti_expand_or_jump_res == 0, ultiResult)
endfunction

function! SetupUltiSnipsMapping()
    " Override the expand trigger mapping for UltiSnips to provide the
    " file skeleton functionality.

    " Break undo sequence via <C-g>u before expanding the trigger.
    let cmd = "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-g>u"
    if g:UltiSnipsExpandTrigger == g:UltiSnipsJumpForwardTrigger
        let cmd .= "<C-r>=ExpandSnippetOrJumpOrSkel()<CR>"
    else
        let cmd .= "<C-r>=ExpandSnippetOrSkel()<CR>"
    endif
    exec cmd
    inoremap <silent> <M-u><Tab> <C-r>=UltiSnips#JumpForwards()<CR>
    snoremap <silent> <M-u><Tab> <Esc>:call UltiSnips#JumpForwards()<CR>
    inoremap <silent> <M-u><M-l> <C-r>=UltiSnips#ListSnippets()<CR>
endfunction

if g:EnableUltiSnips && g:Python != ''
    function! EditSnippets()
        if exists("b:UltiSnipsSnippetDirectories")
            let l:snippetDirs = b:UltiSnipsSnippetDirectories
        elseif exists("g:UltiSnipsSnippetDirectories")
            let l:snippetDirs = g:UltiSnipsSnippetDirectories
        else
            let l:snippetDirs = ["UltiSnips"]
        endif

execute g:Python . ' << endpython'
import os.path
import re

primary_filetype = vim.eval("&ft")
filename = primary_filetype + '.snippets'
pyfilename = filename + '.py'

rtp = [os.path.realpath(os.path.expanduser(p))
        for p in vim.eval("&rtp").split(",")]

# Process them in reverse, because the UltiSnips uses the last one first.
snippetDirs = vim.eval("l:snippetDirs")

def pathContainsBundle(path):
    parts = set(re.split(r"[/\\]", path))
    if parts.intersection(vim.eval('g:vimf_bundle_dirnames')):
        return True
    return False

def searchForFile(filename):
    editPath = None
    for snippetDir in snippetDirs:
        if editPath is not None:
            break

        for p in rtp:
            if pathContainsBundle(p):
                continue

            fullPath = os.path.join(p, snippetDir, filename)
            if os.path.exists(fullPath):
                editPath = fullPath
                break
    return editPath

path = searchForFile(pyfilename)
if path is None:
    # Hunt down a good location to put the snippets file.
    for p in rtp:
        if path is not None:
            break

        if pathContainsBundle(p):
            continue

        for snippetDir in snippetDirs:
            fullPath = os.path.join(p, snippetDir)
            if os.path.exists(fullPath):
                path = fullPath
                break

        if path:
            path = os.path.join(path, pyfilename)

if path is None:
    # Something is very wrong here.  We should at least have an
    # UltiSnips at the root of the VIMFILES area.
    vim.command("let filename = ''")
else:
    vim.command("let filename = '%s'" % path.replace("'", "''"))
endpython

        if l:filename == ""
            echoerr "Could not find a suitable location to "
                    \ . "create snippets file."
        else
            exec 'e ' . l:filename
        endif
    endfunction
    command! EditSnippets :call EditSnippets()
endif

if g:EnableUltiSnips
    augroup local_ultisnips
        autocmd!

        " Wait until all initialization is complete, then override mappings.
        autocmd VimEnter * call SetupUltiSnipsMapping()
    augroup END
else
    " UltiSnips will not load if this variable is defined:
    let g:did_plugin_ultisnips = 1
endif

" -------------------------------------------------------------
" Unicode
" -------------------------------------------------------------

let g:Unicode_data_directory = expand('$VIMFILES/bundle/unicode')

" Avoid default mappings, then put in just the ones we support.
let g:Unicode_no_default_mappings = 1

" nmap <F4> <Plug>(MakeDigraph)
" vmap <F4> <Plug>(MakeDigraph)
imap <C-X><C-G> <Plug>(DigraphComplete)
imap <C-X><C-Z> <Plug>(UnicodeComplete)
imap <C-X><C-B> <Plug>(HTMLEntityComplete)
" imap <C-G><C-F> <Plug>(UnicodeFuzzy)
nmap <leader>un <Plug>(UnicodeSwapCompleteName)
nmap ga <Plug>(UnicodeGA)

" -------------------------------------------------------------
" vim-lsp
" -------------------------------------------------------------

" Uncomment to generate `vim-lsp` logs:
" let g:lsp_log_file = '/tmp/vim-lsp.log'

" Python support:
if !exists('g:EnableVimLsp_pylsp')
    let g:EnableVimLsp_pylsp = 1
endif
if !g:EnableVimLsp || !executable('pylsp')
    let g:EnableVimLsp_pylsp = 0
endif
" Any kind of Python support:
let g:EnableVimLsp_python = g:EnableVimLsp_pylsp


" C/C++ support:
if !exists('g:EnableVimLsp_clangd')
    let g:EnableVimLsp_clangd = 1
endif
if !g:EnableVimLsp || !executable('clangd')
    let g:EnableVimLsp_clangd = 0
endif
" Any kind of C/C++ support:
let g:EnableVimLsp_c = g:EnableVimLsp_clangd

" Rust support:
if !exists('g:EnableVimLsp_rust_analyzer')
    let g:EnableVimLsp_rust_analyzer = 1
endif
if !g:EnableVimLsp || !executable('rust-analyzer')
    let g:EnableVimLsp_rust_analyzer = 0
endif

if !exists('g:EnableVimLsp_rls')
    let g:EnableVimLsp_rls = 1
endif
" Prefer rust-analyzer to rls:
if !g:EnableVimLsp || !executable('rls') || g:EnableVimLsp_rust_analyzer
    let g:EnableVimLsp_rls = 0
endif

" Any kind of Rust support:
let g:EnableVimLsp_rust = g:EnableVimLsp_rust_analyzer || g:EnableVimLsp_rls

" Zig support:
if !exists('g:EnableVimLsp_zls')
    let g:EnableVimLsp_zls = 1
endif
if !g:EnableVimLsp || !executable('zls')
    let g:EnableVimLsp_zls = 0
endif
" Any kind of Zig support:
let g:EnableVimLsp_zig = g:EnableVimLsp_zls

" Configuration for Python LSP plugins:
let g:local_pylsp_plugins = {}

if executable("python3")
    let g:local_mypy_python_executable = "python3"
else
    let g:local_mypy_python_executable = "python"
endif

" `pylsp_mypy` settings:
let g:local_pylsp_plugins['pylsp_mypy'] = {
        \  'enabled': g:local_true,
        \}

" Except on Windows, use a work-around to instruct `mypy` to use the
" first-found Python interpreter on `PATH`, allowing a globally installed
" `mypy` to correctly locate dependent Python modules in an activated venv.
" `overrides` provides additional `mypy` command-line arguments.
" `g:local_true` means "insert other arguments here".
if !has('win32')
    let g:local_pylsp_plugins['pylsp_mypy']['overrides'] = [
            \  '--python-executable',
            \  g:local_mypy_python_executable,
            \  g:local_true
            \]
endif

" `ruff` settings:
let g:local_pylsp_plugins['ruff'] = {
        \  'enabled': g:local_true,
        \  'formatEnabled': g:local_true,
        \  'lineLength': 79,
        \}

" Configuration for Python LSP:
let g:local_pylsp_settings = {}
let g:local_pylsp_settings['name'] = 'pylsp'
let g:local_pylsp_settings['cmd'] = ['pylsp']
" Uncomment to debug `pylsp`:
" let g:local_pylsp_settings['cmd'] =
"         \  ['pylsp', '-v', '--log-file', '/tmp/pylsp.log']
let g:local_pylsp_settings['allowlist'] = ['python']
let g:local_pylsp_settings['workspace_config'] = {
        \  'pylsp': {
        \    'plugins': g:local_pylsp_plugins
        \  }
        \}

if g:EnableVimLsp
    let g:lsp_document_code_action_signs_enabled = 0

    " For any kind of python support:
    if g:EnableVimLsp_python
        " Python Language Server (pylsp) support:
        if g:EnableVimLsp_pylsp
            augroup local_lsp_pylsp
                autocmd!
                autocmd User lsp_setup call
                        \ lsp#register_server(g:local_pylsp_settings)
            augroup END
        endif

        " Use `vim-lsp` instead of other Python linters.
        let g:ale_linters['python'] = ['vim-lsp']
    endif

    " For any kind of C support:
    if g:EnableVimLsp_c
        call insert(g:ale_linters['c'], 'vim-lsp')
        call insert(g:ale_linters['cpp'], 'vim-lsp')
        " Clangd (C/C++) support:
        if g:EnableVimLsp_clangd
            augroup local_lsp_clangd
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                        \ 'name': 'clangd',
                        \ 'cmd': ['clangd'],
                        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
                        \ })
            augroup END
            " Remove linters that just get in the way when we have clangd.
            for s:lang in ['c', 'cpp']
                call filter(g:ale_linters[s:lang],
                        \ 'index(["cc", "clangtidy"], v:val) < 0')
            endfor
        endif
    endif

    " For any kind of rust support:
    if g:EnableVimLsp_rust
        " Rust-analyzer (preferred over rls when available):
        if g:EnableVimLsp_rust_analyzer
            augroup local_lsp_rls
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                        \ 'name': 'rust-analyzer',
                        \ 'cmd': {server_info->['rust-analyzer']},
                        \ 'allowlist': ['rust'],
                        \ })
            augroup END
        endif

        " Rust Language Server (rls) support:
        if g:EnableVimLsp_rls
            augroup local_lsp_rls
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                        \ 'name': 'rls',
                        \ 'cmd': ['rls'],
                        \ 'allowlist': ['rust'],
                        \ })
            augroup END
        endif
        " Remove "rls" (if present); prepend "vim-lsp":
        call filter(g:ale_linters['rust'], 'v:val != "rls"')
        call insert(g:ale_linters['rust'], "vim-lsp")
    endif

    " For any kind of Zig support:
    if g:EnableVimLsp_zig
        " Zig Language Server (zls) support:
        if g:EnableVimLsp_zls
            augroup local_lsp_zls
                autocmd!
                autocmd User lsp_setup call lsp#register_server({
                        \ 'name': 'zls',
                        \ 'cmd': ['zls'],
                        \ 'allowlist': ['zig'],
                        \ })
            augroup END
        endif

        " Remove "zls" (if present); prepend "vim-lsp":
        call filter(g:ale_linters['zig'], 'v:val != "zls"')
        call insert(g:ale_linters['zig'], "vim-lsp")
    endif

    " Experimental vim-lsp mappings:
    " Use <nop> mappings so that (ideally) nothing happens if a mapping is
    " mis-typed.  E.g., pressing <Space>lp0 doesn't have mapping, so it would
    " normally turn into <Space> (moving the cursor), l (moving right), p
    " (putting text), and 0 (move to start of line).  But after mapping
    " <Space>lp to <nop>, the <Space>lp gets eaten and only 0 is left.
    " nmap <Space>l       <nop>
    " nmap <Space>lg      <nop>
    nmap <Space>lgd     <plug>(lsp-definition)
    nmap <Space>lgD     <plug>(lsp-declaration)
    " nmap <Space>lp      <nop>
    nmap <Space>lpd     <plug>(lsp-peek-definition)
    nmap <Space>lpD     <plug>(lsp-peek-declaration)
    nmap <Space>lr      <plug>(lsp-references)
    nmap <Space>lR      <plug>(lsp-rename)
    nmap <Space>lh      <plug>(lsp-hover)
    nmap <Space>l=      <plug>(lsp-document-format)
    xmap <Space>l=      <plug>(lsp-document-range-format)
    " nmap <Space>l       <plug>(lsp-document-format)
    " vmap <Space>l       <plug>(lsp-document-format)
    " nmap <Space>l       <plug>(lsp-code-action)
    " nmap <Space>l       <plug>(lsp-code-lens)
    " nmap <Space>l       <plug>(lsp-document-symbol)
    " nmap <Space>l       <plug>(lsp-document-symbol-search)
    " nmap <Space>l       <plug>(lsp-document-diagnostics)
    " nmap <Space>l       <plug>(lsp-next-diagnostic)
    " nmap <Space>l       <plug>(lsp-next-diagnostic-nowrap)
    " nmap <Space>l       <plug>(lsp-next-error)
    " nmap <Space>l       <plug>(lsp-next-error-nowrap)
    " nmap <Space>l       <plug>(lsp-next-reference)
    " nmap <Space>l       <plug>(lsp-next-warning)
    " nmap <Space>l       <plug>(lsp-next-warning-nowrap)
    " nmap <Space>l       <plug>(lsp-preview-close)
    " nmap <Space>l       <plug>(lsp-preview-focus)
    " nmap <Space>l       <plug>(lsp-previous-diagnostic)
    " nmap <Space>l       <plug>(lsp-previous-diagnostic-nowrap)
    " nmap <Space>l       <plug>(lsp-previous-error)
    " nmap <Space>l       <plug>(lsp-previous-error-nowrap)
    " nmap <Space>l       <plug>(lsp-previous-reference)
    " nmap <Space>l       <plug>(lsp-previous-warning)
    " nmap <Space>l       <plug>(lsp-previous-warning-nowrap)
    " nmap <Space>l       <plug>(lsp-workspace-symbol)
    " nmap <Space>l       <plug>(lsp-workspace-symbol-search)
    " nmap <Space>l       <plug>(lsp-implementation)
    " nmap <Space>l       <plug>(lsp-peek-implementation)
    " nmap <Space>l       <plug>(lsp-type-definition)
    " nmap <Space>l       <plug>(lsp-peek-type-definition)
    " nmap <Space>l       <plug>(lsp-type-hierarchy)
    " nmap <Space>l       <plug>(lsp-status)
    " nmap <Space>l       <plug>(lsp-signature-help)
endif

" -------------------------------------------------------------
" vis
" -------------------------------------------------------------

" Enables the // command from visual block mode.
let g:vis_WantSlashSlash = 1

" -------------------------------------------------------------
" visswap
" -------------------------------------------------------------

" Change default CTRL-x to CTRL-t (for "trade") to avoid conflict
" with swapit plugin.
" @todo Consider other mappings...
xmap <silent> <C-t> <Plug>VisualSwap

" -------------------------------------------------------------
" vcscommand
" -------------------------------------------------------------

" Use \s for vcscommand sets.  This was originally done to avoid
" a conflict with EnhancedCommentify's \c and feels more like "svn".
let VCSCommandMapPrefix = '<Leader>s'

" When doing diff, force two-window layout with old on left.
nmap <silent> <Leader>sv :OneWindow<CR><Plug>VCSVimDiff<C-w>H<C-w>w

" -------------------------------------------------------------
" winmanager
" -------------------------------------------------------------

" :nnoremap <C-w><C-t>   :WMToggle<CR>
" :nnoremap <C-w><C-f>   :FirstExplorerWindow<CR>
" :nnoremap <C-w><C-b>   :BottomExplorerWindow<CR>

" -------------------------------------------------------------
" Zig
" -------------------------------------------------------------

" Don't automatically run ``zig fmt``:
let g:zig_fmt_autosave = 0

" =============================================================
" Neovim Setup
" =============================================================

if has('nvim')

if has('gui_running')
augroup vimf_nvim_gui
autocmd!

" The `'autoread'` feature does not work out-of-the-box for both `nvim-qt` and
" `neovide`:
" - <https://github.com/equalsraf/neovim-qt/issues/846>
" - <https://github.com/neovide/neovide/issues/1477>
"
" The `'autoread'` feature does work for `nvim`'s TUI.
"
" The reason it works for the TUI is mentioned in this now-closed Neovim issue:
" <https://github.com/neovim/neovim/issues/20082#issuecomment-1236324274>
" > No. I just noticed that neovide already triggers `FocusGained`, and that
" > triggering `FocusGained` from `:doautocmd` doesn't actually trigger a
" > timestamp check. With TUI a timestamp check is done the same time as
" > `FocusGained`, but it is not an autocommand callback, but something
" > triggered the same time as the autocommand.
"
" In that issue, Neovim maintainer @justinmk has commented on the `'autoread'`
" feature:
" <https://github.com/neovim/neovim/issues/20082#issuecomment-1288913518>
" > As mentioned above, FocusGained can be used to opt-in to the behavior you
" > want.
" >
" > The general story of improving autoread is tracked in
" > <https://github.com/neovim/neovim/issues/1380>
"
" This refers to having GUI users add this to their configuration:
"
" ```vim
" autocmd FocusGained * checktime
" ```
"
" I can confirm that this work-around does restore the `'autoread'`
" functionality for me, with both GUIs.
"
" It's unclear to me whether there is a long-term plan to restore the
" `'autoread'` feature for Neovim GUIs users without requiring the above
" work-around.
autocmd FocusGained * checktime
augroup END
endif

" Use `execute` below to avoid having a `:lua` command inside the `if`, because
" even though the `if` predicate might be false, Vim still requires the `if`
" body to contain valid lines.
execute "lua require('vimf').setup()"
endif

" =============================================================
" Language and filetype setup
" =============================================================

set spelllang=en_us

" -------------------------------------------------------------
" Highlight setup
" -------------------------------------------------------------

" Define a nice highlighting color for matches.
" From Nuvola:
" highlight NonText gui=BOLD guifg=#4000FF guibg=#EFEFF7
"highlight HG_Background gui=BOLD guibg=#EFEFF7

" Return true if groupName exists.
"   Calling hlexists() ought to suffice, but it can return true even though
"   groupName has been cleared.  At startup, hlexists() correctly returns false
"   for a groupName that has never been defined, but any time after groupName
"   has been defined, hlexists() will be permanently stuck returning true,
"   even after ``:highlight clear`` has clobbered the group's definition.
"   The problem is that after ``:highlight clear``, the group still looks
"   defined, but it now has the inactive value "xxx cleared".
function! HighlightGroupExists(groupName)
    let haveGroup = 0
    if hlexists(a:groupName)
        redir => groupDef
        execute "silent highlight " . a:groupName
        redir END
        if groupDef !~# "xxx cleared$"
            let haveGroup = 1
        endif
    endif
    return haveGroup
endfunction

function! HighlightDefineGroups()
    if !HighlightGroupExists("HG_Subtle")
        if &background == "dark"
            " Same as ColorColumn.
            highlight HG_Subtle  ctermbg=234 guibg=#1c1c1c
        else
            highlight HG_Subtle  ctermbg=lightgrey guibg=#f0f0f0
        endif
    endif
    if !HighlightGroupExists("HG_Warning")
        if &background == "dark"
            highlight HG_Warning ctermfg=red  guifg=#ff0000
        else
            highlight HG_Warning ctermbg=lightgrey  guibg=#ffd0d0
        endif
    endif
endfunction

autocmd ColorScheme * call HighlightDefineGroups()
call HighlightDefineGroups()

" Default value for buffers without b:HighlightEnabled.
let g:HighlightEnabled = 1

let g:HighlightItems = split("commas keywordspace longlines tabs trailingspace")

function! HighlightRegex_longlines()
    if &textwidth == 0
        return ''
    endif
    return '\%>' . &textwidth . 'v.\+'
endfunction

let g:HighlightRegex_tabs = '\t'
let g:HighlightRegex_commas = ',\ze\S'
let g:HighlightRegex_keywordspace = '\(\<' . join(
        \ split('for if while switch'), '\|\<') . '\)\@<=('
let g:HighlightRegex_trailingspace = '\s\+\%#\@<!$'

" `b:highlight_groups` is a dictionary mapping from
" `groupName` to a `buf_match_id` from the `bufmatch` plugin.

" Setup groupName as a syntax match with the given pattern.
function! HighlightSyntaxMatch(groupName, pattern)
    if !exists('b:highlight_groups')
        let b:highlight_groups = {}
    endif
    " Remove any existing match.
    if has_key(b:highlight_groups, a:groupName)
        call bufmatch#MatchDelete(b:highlight_groups[a:groupName])
        unlet b:highlight_groups[a:groupName]
    endif
    " Add new match (if any).
    if a:pattern != ''
        " Choose a priority less than zero (the priority of search
        " highlighting).
        let priority = -10
        let buf_match_id = bufmatch#MatchAdd(a:groupName, a:pattern, priority)
        let b:highlight_groups[a:groupName] = buf_match_id
    endif
endfunction

" Invoke as: HighlightNamedRegex('longlines1', 'HG_Warning', 1)
" The linkedGroup comes from the highlight groups (:help highlight-groups),
" or from HighlightDefineGroups() above.
" Highlight groups to consider:
"   Error       very intrusive group with reverse-video red.
"   ErrorMsg    less intrusive, red foreground (invisible for whitespace).
"   NonText     non-intrusive, fairly subtle.
function! HighlightNamedRegex(regexName, linkedGroup, enable)
    let groupName = 'Highlight_' . a:regexName
    execute 'highlight link ' . groupName . ' ' . a:linkedGroup

    let patternName = 'HighlightRegex_' . a:regexName
    let pattern = ''
    if a:enable
        if exists('*' . patternName)
            " Named regex is a function; call it to get the pattern.
            let pattern = eval(patternName . '()')
        else
            " Named regex is a regular variable; use it as the pattern.
            let pattern = {'g:' . patternName}
        endif
    endif
    call HighlightSyntaxMatch(groupName, pattern)
endfunction

function! Highlight_commas(enable)
    call HighlightNamedRegex('commas', 'HG_Warning', a:enable)
endfunction

function! Highlight_keywordspace(enable)
    call HighlightNamedRegex('keywordspace', 'HG_Warning', a:enable)
endfunction

function! Highlight_longlines(enable)
    call HighlightNamedRegex('longlines', 'HG_Subtle', a:enable)
endfunction

function! Highlight_tabs(enable)
    call HighlightNamedRegex('tabs', 'HG_Subtle', a:enable)
endfunction

function! Highlight_trailingspace(enable)
    call HighlightNamedRegex('trailingspace', 'HG_Subtle', a:enable)
endfunction

function! HighlightArgs(ArgLead, CmdLine, CursorPos)
    let noItems = []
    for Item in g:HighlightItems
        let noItems = add(noItems, 'no' . Item)
    endfor
    return join(g:HighlightItems + noItems + ['*', 'no*'], "\n")
endfunction

function! HighlightBufferEnabled()
    if exists("b:HighlightEnabled")
        let bufferEnabled = b:HighlightEnabled
    else
        let bufferEnabled = g:HighlightEnabled
    endif
    return bufferEnabled
endfunction

function! HighlightItem(itemName, enable)
    let fullItemName = 'Highlight_' . a:itemName
    if !exists('*' . fullItemName)
        echoerr "Invalid highlight option " . a:itemName
        return
    endif
    let b:{fullItemName} = a:enable
    call {fullItemName}(a:enable && HighlightBufferEnabled())
endfunction

function! Highlight(...)
    let i = 0
    while i < a:0
        let itemName = a:000[i]
        let enable = 1
        if strpart(a:000[i], 0, 2) == 'no'
            let enable = 0
            let itemName = strpart(itemName, 2)
        endif
        if itemName == '*'
            for itemName in g:HighlightItems
                call HighlightItem(itemName, enable)
            endfor
        else
            call HighlightItem(itemName, enable)
        endif
        let i = i + 1
    endwhile
endfunction
command! -nargs=* -complete=custom,HighlightArgs
        \ Highlight call Highlight(<f-args>)

function! HighlightItemEnabled(itemName)
    let varName = "b:Highlight_" . a:itemName
    return exists(varName) && {varName}
endfunction

" (Re)-apply highlight groups.
" Note related local_HighlightApply autocmd group below.
function! HighlightApply()
    for itemName in g:HighlightItems
        call HighlightItem(itemName, HighlightItemEnabled(itemName))
    endfor
endfunction

function! HighlightEnable(enable)
    let b:HighlightEnabled = a:enable
    call HighlightApply()
endfunction
command!  HighlightOn  call HighlightEnable(1)
command!  HighlightOff call HighlightEnable(0)

" -------------------------------------------------------------
" Spell-checking.
" -------------------------------------------------------------

" 0 - Disable changing of 'spell' option for all filetypes.
" 1 - Enable changing of 'spell' option, subject to g:SpellMap below.
" Override this in per-user configuration files to disable automatic setup of
" spell-checking:
"   let g:Spell = 0
let g:Spell = 1

" Determines spell-check setting for a file.
" Starting with an initial key, the dictionary is used to map the key to a
" subsequent key until the key is not found.  Then, if the key is
" "<on>", spell-checking will be turned on for this file; if the key is
" "<off>", spell-checking will be turned off for this file; otherwise, nothing
" is done.
" Keys are either filetypes (as found in &filetype) or strings of the form
" "<group_or_directive>".  Groups are useful to allow control of similar
" filetypes.  Some expected groups are:
"
" - "<source>"      Source files
" - "<*>"           Used when &filetype is not in g:SpellMap
"
" The initial key is one of the following:
" - &filetype           (if &filetype is in g:SpellMap)
" - b:SpellType         (if b:SpellType exists)
" - "<*>"               (otherwise)
" Examples:
"   Turn off spell-checking for just "C" source code:
"     let g:SpellMap["c"] = "<off>"
"   Turn off spell-checking for the entire "<source>" group:
"     let g:SpellMap["<source>"] = "<off>"

let g:SpellMap = {}

" Implements the lookup scheme described above. varname is expected to be the
" buffer-local variable (like "b:SpellType"), and mapname is the name of the
" map used to track the mapping (e.g. "g:SpellMap").
"
" We use names instead of the actual variable so that we can check for the
" existence of varname, and so we can provide a better error if a loop is
" detected in mapname.
function! LookupKey(varname, mapname)
    let globalMap = eval(a:mapname)

    " Track keys we've seen before.
    let l:sawKey = {}

    if has_key(l:globalMap, &filetype)
        let key = &filetype
    elseif exists(a:varname)
        let key = eval(a:varname)
    else
        let key = "<*>"
    endif

    while has_key(l:globalMap, key)
        if has_key(l:sawKey, key)
            echoerr "Loop in " . mapname . " for key:" key
            return
        endif
        let l:sawKey[key] = 1
        let key = l:globalMap[key]
    endwhile

    if key == "<on>" || key == "<off>"
        return key
    endif

    return ""
endfunction

" Adjust 'spell' setting for file (see g:SpellMap for details).
" Generally called from autocmd on filetype change.
function! SetSpell()
    " Bail out if 'spell' setting is globally disabled.
    if ! g:Spell
        return
    endif

    let key = get(b:, "Spell", LookupKey("b:SpellType", "g:SpellMap"))

    if key == "<on>"
        setlocal spell
    elseif key == "<off>"
        setlocal nospell
    endif
endfunction

" -------------------------------------------------------------
" Syntax embedding
" -------------------------------------------------------------

" Embed a syntax highlighting group into the current syntax.
function! SyntaxInclude(group, syntaxType)
    " Executes the following commands:
    "   syntax include @<group> syntax/<syntaxType>.vim
    "   syntax include @<group> after/syntax/<syntaxType>.vim
    " Preserves existing b:current_syntax.

    if exists('b:current_syntax')
        let savedSyntax = b:current_syntax
        unlet b:current_syntax
    endif

    let cmd = 'syntax include @' . a:group
    let syntaxName = a:syntaxType . '.vim'

    try
        execute cmd . ' syntax/' . syntaxName
        execute cmd . ' after/syntax/' . syntaxName
    catch
    endtry
    if exists('savedSyntax')
        let b:current_syntax = savedSyntax
    else
        unlet b:current_syntax
    endif
endfunction

" Map language a:lang into Vim's syntax name.
function! SyntaxMap(lang)
    if a:lang == 'c'
        " Special-case C because Vim's syntax highlighting for cpp
        " is based on the C highlighting, and it doesn't like to
        " have both C and CPP active at the same time.  Map C highlighting
        " to CPP to avoid this problem.
        return 'cpp'
    elseif a:lang == 'ini'
        " The Vim filetype for .ini files is 'dosini'.
        return 'dosini'
    endif
    return a:lang
endfunction

if !exists('g:commonEmbeddedLangs')
    " NOTE: Embedding java causes spell checking to be disabled, because
    " the syntax file for java monkeys with the spell checking settings.
    let g:commonEmbeddedLangs = [
            \ 'bash', 'c', 'cpp', 'dosini', 'html', 'ini', 'python',
            \ 'ruby', 'rust', 'sh', 'vim', 'toml', 'yaml']
endif

" -------------------------------------------------------------
" Settings common to all filetypes.
" -------------------------------------------------------------
function! SetupCommon()
    " Setup formatoptions:
    "   c - auto-wrap comments to textwidth.
    "   q - allow formatting of comments with 'gq'.
    "   l - long lines are not broken in insert mode.
    "   n - recognize numbered lists.
    setlocal formatoptions+=cqln

    " This flag was added in Vim 7.3.541:
    "   j - remove comment leader when joining.
    " Ignore failures setting this flag.
    silent! setlocal formatoptions+=j

    " Define pattern for list items.  This helps with reformatting paragraphs
    " (e.g., via gqap) such that bulleted and numbered lines are handled
    " correctly.
    let &l:formatlistpat = '^\s*\d\+\.\s\+\|^\s*[-*+]\s\+'

    " Also treat lines consisting of optional leading whitespace and
    " a single repeated punctuation character as list items so that
    " header text will not be joined with its underline. E.g., the below
    " text will be unchanged by reformatting::
    "
    "   Some header text
    "   ================
    "
    " Unfortunately, overlines are not treated properly.  This text:
    "
    "   =================
    "   Over/under header
    "   =================
    "
    " will be reformatted badly to this::
    "
    "   ================= Over/under header
    "   =================
    "
    " But since underlined headers are the most common, this is better
    " than nothing, and it's much easier to use Vim's built-in formatting
    " logic than to write something custom.

    let &l:formatlistpat .= '\|^\s*\([-=^"#*' . "'" . ']\)\ze\1\+$'
endfunction
command! -bar SetupCommon call SetupCommon()

" -------------------------------------------------------------
" Setup for plain text (and derivatives).
" -------------------------------------------------------------
function! SetupText()
    SetupCommon
    " Auto-wrap text using textwidth:
    setlocal formatoptions+=t

    " Do not automatically insert comment leaders:
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    " Note: This is to avoid the unwanted side-effect that pressing <Enter>
    " on a bulleted list item indents the next line, e.g.:
    "
    "   - Pressing <Enter> on this bullet yields the below
    "     indented second line.
    setlocal formatoptions-=ro

    setlocal tw=80 ts=8 sts=2 sw=2 et ai
    let b:SpellType = "<text>"
endfunction
command! -bar SetupText call SetupText()
let g:SpellMap["<text>"] = "<on>"

" -------------------------------------------------------------
" Setup for general source code.
" -------------------------------------------------------------
function! SetupSource()
    SetupCommon
    " Disable auto-wrap for text, allowing long code lines.
    set formatoptions-=t

    " Automatically insert comment leaders:
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    setlocal formatoptions+=ro

    setlocal tw=80 ts=8 sts=4 sw=4 et ai
    Highlight longlines tabs trailingspace
    let b:SpellType = "<source>"
endfunction
command! -bar SetupSource call SetupSource()
let g:SpellMap["<source>"] = "<on>"

" -------------------------------------------------------------
" Setup for markup languages like HTML, XML, ....
" -------------------------------------------------------------
function! SetupMarkup()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
    runtime scripts/closetag.vim
    runtime scripts/xml.vim
    let b:SpellType = "<markup>"

    syntax sync minlines=300 maxlines=300
endfunction
command! -bar SetupMarkup call SetupMarkup()
let g:SpellMap["<markup>"] = "<on>"

" -------------------------------------------------------------
" Setup for mail.
" -------------------------------------------------------------
function! SetupMail()
    SetupText
    " Use the 'w' flag in formatoptions to setup format=flowed editing.
    " The 'w' flag causes problems for wrapping when manual editing strips
    " out a trailing space.  Better to avoid the flag...
    " set formatoptions+=w
    setlocal tw=64 sw=2 sts=2 et ai

    " Highlight diffs.  Most of this was taken from notmuch's vim integration,
    " but with spelling turned off in the highlighted lines.

    " diffSeparator separates headers such as "Signed-off-by" from the
    " diff itself, as in this example::
    "
    "   Signed-off-by: John Szakmeister <john@example.com>
    "   ---
    "   Some comments about the diff that follows below.
    "
    " It's not part of diffRegion below.  Since it's unlikely that emails
    " will contain the line "---" without preceding such a diff, and it's
    " little enough harm in the event of a spurious match, we'll highlight
    " lines of "---" anywhere throughout an email.
    syntax match diffSeparator "^---$"

    " These "contained" matches should all include the final newline in their
    " regex, so that no characters are left unmatched.  That way, any unmatched
    " characters will cause the "end=" match in diffRegion to bail out, showing
    " the user where the well-formed diff hunk ends.
    syntax match diffFile "^diff .*\n" contains=@NoSpell contained
    syntax match diffIndex "^Index: .*\n" contains=@NoSpell contained
    syntax match diffIndex "^index .*\n" contains=@NoSpell contained
    syntax match diffNormal "^ .*\n" contains=@NoSpell contained
    syntax match diffNormal "^=\+\n" contains=@NoSpell contained
    syntax match diffRemoved "^-.*\n" contains=@NoSpell contained
    syntax match diffAdded "^+.*\n" contains=@NoSpell contained

    syntax match diffNewFile "^+++ .*\n" contains=@NoSpell contained
    syntax match diffOldFile "^--- .*\n" contains=@NoSpell contained

    syntax match diffSubname " @@..*\n"ms=s+3 contains=@NoSpell contained
    syntax match diffLine "^@.*\n" contains=diffSubname,@NoSpell

    " Declare a region of "diff" hunks.  The "matchgroup=" directive applies
    " only for select "end=" conditions, allowing the other contained matches to
    " handle individual highlighting (e.g., "diffIndex" will be used to
    " highlight the "Index: " lines).  The use of "." as an "end=" regex means
    " that diffRegion will terminate on the first character not claimed by one
    " of the contained matches.  Another "end=" regex causes termination on a
    " completely empty line, since diff hunks should have at least a leading
    " space for normal diff lines.

    syntax region diffRegion
            \ contains=@NoSpell,
            \diffFile,diffIndex,diffNormal,diffRemoved,diffAdded,
            \diffNewFile,diffOldFile,diffLine
            \ start="\v^(
            \(diff .*\nindex .*\n|Index: .*\n(\=+\n)?)?
            \(^--- .*\n\+\+\+ )
            \)"
            \ end="^$"
            \ end="."
            \ matchgroup=diffEndmarker
            \ end="^-- \n"

    highlight default link diffHeader diffFile
    highlight default link diffIndex diffFile
    highlight default link diffOldFile diffFile
    highlight default link diffNewFile diffFile
    highlight default link diffRemoved Special
    highlight default link diffAdded Identifier
    highlight default link diffLine Statement
    highlight default link diffSubname PreProc
    highlight default link diffSeparator diffComment
    highlight default link diffEndMarker diffComment

    syntax match gitDiffStatLine /^ .\{-}\zs[+-]\+$/
            \ contains=gitDiffStatAdd,gitDiffStatDelete
    syntax match gitDiffStatAdd /+/ contained
    syntax match gitDiffStatDelete /-/ contained

    highlight default link gitDiffStatAdd diffAdded
    highlight default link gitDiffStatDelete diffRemoved

    syntax sync minlines=300 maxlines=300
endfunction
command! -bar SetupMail call SetupMail()
let g:SpellMap["mail"] = "<on>"

" -------------------------------------------------------------
" Setup for Markdown.
" -------------------------------------------------------------

function! DisableMarkdownSyntaxCodeList()
    let g:markdown_fenced_languages = []
endfunction

call DisableMarkdownSyntaxCodeList()

function! SetupMarkdownSyntax()
    call DisableMarkdownSyntaxCodeList()

    " We default to g:commonEmbeddedLangs.
    if !exists("g:markdownEmbeddedLangs")
        let g:markdownEmbeddedLangs = g:commonEmbeddedLangs
    endif

    " The group naming convention is the same as vim-markdown's, but the logic
    " is a little different here.  Namely, we don't deal with dotted names, and
    " we have special handling for the c language.

    " Do not re-include the same `synLang` twice.
    let includedSynLangs = {}
    for lang in g:markdownEmbeddedLangs
        let synLang = SyntaxMap(lang)
        let synGroup = 'markdown_embed_' . synLang
        if !has_key(includedSynLangs, synLang)
            call SyntaxInclude(synGroup, synLang)
            let includedSynLangs[synLang] = 1
        endif

        execute 'syntax region ' . synGroup .
                \ ' matchgroup=markdownCodeDelimiter start="^\s*```\s*' .
                \ lang . '\>.*$" end="^\s*```\ze\s*$" keepend ' .
                \ 'contains=@' . synGroup
    endfor
endfunction
command! -bar SetupMarkdownSyntax call SetupMarkdownSyntax()

function! SetupMarkdown()
    SetupMarkup

    " Setup comments so that we get proper list support.  Also taken from
    " vim-markdown's ftplugin/markdown.vim.
    setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=>\ %s

    " Setup some extra highlighting for code blocks.  This matches the
    " highlighting from Ben William's syntax/mkd.vim and is a decent fallback
    " when we don't support the embedded language or the block is inline.
    highlight default link markdownCode                  String
    highlight default link markdownCodeBlock             String

    " Having underscores within a word `like_this` is not generally an error;
    " see: https://spec.commonmark.org/0.30/#emphasis-and-strong-emphasis
    " To retain this highlighting anyway, let g:LocalAllowMarkdownError = 1.
    if !exists('g:LocalAllowMarkdownError') || !g:LocalAllowMarkdownError
        highlight link markdownError NONE
    endif
endfunction
command! -bar SetupMarkdown call SetupMarkdown()

" -------------------------------------------------------------
" Setup LessCSS.
" -------------------------------------------------------------
function! SetupLess()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
endfunction
command! -bar SetupLess call SetupLess()

" Disable the embedded syntax feature of newer syntax/rst.vim for a few reasons:
" - It doesn't work with both "c" and "cpp" active simultaneously, since both
"   rely on including syntax/c.vim, and the double inclusion of this file
"   causes problems.
" - It requires a fairly new Vim, and we'd like to support older ones, too.
" - It marks the block with NoSpell, which we don't want.
" - It's easier to disable the support in syntax/rst.vim entirely than to
"   partially use it and work around its limitations.
function! DisableRstSyntaxCodeList()
    let g:rst_syntax_code_list = []
endfunction

call DisableRstSyntaxCodeList()

" -------------------------------------------------------------
" Setup for reStructuredText.
" -------------------------------------------------------------

" Define function and command for fixing literal block syntax highlighting.
" But don't use alphabetic enumerators like `ii.`, since they can show
" up at start-of-line like this::
"
"   This is a sentence with many
"   words.  Now a literal follows::
"
"       But it is not highlighted correctly because "words." looks like
"       an enumerator, so the indentation is insufficient to be considered
"       a valid literal (it would need to be indented beneath the "Now").
if !exists('g:RstLiteralBlockFix_alphaEnumerators')
    let g:RstLiteralBlockFix_alphaEnumerators = 0
endif
runtime scripts/rstliteralblockfix.vim

function! SetupRstSyntax()
    " We default to g:commonEmbeddedLangs.
    if !exists('g:rstEmbeddedLangs')
        let g:rstEmbeddedLangs = g:commonEmbeddedLangs
    endif

    " Layout embedded source as follows:
    " .. code-block:: lang
    "     lang-specific source code here.
    " ..
    function! s:EmbedCodeBlock(lang, synGroup)
        if a:lang == ''
            let region = 'rstCodeBlock'
            let regex = '.*'
        else
            " Put a:lang first so that plugins like TComment can detect embedded
            " languages using a heuristic based on the common convention that
            " syntax files use, namely putting the language's name first in a
            " lowerMixedCase identifier.  For example, in the "C" language there
            " are `cStatement`, `cLabel`, `cConditional`, etc.
            let region = a:lang . 'RstDirective'
            let regex = a:lang
        endif
        silent! syntax clear region
        let cmd  = 'syntax region ' . region
        let cmd .= ' matchgroup=rstDirective fold'
        let cmd .= ' start="^\z(\s*\)\.\.\s\+'
        let cmd .= '\%(sourcecode\|code-block\|code\)::\s\+'
        let cmd .= regex . '\s*$"'
        " @todo Don't forget to highlight :options: lines
        " such as :linenos:
        let cmd .= ' skip="\n\z1\s\|\n\s*\n"'
        let cmd .= ' end="$"'
        if a:synGroup != ""
            let cmd .= ' contains=@' . a:synGroup
        endif
        execute cmd
        execute 'syntax cluster rstDirectives add=' . region
    endfunction

    let old_iskeyword = &iskeyword
    call DisableRstSyntaxCodeList()
    " Handle unspecified languages first.
    call s:EmbedCodeBlock("", "")

    " Do not re-include the same `synLang` twice.
    let includedSynLangs = {}
    for lang in g:rstEmbeddedLangs
        let synLang = SyntaxMap(lang)
        let synGroup = 'rst_embed_' . synLang
        if !has_key(includedSynLangs, synLang)
            call SyntaxInclude(synGroup, synLang)
            let includedSynLangs[synLang] = 1
        endif
        call s:EmbedCodeBlock(lang, synGroup)
    endfor
    let &iskeyword = old_iskeyword

    syntax sync minlines=300 maxlines=300
    " Enable fix for literal block highlighting.
    RstLiteralBlockFix on
endfunction
command! -bar SetupRstSyntax call SetupRstSyntax()

function! SetupRst()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai

    " Vim v8.1.0225 enable syntax-based folding for reST files by default.
    " Change the foldlevel to prevent user annoyance at having to expand folds
    " every time.
    setlocal foldlevel=99

    if g:Python != '' && findfile('conf.py', '.;') != ''
        let b:syntastic_checkers = ['rstsphinx']
    endif
endfunction
command! -bar SetupRst call SetupRst()
let g:SpellMap["rst"] = "<on>"

function! SetupRstIndent()
    " The indent function shipped with Vim tries to guess the desired
    " indentation, but it guesses incorrectly often enough to make it
    " irritating.  This is mainly because after a line like this:
    "
    "   - Some bullet text
    "
    " It's not possible to guess accurately enough whether the user
    " plans to continue the bullet or start something new.  Manually
    " changing the indentation when desired seems to create a less
    " jarring experience.  Therefore, use the "Status Quo" indentation
    " function to keep the prevailing indentation level unless the user
    " changes it explicitly.
    setlocal indentexpr=StatusQuoIndent()
endfunction
command! -bar SetupRstIndent call SetupRstIndent()

" -------------------------------------------------------------
" Setup for Wikipedia.
" -------------------------------------------------------------
function! SetupWikipedia()
    SetupText
    setlocal tw=0 ts=8 sts=2 sw=2 et ai
    " Setup angle brackets as matched pairs for '%'.
    setlocal matchpairs+=<:>
endfunction
command! -bar SetupWikipedia call SetupWikipedia()
let g:SpellMap["Wikipedia"] = "<on>"

" -------------------------------------------------------------
" Setup for Bash "fixcommand" mode using "fc" command.
" -------------------------------------------------------------
function! SetupBashFixcommand()
    " Generally this mode is for "one-shot" editing using Bash's "fc"
    " command.  It won't be used for a long-running editing session
    " with multiple files, so it's OK to change the global shell defaults
    " (which is good, because this would be painful otherwise).

    " Use ``unlet!`` to silence errors should ``g:is_kornshell`` be undefined.
    unlet! g:is_kornshell
    let g:is_bash=1
    setfiletype sh

    setlocal tw=0
    Highlight no*
endfunction
command! -bar SetupBashFixcommand call SetupBashFixcommand()

" -------------------------------------------------------------
" Setup for C code.
" -------------------------------------------------------------

" Use C syntax for *.h files (see filetype.vim)
let g:c_syntax_for_h = 1

" Minimum number of lines before current line to start syntax
" synchronization (default 50).
let g:c_minlines = 300

" Enable Doxygen highlighting.
let g:load_doxygen_syntax = 1

" Disable error highlighting of curly braces inside parentheses.
let g:c_no_curly_error = 1

function! IndentC()
    if v:lnum > 1 && getline(v:lnum - 1) =~ '^\s*\*//\*\*'
        return indent(v:lnum - 1) + &shiftwidth
    else
        return cindent(v:lnum)
    endif
endfunction

if !exists('g:UseCppComments')
    let g:UseCppComments = 1
endif

if !exists('g:UseLeadingAsterisks')
    let g:UseLeadingAsterisks = 0
endif

if !exists('g:tcomment_def_c')
    let g:tcomment_def_c = {
            \ 'rxmid': '',
            \ 'rxend': '',
            \ 'commentstring': '/* %s */',
            \ 'commentstring_rx': '\%%(// %s\|/* %s */\)',
            \ 'replacements': {
            \   '*/': '|)}>#',
            \   '/*': '#<{(|'
            \  },
            \ 'rxbeg': '\*\+'
            \ }
endif

if !exists('g:tcomment_def_cpp')
    let g:tcomment_def_cpp = {
            \ 'rxmid': '',
            \ 'rxend': '',
            \ 'commentstring': '// %s',
            \ 'commentstring_rx': '\%%(// %s\|/* %s */\)',
            \ 'replacements': {},
            \ 'rxbeg': '\*\+'
            \ }
endif

if g:UseCppComments
    call tcomment#type#Define('c', g:tcomment_def_cpp)
else
    call tcomment#type#Define('c', g:tcomment_def_c)
endif
call tcomment#type#Define('cpp', g:tcomment_def_cpp)

function! SetupCommentStyleC()
    let b:UseCppComments = GetVar('b:UseCppComments', g:UseCppComments)
    let b:UseLeadingAsterisks =
            \ GetVar('b:UseLeadingAsterisks', g:UseLeadingAsterisks)

    if b:UseLeadingAsterisks
        " Has leading asterisks (Vim default).
        setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
    else
        " No leading asterisks.
        setlocal comments=s:/*,mb:\ ,e-4:*/,://
    endif

    if b:UseCppComments
        let b:tcomment_def_c = deepcopy(g:tcomment_def_cpp)
    else
        let b:tcomment_def_c = deepcopy(g:tcomment_def_c)
    endif
endfunction
command! -bar SetupCommentStyleC call SetupCommentStyleC()

function! SetupC()
    SetupSource
    Highlight commas keywordspace longlines tabs trailingspace
    setlocal indentexpr=IndentC()

    " Re-indent when ending a C-style comment.
    setlocal indentkeys+=/

    " cinoptions shift amounts ending in 's' are in units of shiftwidth.

    " Don't outdent function return types.
    setlocal cinoptions+=t0

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " Comment bodies indented one shiftwidth.
    setlocal cinoptions+=c1s,C1s

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Indent amount for unclosed parentheses (first-level).
    setlocal cinoptions+=(1s

    " Indent amount for unclosed parentheses (second-level).
    setlocal cinoptions+=u0

    " How many lines away to search for unclosed parentheses.
    setlocal cinoptions+=)30

    " Whether to respect indenting even when unclosed parenthesis is the first
    " non-white character in its line (U1 to respect, U0 to ignore).
    setlocal cinoptions+=U1

    " How many lines away to search for unclosed comments.
    setlocal cinoptions+=*100

    " Map CTRL-o_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>
    vnoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>

    SetupCommentStyleC

    if g:EnableVimLsp_c
        setlocal omnifunc=lsp#complete
    endif
endfunction
command! -bar SetupC call SetupC()

" -------------------------------------------------------------
" Setup for C++ code.
" -------------------------------------------------------------
function! SetupCpp()
    let b:UseCppComments = 1
    SetupC
endfunction
command! -bar SetupCpp call SetupCpp()

" -------------------------------------------------------------
" Setup for general Clojure code.
" -------------------------------------------------------------
function! SetupClojure()
    SetupSource
    setlocal ts=8 sts=2 sw=2

    RainbowParenthesesLoadRound
    RainbowParenthesesLoadSquare
    RainbowParenthesesLoadBraces
    RainbowParenthesesActivate
endfunction
command! -bar SetupClojure call SetupClojure()

" -------------------------------------------------------------
" Setup for CMake
" -------------------------------------------------------------
function! SetupCmake()
    SetupSource
    setlocal commentstring=#\ %s

    syntax sync minlines=300 maxlines=300
endfunction
command! -bar SetupCmake call SetupCmake()

" -------------------------------------------------------------
" Setup for C# code.
" -------------------------------------------------------------
function! SetupCs()
    SetupSource
endfunction
command! -bar SetupCs call SetupCs()

" -------------------------------------------------------------
" Setup for D code.
" -------------------------------------------------------------
function! SetupD()
    SetupC
endfunction
command! -bar SetupD call SetupD()

" -------------------------------------------------------------
" Setup for Dockerfile
" -------------------------------------------------------------
function! SetupDockerfile()
    SetupCommon
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
endfunction
command! -bar SetupDockerfile call SetupDockerfile()

" -------------------------------------------------------------
" Setup for GDB.
" -------------------------------------------------------------
function! SetupGdb()
    SetupSource
    setlocal commentstring=#\ %s
endfunction
command! -bar SetupGdb call SetupGdb()

" -------------------------------------------------------------
" Setup for Git-related files (e.g., "COMMIT_EDITMSG").
" -------------------------------------------------------------
function! SetupGit()
    SetupText
    setlocal tw=72
endfunction
command! -bar SetupGit call SetupGit()

function! SetupGitConfig()
    SetupText
    setlocal noexpandtab sts=8 sw=8 commentstring=#\ %s
endfunction
command! -bar SetupGitConfig call SetupGitConfig()

" -------------------------------------------------------------
" Setup for Haskell.
" -------------------------------------------------------------
function! SetupHaskell()
    SetupSource

endfunction
command! -bar SetupHaskell call SetupHaskell()

" -------------------------------------------------------------
" Setup for JavaScript.
" -------------------------------------------------------------
function! SetupJavaScript()
    SetupSource

    " Use 2-space indent for knife files, since it's the Chef default.
    if match(expand("%:t"), "^knife-") != -1
        setlocal sts=2 sw=2
    endif

    " Map CTRL-o_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>
    vnoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>
endfunction
command! -bar SetupJavaScript call SetupJavaScript()

" -------------------------------------------------------------
" Setup for JSON
" -------------------------------------------------------------
function! SetupJson()
    SetupSource
    Highlight nolonglines
endfunction
command! -bar SetupJson call SetupJson()

" -------------------------------------------------------------
" Setup for LLVM source code.
" -------------------------------------------------------------

function! SetupLlvm()
    SetupSource

    set sts=2 sw=2 expandtab

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Line up function args.
    setlocal cinoptions+=(0

    " Use a shiftwidth for argument indent, when the first parameter is not
    " on the same line as the function.
    setlocal cinoptions+=Ws

    " Aligns the curly for a case statement with the case label, rather than the
    " last statement.
    setlocal cinoptions+=l1

    let b:UseCppComments = 1
    let b:UseLeadingAsterisks = 0
    SetupCommentStyleC
endfunction
command! -bar SetupLlvm call SetupLlvm()

" -------------------------------------------------------------
" Setup for Lua.
" -------------------------------------------------------------
function! SetupLua()
    SetupSource
    setlocal commentstring=--\ %s
endfunction
command! -bar SetupLua call SetupLua()

" -------------------------------------------------------------
" Setup for Moonscript.
" -------------------------------------------------------------
function! SetupMoonscript()
    SetupSource
    setlocal commentstring=--\ %s
endfunction
command! -bar SetupMoonscript call SetupMoonscript()

" -------------------------------------------------------------
" Setup for Python.
" -------------------------------------------------------------
function! SetupPython()
    SetupSource

    " Lines are at most 79 characters according to PEP8.
    setlocal tw=79

    " Python always thinks tabs are 8 characters wide.
    setlocal ts=8

    " Follow PEP-recommended alignment of parentheses
    setlocal cinoptions+=(0

    " Map CTRL-o_CR to append ':' to the end of line, then do CR.
    inoremap <buffer> <C-o><CR> <C-\><C-n>A:<CR>
    vnoremap <buffer> <C-o><CR> <C-\><C-n>A:<CR>

    syntax sync minlines=300 maxlines=300

    SyntasticBufferSetup strict
    if g:EnableVimLsp_python
        setlocal omnifunc=lsp#complete
    elseif g:EnableAle
        setlocal omnifunc=ale#completion#OmniFunc
    endif
endfunction
command! -bar SetupPython call SetupPython()
let g:IndentGuidesMap["python"] = "<on>"

" -------------------------------------------------------------
" Setup for QuickFix window
" -------------------------------------------------------------

" Parse line for 'path/to/filename|', return 'path/to/filename' or ''.
function! QuickFixFilename(line)
    return matchstr(a:line, '\v^[^|]+\ze\|')
endfunction

" Use getline() to search current buffer at lineNum and backward until
" a valid QuickFixFilename() is located; return it or '' if not found.
function! QuickFixFilenameAt(lineNum)
    let i = a:lineNum
    while i >= 1
        let filename = QuickFixFilename(getline(i))
        if filename != ''
            return filename
        endif
        let i -= 1
    endwhile
    return ''
endfunction

" Find the "leading" line number starting at lineNum and working backward.
" Uses getline() to determine prevailing filename at lineNum, then determines
" first line number with that same filename.  If no such filename, return 0.
function! QuickFixLeadingLineNum(lineNum)
    let leadingFilename = QuickFixFilenameAt(a:lineNum)
    if leadingFilename == ''
        return 0
    endif
    let leadingLineNum = a:lineNum
    let i = a:lineNum - 1
    while i >= 1
        let filename = QuickFixFilename(getline(i))
        if filename == leadingFilename
            let leadingLineNum = i
        elseif filename != ''
            break
        endif
        let i -= 1
    endwhile
    return leadingLineNum
endfunction

function! QuickFixPrevFileLineNum()
    let lineNum = line('.')
    let leadingLineNum = QuickFixLeadingLineNum(lineNum)
    if leadingLineNum == lineNum
        let leadingLineNum = QuickFixLeadingLineNum(leadingLineNum - 1)
    endif
    if leadingLineNum > 0
        let lineNum = leadingLineNum
    endif
    return lineNum
endfunction

function! QuickFixNextFileLineNum()
    let lineNum = line('.')
    let leadingFilename = QuickFixFilenameAt(lineNum)
    " Set destLineNum to line number of next non-empty filename (if any).
    let destLineNum = lineNum
    while lineNum < line('$')
        let lineNum += 1
        let filename = QuickFixFilename(getline(lineNum))
        if (filename != '') && (filename != leadingFilename)
            let destLineNum = lineNum
            break
        endif
    endwhile
    return destLineNum
endfunction

" Save height of QuickFix window.
function! SaveQuickFixHeight()
    if &buftype == 'quickfix'
        let b:QuickFixHeight = winheight(0)
    endif
endfunction

" Restore height of QuickFix window.
function! RestoreQuickFixHeight()
    if &buftype == 'quickfix' && exists('b:QuickFixHeight')
        execute 'resize ' . b:QuickFixHeight
    endif
endfunction

" Add mappings to QuickFix and Location List windows.
function! AddQuickFixMappings()
    if &buftype == 'quickfix'
        let pre = 'nmap <buffer> <silent> '
        let saveH = ':call SaveQuickFixHeight()<CR>'
        let restoreH = ':call RestoreQuickFixHeight()<CR>'
        if IsQuickFixWin()
            let close = ':cclose<CR>'
        else
            let close = ':lclose<CR>'
        endif
        let openNew = '<C-w><CR>'
        let prevWin = '<C-w>p'

        " Allow escaping out of mappings without performing o/O editing actions.
        nnoremap <buffer> <silent> o <Nop>
        nnoremap <buffer> <silent> O <Nop>

        execute pre . 'oo ' . prevWin
        execute pre . 'OO ' . close

        " Ensure <CR> does the out-of-the-box behavior.
        nnoremap <buffer> <silent> <CR> <CR>

        let openStay = '<CR>' . prevWin
        execute pre . '<s-CR>  ' . openStay
        execute pre . 'o<CR> '   . '<CR>'
        execute pre . 'o<s-CR> ' . openStay
        execute pre . 'O<CR> '   . openStay . close
        execute pre . 'O<s-CR> ' . openStay . close

        let openStay = openNew . '<C-w>K' . prevWin
        execute pre . 'oh ' . saveH . openStay . restoreH . prevWin
        execute pre . 'oH ' . saveH . openStay . restoreH
        execute pre . 'Oh '         . openStay . close    . prevWin
        execute pre . 'OH '         . openStay . close    . prevWin

        let openStay = openNew . '<C-w>H' . prevWin . '<C-w>J'
        execute pre . 'ov ' . saveH . openStay . restoreH . prevWin
        execute pre . 'oV ' . saveH . openStay . restoreH
        execute pre . 'Ov '         . openStay . close    . prevWin
        execute pre . 'OV '         . openStay . close    . prevWin

        let openStay = openNew . '<C-w>T' . 'gT<C-w>j'
        execute pre . 'ot ' . saveH . openStay . restoreH . 'gt'
        execute pre . 'oT ' . saveH . openStay . restoreH
        execute pre . 'Ot '         . openStay . close    . 'gt'
        execute pre . 'OT '         . openStay . close    . 'gt'

        nnoremap <buffer> <F1> :help notes_quickfix<CR>

        nnoremap <buffer> <silent> <expr> {
                \ ':' . QuickFixPrevFileLineNum() . '<CR>'
        nnoremap <buffer> <silent> <expr> }
                \ ':' . QuickFixNextFileLineNum() . '<CR>'
    endif
endfunction

function! SetupQuickFix()
   FoldQuickFixFiles 1
   call AddQuickFixMappings()
   " Don't do whitespace checking on QuickFix windows.
   " By default, QuickFix would be ignored because it's readonly, but we have
   " a writable QuickFix due to the QuickFix Reflector plugin.
   let b:airline_whitespace_disabled = 1
endfunction
command! -bar SetupQuickFix call SetupQuickFix()

" -------------------------------------------------------------
" Setup for Ruby.
" -------------------------------------------------------------
function! SetupRuby()
    SetupSource
    setlocal ts=8 sts=2 sw=2
    " TODO May want ``default`` as another strictness value.
    SyntasticBufferSetup strict
endfunction
command! -bar SetupRuby call SetupRuby()

" -------------------------------------------------------------
" Setup for Rust.
" -------------------------------------------------------------
function! SetupRust()
    SetupSource

    " Original definition from bundle/rust/ftplugin/rust.vim:
    " setlocal comments=s0:/*!,ex:*/,s1:/*,mb:*,ex:*/,:///,://!,://
    setlocal comments=s0:/*!,mb:\ ,e-4:*/,s0:/*,mb:\ ,ex-4:*/,:///,://!,://

    if g:EnableVimLsp_rust
        setlocal omnifunc=lsp#complete
    elseif g:EnableAle
        setlocal omnifunc=ale#completion#OmniFunc
    endif
endfunction
command! -bar SetupRust call SetupRust()

function! SetupRustIndent()
    " Re-indent when ending a block comment.
    setlocal indentkeys+=/

    " Comment bodies indented one shiftwidth.
    setlocal cinoptions+=c1s,C1s
endfunction
command! -bar SetupRustIndent call SetupRustIndent()

" -------------------------------------------------------------
" Setup for Scheme code.
" -------------------------------------------------------------
function! SetupScheme()
    SetupSource
    setlocal ts=8 sts=2 sw=2

    RainbowParenthesesLoadRound
    RainbowParenthesesActivate
endfunction
command! -bar SetupScheme call SetupScheme()

" -------------------------------------------------------------
" Setup for shell languages like sh and zsh.
" -------------------------------------------------------------

" Avoid adding "." to 'iskeyword'.  The 'sh' syntax file started adding
" this a while ago, apparently because certain dialects of shell syntax
" permit using a "." inside of an identifier; but changing 'iskeyword'
" breaks expectations for word-related editing commands like ``dw``.
" Given that using a "." in an identifier is a very rare use-case, whereas
" editing words is a very common use-case, this is a mis-feature that needs
" to be undone by the following assignment.
let g:sh_noisk = 1

function! SetupShell()
    SetupSource

    syntax sync minlines=300 maxlines=300

    if exists('g:ale_sh_shfmt_options')
        let options = g:ale_sh_shfmt_options . ' '
    else
        let options = ''
    endif

    " Setup ALE shfmt options based on dialect.
    if exists('b:is_kornshell')
        " kornshell means POSIX.
        let b:ale_sh_shfmt_options = options . '-p'
    endif
endfunction
command! -bar SetupShell call SetupShell()

" -------------------------------------------------------------
" Setup for Subversion commit files.
" -------------------------------------------------------------
function! SetupSvn()
    SetupText
    setlocal tw=72
endfunction
command! -bar SetupSvn call SetupSvn()

" --------------------------------------
" Setup for Vader (Vim testing language)
" --------------------------------------
function! SetupVader()
    SetupSource
    HighlightOff
endfunction
command! -bar SetupVader call SetupVader()

" -------------------------------------------------------------
" Setup for VHDL.
" -------------------------------------------------------------
function! SetupVhdl()
    SetupSource

    setlocal comments=b:--

    " Map CTRL-o_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>
    vnoremap <buffer> <C-o><CR> <C-\><C-n>A;<CR>

    " Convert a port into a port map.
    xnoremap <buffer> <leader>pm :s/^\(\s*\)\(\w\+\)\(\s*\)\(=>\<bar>:\).*
            \/\1\2\3=> \2,/<CR>
endfunction
command! -bar SetupVhdl call SetupVhdl()

" -------------------------------------------------------------
" Setup for Vim C-code Source (the source code for Vim itself).
" -------------------------------------------------------------
function! SetupVimC()
    SetupCommon
    setlocal ts=8 sts=4 sw=4 tw=80

    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Enable automatic C program indenting.
    setlocal cindent

    " Use default indentation options.
    setlocal cinoptions&

    let b:UseCppComments = 0
    let b:UseLeadingAsterisks = 1
    SetupCommentStyleC
endfunction
command! -bar SetupVimC call SetupVimC()

" Set indentation for backslash-continuations (the default value of 3 *
" &shiftwidth is excessive).  Do not define here in terms of &shiftwidth,
" as that value won't be set yet; but make this a one-time setting here so that
" vimrc-after can override it.
let g:vim_indent_cont = 2 * 4

" -------------------------------------------------------------
" Setup for Linux Kernel Sources.
" -------------------------------------------------------------
function! SetupKernelSource()
    SetupCommon
    setlocal ts=8 sts=8 sw=8 tw=80

    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Enable automatic C program indenting.
    setlocal cindent

    " Don't outdent function return types.
    setlocal cinoptions+=t0

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Line up function args.
    setlocal cinoptions+=(0

    let b:UseCppComments = 0
    let b:UseLeadingAsterisks = 1
    SetupCommentStyleC
endfunction
command! -bar SetupKernelSource call SetupKernelSource()

" -------------------------------------------------------------
" Setup for Makefiles.
" -------------------------------------------------------------
function! SetupMake()
    SetupCommon
    " Vim's defaults are mostly good.
    setlocal ts=8 tw=80

    " Setup identical settings for both "##" and "#" comments.
    setlocal comments=sO:##\ -,mO:##\ \ ,b:##,sO:#\ -,mO:#\ \ ,b:#
endfunction
command! -bar SetupMake call SetupMake()

function! SetupMakeIndent()
    setlocal autoindent
    setlocal indentkeys-=<:>
endfunction
command! -bar SetupMakeIndent call SetupMakeIndent()

" -------------------------------------------------------------
" Setup for help files.
" -------------------------------------------------------------
function! SetupHelp()
    SetupText
    " This helps make it easier to jump to tags while editing help files,
    " since a number of tags contain a hyphen.
    " The "@" adds in all "alphabetic" characters, including
    " accented characters beyond ASCII a-z and A-Z.
    setlocal iskeyword=@,!-~,^*,^\|,^\",192-255
    if &readonly
        " Disable spell checking when just reading help pages.
        let b:Spell = "<off>"
    endif
endfunction
command! -bar SetupHelp call SetupHelp()

" Last active help buffer number (0 if none).
let g:LastHelpBuf = 0
augroup local_help
    autocmd!

    " Store last active help buffer number when leaving the help window.
    autocmd WinLeave * if &bt == "help" | let g:LastHelpBuf = bufnr("%") | endif
augroup END

" Return buffer number of recent help window (0 if no help buffers).
function! FindRecentHelpBuf()
    let buf = 1
    let recentHelpBuf = 0
    while buf <= bufnr("$")
        if getbufvar(buf, "&buftype") == "help"
            let recentHelpBuf = buf
            if recentHelpBuf == g:LastHelpBuf
                break
            endif
        endif
        let buf += 1
    endwhile
    return recentHelpBuf
endfunction

" Return window number of active help window (0 if no active windows).
function! FindHelpWindow()
    let win = 1
    while win <= winnr("$")
        let buf = winbufnr(win)
        if getbufvar(buf, "&buftype") == "help"
            return win
        endif
        let win += 1
    endwhile
    return 0
endfunction

" If help window is active, close it; otherwise, re-open recent help buffer.
function! HelpToggle()
    let win = FindHelpWindow()
    let recentHelpBuf = FindRecentHelpBuf()
    if win > 0
        execute win . "wincmd w"
        wincmd c
        wincmd p
    elseif recentHelpBuf > 0
        split
        execute recentHelpBuf . "buffer"
    else
        help
    endif
endfunction
command! -bar HelpToggle call HelpToggle()

nnoremap <F1>       :<C-u>HelpToggle<CR>
nnoremap <C-q>h     :<C-u>HelpToggle<CR>
nnoremap <C-q><C-h> :<C-u>HelpToggle<CR>
nnoremap <Space>qh  :<C-u>HelpToggle<CR>

" Get help on visual selection.
function! VisualHelp()
    execute ":help " . SelectedText()
endfunction
command! -bar VisualHelp call VisualHelp()

xnoremap <F1>       :<C-u>call VisualHelp()<CR>
xnoremap <C-q>h     :<C-u>call VisualHelp()<CR>
xnoremap <C-q><C-h> :<C-u>call VisualHelp()<CR>
xnoremap <Space>qh  :<C-u>call VisualHelp()<CR>


" -------------------------------------------------------------
" Setup for C projects following the GNU Coding Standards
" -------------------------------------------------------------
function! SetupGnuSource()
    SetupSource
    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Turn off our own indent rules.  Reset it to Vim's default.
    setlocal indentexpr&

    " Taken from: http://gcc.gnu.org/wiki/FormattingCodeForGCC
    setlocal cindent

    " Don't outdent function return types.
    setlocal cinoptions=t0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Amount added after normal indent.
    setlocal cinoptions+=>2s

    " If statements without braces aren't indented as far.
    setlocal cinoptions+=n-1s

    " Opening branch are indented from if statement.
    setlocal cinoptions+={1s

    " Bring back the indentation inside a function.
    setlocal cinoptions+=^-1s

    " Indent case labels slightly.
    setlocal cinoptions+=:1s

    " Indent case statements from the case label.
    setlocal cinoptions+==1s

    " Place scope decorations in the same column as braces.
    setlocal cinoptions+=g0

    " Indent statements after scope declaration.
    setlocal cinoptions+=h1s

    " K&R-style parameter declarations get 5 spaces.
    setlocal cinoptions+=p5

    " Indent continuation lines.
    setlocal cinoptions+=+1s

    " Line up the first characters when you are continuing inside a statement
    " with parens.
    setlocal cinoptions+=(0

    " Second level of parens works the same way as above.
    setlocal cinoptions+=u0

    " If there's leading whitespace between the paren and first non-white
    " character, the ignore them when deciding where to continue.
    setlocal cinoptions+=w1

    " Line a closing paren that starts at the beginning of a line with the start
    " of the line that contains the matching opening paren.
    setlocal cinoptions+=m1

    setlocal sw=2 sts=2 tw=79
endfunction
command! -bar SetupGnuSource call SetupGnuSource()

function! SetupDiff()
    SetupText
    call CreateTextobjDiffLocalMappings()
endfunction
command! -bar SetupDiff call SetupDiff()

function! SetupAsm()
    SetupSource
endfunction
command! -bar SetupAsm call SetupAsm()

function! SetupJava()
    SetupSource
    setlocal omnifunc=javacomplete#Complete

    " Setup better linewise comments for Java.
    setlocal commentstring=//\ %s

    " [[, ]], and friends don't work well in Java.  Map them to
    " the "method" equivalents instead.
    nnoremap <buffer> [[ [m
    nnoremap <buffer> [] [M
    nnoremap <buffer> ]] ]m
    nnoremap <buffer> ][ ]M
    xnoremap <buffer> [[ [m
    xnoremap <buffer> [] [M
    xnoremap <buffer> ]] ]m
    xnoremap <buffer> ][ ]M
endfunction
command! -bar SetupJava call SetupJava()

function! SetupTmux()
    SetupSource
endfunction
command! -bar SetupTmux call SetupTmux()

function! SetupToml()
    SetupSource
    setlocal sts=2 sw=2
    let b:SpellType = "<toml>"
endfunction
command! -bar SetupToml call SetupToml()
let g:SpellMap["<toml>"] = "<off>"

function! SetupYaml()
    SetupSource
    setlocal sts=2 sw=2
    let b:SpellType = "<yaml>"
endfunction
command! -bar SetupYaml call SetupYaml()
let g:SpellMap["<yaml>"] = "<off>"

function! SetupYamlIndent()
    " This function used to remove some keys from `indentkeys`, but use of
    " `indentkeys` has become an important feature for editing YAML because
    " indentation logic in recent Vim indents after a key:value pair until a
    " subsequent key:value pair is typed (signified by pressing `:`).  For
    " example, typing the text "key1: value1<CR>key2" yields:
    "   key1: value1
    "     key2
    "
    " But typing the additional text ": value2" causes re-indentation (due to
    " the `:` key), yielding the expected:
    "   key1: value1
    "   key2: value2
    "
    " This function is being kept as a placeholder for the future.
endfunction
command! -bar SetupYamlIndent call SetupYamlIndent()

function! IndentZ80()
    if getline(v:lnum) =~ '^\s*\w\+:$'
        return 0
    elseif getline(v:lnum) =~ '^\s*#'
        return 0
    elseif v:lnum > 1 && getline(v:lnum - 1) =~ '^\s*\w\+:$'
        return 8
    else
        return indent(v:lnum)
    endif
endfunction

function! SetupZ80()
    SetupSource

    " Use 8-space indentation.
    setlocal sts=8 sw=8

    setlocal indentexpr=IndentZ80()
    setlocal indentkeys=!^F,o,O,<:>,0#
    setlocal commentstring=;%s
    " It's too jarring to have ; and . be part of iskeyword.
    setlocal iskeyword-=.
    setlocal iskeyword-='

    let b:SpellType = "<z80>"
endfunction
command! -bar SetupZ80 call SetupZ80()
let g:SpellMap["<z80>"] = "<off>"

" =============================================================
" Syntax highlighting and filetype support
" =============================================================

" NOTE: This must be done after bundles have been loaded and support functions
" have been defined, etc.

" Provide an indication that filetype support is ready.
" Filetype-related files should check exists('g:VimfilesFiletypeReady')
" before calling functions defined in vimrc.
let g:VimfilesFiletypeReady = 1

" Enable filetype detection, filetype plugins, and filetype-specific
" indentation.
filetype plugin indent on

" Enable syntax highlighting and search highlighting when colors available.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

" =============================================================
" Autocmds
" =============================================================

function! AutoRestoreLastCursorPosition()
    " Restore the position only for regular buffers.
    if &buftype != ''
        return
    endif
    " If b:startAtTop exists, jump to the top of the file; otherwise,
    " if possible, jump to last known cursor position for this file.
    " Avoid jumping if the position would be invalid for this file.
    if exists("b:startAtTop")
        silent! normal! gg
    elseif line("'\"") > 0 && line("'\"") <= line("$")
        silent! execute "normal! g`\""
    endif
endfunction

function! AutoOpenGitDiff()
    " Show diffs for this Git commit.
    " The fugitive plugin uses a previewwindow for the :Gstatus command,
    " but it sets the filetype of that windows to 'gitcommit', so don't
    " open a diff window if the gitcommit is in a previewindow.
    " Also, when using ``:Gedit :``,  the .git/index file is opened
    " in a regular window using filetype 'gitcommit', so avoid opening
    " a diff window in that case as well, as suggested by Tim Pope here:
    " https://github.com/tpope/vim-fugitive/issues/294#issuecomment-12474356
    " Note that checking for 'index' is not sufficient in itself, because
    " using :Gstatus followed by attempting a commit via ``cc`` does not
    " work properly in that event (the COMMIT_MSG window will not have
    " the correct contents).
    if ! &previewwindow && expand('%:t') !~# 'index'
        DiffGitCached
        wincmd p
        wincmd K
        resize 15
    endif
endfunction

function! AutoCloseGitDiff()
    " Close any preview window when finished with a 'gitcommit' buffer.
    " Since :DiffGitCached uses a preview window for diffs, this will
    " close out any diff window that might be hanging around.
    if &ft == 'gitcommit'
        pclose
    endif
endfunction

" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

function! ChangeRebaseAction(action)
    let ptn = '^\(pick\|reword\|edit\|squash\|fixup\|exec\|p\|r\|e\|s\|f\|x\)\s'
    let line = getline(".")
    let result = matchstr(line, ptn)
    if result != ""
        execute "normal! ^cw" . a:action
        execute "normal! ^"
    endif
endfunction

function! SetupRebaseMappings()
    nnoremap <buffer> <Leader><Leader>e
            \ :call ChangeRebaseAction('edit') <bar>
            \ silent! call repeat#set("\<Leader>\<Leader>e")<CR>
    nnoremap <buffer> <Leader><Leader>f
            \ :call ChangeRebaseAction('fixup') <bar>
            \ silent! call repeat#set("\<Leader>\<Leader>f")<CR>
    nnoremap <buffer> <Leader><Leader>p
            \ :call ChangeRebaseAction('pick') <bar>
            \ silent! call repeat#set("\<Leader>\<Leader>p")<CR>
    nnoremap <buffer> <Leader><Leader>r
            \ :call ChangeRebaseAction('reword') <bar>
            \ silent! call repeat#set("\<Leader>\<Leader>r")<CR>
    nnoremap <buffer> <Leader><Leader>s
            \ :call ChangeRebaseAction('squash') <bar>
            \ silent! call repeat#set("\<Leader>\<Leader>s")<CR>
endfunction

" Put these in an autocmd group, so that we can delete them easily.
augroup local_vimrc
    " First, remove all autocmds in this group.
    autocmd!

    " Auto-commands are done in order; however, note that FileType events
    " generally fire before BufReadPost events.

    " Start at top-of-file for Subversion commit messages.
    autocmd FileType svn SetupSvn | let b:startAtTop = 1

    " Start at top-of-file for Git-related files.
    autocmd FileType gitcommit,gitrelated,gitrebase SetupGit |
            \ let b:startAtTop = 1

    " When editing a file, jump to the last known cursor position.
    autocmd BufReadPost * call AutoRestoreLastCursorPosition()

    " Open a diff window for Git commits.
    autocmd FileType gitcommit call AutoOpenGitDiff()

    " Close diff window after a Git commit.
    autocmd BufUnload * call AutoCloseGitDiff()

    " Add interactive rebase mappings when doing a `git rebase`.
    autocmd FileType gitrebase call SetupRebaseMappings()

    " By default, when Vim switches buffers in a window, the new buffer's
    " cursor position is scrolled to the center (as if 'zz' had been
    " issued).  This fix restores the buffer's position.
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()

    " Set makeprg for *.snippet.py files.
    autocmd BufRead,BufNewFile *.snippets.py
            \ setlocal makeprg=make\ -s\ -C\ %:p:h
    " Do not allow writing a file named apostrophe (a too-common error
    " for Mike on his laptop keyboard).
    autocmd BufWritePre  ' throw "Do not write ' as a filename"
augroup END

" Support for gpg-encrypted files.
augroup local_encrypted
    " First, remove all autocmds in this group.
    autocmd!

    " First make sure nothing is written to ~/.viminfo while editing
    " an encrypted file.
    autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
    " We don't want a swap file, as it writes unencrypted data to disk
    autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
    " Switch to binary mode to read the encrypted file
    autocmd BufReadPre,FileReadPre      *.gpg set bin
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPre,FileReadPre      *.gpg let shsave=&sh
    autocmd BufReadPre,FileReadPre      *.gpg let &sh='sh'
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt
            \   --default-recipient-self 2> /dev/null
    autocmd BufReadPost,FileReadPost    *.gpg let &sh=shsave

    " Switch to normal mode for editing
    autocmd BufReadPost,FileReadPost    *.gpg set nobin
    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|
            \   unlet ch_save
    autocmd BufReadPost,FileReadPost    *.gpg execute
            \   ":doautocmd BufReadPost " . expand("%:r")

    " Convert all text to encrypted text before writing
    autocmd BufWritePre,FileWritePre    *.gpg set bin
    autocmd BufWritePre,FileWritePre    *.gpg let shsave=&sh
    autocmd BufWritePre,FileWritePre    *.gpg let &sh='sh'
    autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --encrypt
            \   --default-recipient-self 2>/dev/null
    autocmd BufWritePre,FileWritePre    *.gpg let &sh=shsave

    " Undo the encryption so we are back in the normal text, directly
    " after the file has been written.
    autocmd BufWritePost,FileWritePost  *.gpg   silent u
    autocmd BufWritePost,FileWritePost  *.gpg set nobin
augroup END

" Spell-check autocmd group.
" This group should come after most FileType-related auto-commands, since
" these other auto-commands might influence whether spell-checking should
" be on.
augroup local_spell
    " First, remove all autocmds in this group.
    autocmd!
    autocmd FileType * call SetSpell()
augroup END

" Re-apply highlight groups on syntax change.
" This should come after "syntax on" so it will be invoked after Vim-supplied
" autocmds.
augroup local_HighlightApply
    " First, remove all autocmds in this group.
    autocmd!

    " Re-apply highlight groups defined via :Highlight command.
    " Older Vim versions can clear the associated Highlight syntax groups,
    " so this autocmd (which comes after "syntax on") will run afterward
    " to apply those groups again.
    autocmd Syntax * call HighlightApply()

    if exists('##OptionSet')
        autocmd OptionSet textwidth call HighlightApply()
    endif
augroup END

" =============================================================
" Status line
" =============================================================

" Function used to display syntax group.
function! SyntaxItem()
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction

" Function used to display utf-8 sequence.
function! ShowUtf8Sequence()
    try
        let p = getpos('.')
        redir => utfseq
        sil normal! g8
        redir End
        call setpos('.', p)
        " 12 34 56 ==> 0x12 0x34 0x56
        return substitute(matchstr(utfseq, '\x\+ .*\x'), '\<\x', '0x&', 'g')
    catch
        return '?'
    endtry
    "  ²´´
endfunction

" @todo Define User1, User2, User3, and User4 highlight groups.
if has('statusline') && version >= 700
    " Default status line:
    " set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
    set statusline=
    set statusline+=%#User1#                       " Highlighting
    set statusline+=%-3n\                          " Buffer number

    set statusline+=%#User2#                       " Highlighting
    set statusline+=%<                             " Truncate here
    set statusline+=%f\                            " File name
    set statusline+=%#User1#                       " Highlighting

    set statusline+=%h                             " [help]
    set statusline+=%m                             " [+] (modified)
    set statusline+=%r                             " [RO]
    set statusline+=%w                             " [Preview]
    set statusline+=\                              " Space

"   set statusline+=%{strlen(&ft)?&ft:'none'},     " File type
    if usingTagbar
        set statusline+=%{tagbar#currenttag('[%s]','')} " Function name
    endif
"   set statusline+=,%{SyntaxItem()}               " Syntax group under cursor
    set statusline+=\                              " Space

    set statusline+=%=                             " Separate left from right.

    set statusline+=%#User2#                       " Highlighting
"   set statusline+=%{ShowUtf8Sequence()}\         " Utf-8 sequence
    set statusline+=%#User1#                       " Highlighting

"   set statusline+=U+%04B\                        " Unicode char under cursor
    set statusline+=%-6.(%l,%c%V%)\ %P             " Position

    " Use different colors for statusline in current and non-current window.
    let g:Active_statusline=&g:statusline
    let g:NCstatusline=substitute(
            \                substitute(g:Active_statusline,
            \                'User1', 'User3', 'g'),
            \                'User2', 'User4', 'g')
    au! WinEnter * let&l:statusline = g:Active_statusline
    au! WinLeave * let&l:statusline = g:NCstatusline
endif

" When to show a statusline:
" 0 - never.
" 1 - if more than one window (default).
" 2 - always.
set laststatus=2


" -------------------------------------------------------------
" "vimrc-after" overrides
" -------------------------------------------------------------

" Execute in lowest-to-highest priority order, so that highest-priority
" gets the last word.
call Source('$VIMLOCALFILES/vimrc-after.vim')
call Source('$VIMUSERFILES/vimrc-after.vim')
call Source('$VIMUSERLOCALFILES/vimrc-after.vim')
