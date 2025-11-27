" Autoload portion of plugin/fontsize.vim.

if exists("autoloaded_fontsize")
    finish
endif
let autoloaded_fontsize = 1

let s:hasFloat = has('float')

" Font examples from http://vim.wikia.com/wiki/VimTip632

" Regex values for each platform split guifont into three
" sections (\1, \2, and \3 in capturing parentheses):
"
" - prefix
" - size (possibly fractional)
" - suffix (possibly including extra fonts after commas)

let s:size_suffix_vregex = '(\d+%(\.\d*)?|\.\d+)' . '(.*)'

" gui_gtk2: `Courier New 11`
let fontsize#regex_gtk2 = '\v^(.{-} )' . s:size_suffix_vregex

" gui_photon: `Courier New:s11`
let fontsize#regex_photon = '\v^(.{-}:s)' . s:size_suffix_vregex

" gui_kde: `Courier New/11/-1/5/50/0/0/0/1/0`
let fontsize#regex_kde = '\v^(.{-}/)' . s:size_suffix_vregex

" gui_x11: `-*-courier-medium-r-normal-*-*-180-*-*-m-*-*`
" TODO For now, just taking the first string of digits.
let fontsize#regex_x11 = '\v^(.{-}-)' . s:size_suffix_vregex

" gui_haiku: `Terminus (TTF)/Medium/20`
let fontsize#regex_haiku = '\v^([^/]*/[^/]*/)' . s:size_suffix_vregex

" gui_other: `Courier_New:h11:cDEFAULT`
let fontsize#regex_other = '\v^(.{-}:h)' . s:size_suffix_vregex

if has("gui_gtk2") || has("gui_gtk3")
    let s:regex = fontsize#regex_gtk2
elseif has("gui_photon")
    let s:regex = fontsize#regex_photon
elseif has("gui_kde")
    let s:regex = fontsize#regex_kde
elseif has("x11")
    let s:regex = fontsize#regex_x11
elseif has("haiku")
    let s:regex = fontsize#regex_haiku
else
    let s:regex = fontsize#regex_other
endif

function! fontsize#getFontName()
    " On Neovim, `getfontname()` always returns the empty string; however,
    " Neovim GUIs seem to support the 'guifont' option.  Unlike Gvim (which
    " supports multiple comma-separated fonts in 'guifont'), Neovim GUIs seem
    " to support only a single font in 'guifont'.  Try `getfontname()` first to
    " handle the Gvim cases smoothly (such as when 'guifont' is empty, or
    " contains multiple fonts, or contains an invalid font), but fall back to
    " using 'guifont' directly if `getfontname()` returns the empty string.
    let fontName = getfontname()
    if fontName == ''
        let fontName = &guifont
    endif
    return fontName
endfunction

function! fontsize#setFontName(fontName)
    " `nvim-qt` has a `GuiFont(fontName, force)` function for changing the font.
    " Though `nvim-qt` also seems to support assigning to the 'guifont'
    " option, this causes various warnings and bad behavior for some fonts
    " (notably "Hack" and "Consolas"), such as:
    "   Warning: Font "Hack" reports bad fixed pitch metrics
    " Without the `force=1` argument, the `GuiFont()` function generates the
    " same warnings.
    " `neovide` lacks a `GuiFont()` function, but it seems well behaved when
    " changing the font by assigning to the 'guifont' option.
    if exists('*GuiFont')
        call GuiFont(a:fontName, 1)
    else
        let &guifont = a:fontName
    endif
endfunction

function! fontsize#setFontNameWide(fontName)
    " NOTE: `GuiFont()` doesn't work for the 'guifontwide' option.
    let &guifontwide = a:fontName
endfunction

function! fontsize#encodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let encodedFont = iconv(a:font, &enc, g:fontsize#encoding)
    else
        let encodedFont = a:font
    endif
    return encodedFont
endfunction

function! fontsize#decodeFont(font)
    if has("iconv") && exists("g:fontsize#encoding")
        let decodedFont = iconv(a:font, g:fontsize#encoding, &enc)
    else
        let decodedFont = a:font
    endif
    return decodedFont
endfunction

" Return integer when font size is an integer.  For fractional font size, return
" float if floating point is supported, and string otherwise.
function! fontsize#normalizeSize(size)
    " Treat as a string by concatenating ''.
    " Remove any suffix consisting solely of a decimal point and some number of
    " zeros.
    let size_str = substitute(a:size . '', '\.0*$', '', '')
    if size_str !~ '\.'
        " No fractional portion; return integer.
        return str2nr(size_str)
    endif
    if s:hasFloat
        return str2float(size_str)
    endif
    " Must keep as a string.
    return size_str
endfunction

function! fontsize#testNorm()
    let v:errors = []

    let size = fontsize#normalizeSize(2)
    call assert_equal(type(size), type(2))
    call assert_equal(size, 2)
    let size = fontsize#normalizeSize('2.')
    call assert_equal(type(size), type(2))
    call assert_equal(size, 2)
    let size = fontsize#normalizeSize('2.0')
    call assert_equal(type(size), type(2))
    call assert_equal(size, 2)

    if has('float')
        let size = fontsize#normalizeSize(2.0)
        call assert_equal(type(size), type(2))
        call assert_equal(size, 2)
        let size = fontsize#normalizeSize(2.5)
        call assert_equal(type(size), type(2.5))
        call assert_equal(size, 2.5)
        let size = fontsize#normalizeSize('.2')
        call assert_equal(type(size), type(0.2))
        call assert_equal(size, 0.2)
    endif

    let s:hasFloat = 0
    let size = fontsize#normalizeSize('2.5')
    call assert_equal(type(size), type('2.5'))
    call assert_equal(size, '2.5')
    let s:hasFloat = has('float')

    for e in v:errors
        echoerr e
    endfor
endfunction

" `size` will be normalized; `delta` must be numeric but may be negative.
" If sum would be negative, return normalized `size`.
function! fontsize#addSize(size, delta)
    let normSize = fontsize#normalizeSize(a:size)
    if type(normSize) == type('')
        " Must not have floating point, so `a:delta` must be integer.
        " Trim leading digits to acquire any fractional suffix.
        let suffix = substitute(normSize, '^\d\+', '', '')
        let size = str2nr(normSize)
    else
        let suffix = ''
        let size = normSize
    endif
    " `size` is numeric.
    if size + a:delta > 0
        let size += a:delta
    endif
    if suffix != ''
        " Must not have floating point, so `size` is integer here.
        return size . suffix
    endif
    return size
endfunction

" Return normalized size (see `fontsize#normalizeSize()`.
function! fontsize#getSize(font)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        let size_str = substitute(decodedFont, s:regex, '\2', '')
        let size = fontsize#normalizeSize(size_str)
    else
        let size = 0
    endif
    return size
endfunction

" `size` may be integer, float, or string.
function! fontsize#setSize(font, size)
    let decodedFont = fontsize#decodeFont(a:font)
    if match(decodedFont, s:regex) != -1
        let newFont = substitute(decodedFont, s:regex, '\1' . a:size . '\3', '')
    else
        let newFont = decodedFont
    endif
    return fontsize#encodeFont(newFont)
endfunction

function! fontsize#fontString(font)
    let fontName = fontsize#decodeFont(a:font)
    if len(fontName) == 0
        let fontName = "(Empty)"
        let fontSize = 0
    else
        let fontSize = fontsize#getSize(fontName)
    endif
    let maxFontLen = 50
    if len(fontName) > maxFontLen
        let fontName = fontName[:maxFontLen - 4] . "..."
    endif
    if fontSize == 0
        let fontString = "??: " . fontName
    else
        let fontString = fontSize . ": " . fontName
    endif
    return fontString
endfunction

function! fontsize#display()
    redraw
    sleep 100m
    echo fontsize#fontString(fontsize#getFontName()) . " (+/= - 0 ! q CR SP)"
endfunction

" True when options have already been setup.
let g:fontsize#optionsActive = 0

function! fontsize#setupOptions()
    if g:fontsize#optionsActive
        return
    endif
    let g:fontsize#optionsActive = 1
    let g:fontsize#original_timeout = &timeout
    let g:fontsize#original_timeoutlen = &timeoutlen
    let g:fontsize#original_ttimeout = &ttimeout
    let g:fontsize#original_ttimeoutlen = &ttimeoutlen

    let mappingTimeout = &timeout
    let mappingTimeoutMsec = &timeoutlen
    let keyCodeTimeout = &timeout || &ttimeout
    let keyCodeTimeoutMsec = &ttimeoutlen < 0 ?  &timeoutlen : &ttimeoutlen

    if exists("g:fontsize#timeout")
        let modeTimeout = g:fontsize#timeout
    else
        let modeTimeout = &timeout
    endif
    if exists("g:fontsize#timeoutlen")
        let modeTimeoutMsec = g:fontsize#timeoutlen
    else
        let modeTimeoutMsec = &timeoutlen
    endif

    " In the worst case, the user had no keyCodeTimeout, but he wants "font
    " size" mode to timeout.  This means we have to enable a mapping timeout
    " which has the unfortunate side-effect of turning on the keyCodeTimeout.
    " The best we can do is make a long keyCodeTimeoutMsec in this case.
    if !keyCodeTimeout
        let keyCodeTimeoutMsec = 10000
    endif

    " Apply the user's effective keyCodeTimeout settings.
    let &ttimeoutlen = keyCodeTimeoutMsec
    let &ttimeout = keyCodeTimeout

    " To avoid any hint of a race condition, change 'timeoutlen' only if
    " we are going to enable timeouts.
    if modeTimeout
        let &timeoutlen = modeTimeoutMsec
    endif
    let &timeout = modeTimeout
endfunction

function! fontsize#restoreOptions()
    if !g:fontsize#optionsActive
        return
    endif
    let &timeout = g:fontsize#original_timeout
    let &timeoutlen = g:fontsize#original_timeoutlen
    let &ttimeout = g:fontsize#original_ttimeout
    let &ttimeoutlen = g:fontsize#original_ttimeoutlen
    let g:fontsize#optionsActive = 0
endfunction

function! fontsize#begin()
    call fontsize#setupOptions()
    call fontsize#display()
endfunction

function! fontsize#quit()
    echo fontsize#fontString(fontsize#getFontName()) . " (Done)"
    call fontsize#restoreOptions()
endfunction

function! fontsize#default()
    call fontsize#setupOptions()
    call fontsize#setFontName(
            \ fontsize#setSize(fontsize#getFontName(), g:fontsize#defaultSize))
    call fontsize#setFontNameWide(
            \ fontsize#setSize(&guifontwide, g:fontsize#defaultSize))
    call fontsize#display()
endfunction

function! fontsize#setDefault()
    call fontsize#setupOptions()
    let g:fontsize#defaultSize = fontsize#getSize(fontsize#getFontName())
endfunction

function! fontsize#add(delta)
    call fontsize#setupOptions()
    let oldSize = fontsize#getSize(fontsize#getFontName())
    let newSize = fontsize#addSize(oldSize, a:delta)
    call fontsize#setFontName(fontsize#setSize(fontsize#getFontName(), newSize))
    call fontsize#setFontNameWide(
            \ fontsize#setSize(&guifontwide, newSize))
    call fontsize#display()
endfunction

function! fontsize#inc()
    call fontsize#add(v:count1 * g:fontsize#stepSize)
endfunction

function! fontsize#dec()
    call fontsize#add(-v:count1 * g:fontsize#stepSize)
endfunction

function! fontsize#testRegexes()
    let v:errors = []

    " gui_gtk2:
    let m = matchlist('Courier New ', g:fontsize#regex_gtk2)
    call assert_equal(m, [])
    let m = matchlist('Courier New11', g:fontsize#regex_gtk2)
    call assert_equal(m, [])
    let m = matchlist('Courier New 11', g:fontsize#regex_gtk2)
    call assert_equal(m[1], 'Courier New ')
    call assert_equal(m[2], '11')
    call assert_equal(m[3], '')
    let m = matchlist('Courier New 11.25', g:fontsize#regex_gtk2)
    call assert_equal(m[1], 'Courier New ')
    call assert_equal(m[2], '11.25')
    call assert_equal(m[3], '')
    let m = matchlist('Courier New 11.', g:fontsize#regex_gtk2)
    call assert_equal(m[1], 'Courier New ')
    call assert_equal(m[2], '11.')
    call assert_equal(m[3], '')
    let m = matchlist('Courier New .9', g:fontsize#regex_gtk2)
    call assert_equal(m[1], 'Courier New ')
    call assert_equal(m[2], '.9')
    call assert_equal(m[3], '')
    let m = matchlist('Courier New .', g:fontsize#regex_gtk2)
    call assert_equal(m, [])

    " gui_photon:
    let m = matchlist('Courier New:11', g:fontsize#regex_photon)
    call assert_equal(m, [])
    let m = matchlist('Courier New:s11', g:fontsize#regex_photon)
    call assert_equal(m[1], 'Courier New:s')
    call assert_equal(m[2], '11')
    call assert_equal(m[3], '')
    let m = matchlist('Courier New:s11.25', g:fontsize#regex_photon)
    call assert_equal(m[1], 'Courier New:s')
    call assert_equal(m[2], '11.25')
    call assert_equal(m[3], '')

    " gui_kde:
    let m = matchlist('Courier New 11', g:fontsize#regex_kde)
    call assert_equal(m, [])
    let m = matchlist('Courier New/11/-1/5/50/0/0/0/1/0', g:fontsize#regex_kde)
    call assert_equal(m[1], 'Courier New/')
    call assert_equal(m[2], '11')
    call assert_equal(m[3], '/-1/5/50/0/0/0/1/0')
    let m = matchlist('Courier New/11.25/-1/5/50/0/0/0/1/0', g:fontsize#regex_kde)
    call assert_equal(m[1], 'Courier New/')
    call assert_equal(m[2], '11.25')
    call assert_equal(m[3], '/-1/5/50/0/0/0/1/0')

    " gui_x11:
    let m = matchlist('/*/courier/medium/r/normal/*/*/180/*/*/m/*/*',
            \ g:fontsize#regex_x11)
    call assert_equal(m, [])
    let m = matchlist('-*-courier-medium-r-normal-*-*-180-*-*-m-*-*',
            \ g:fontsize#regex_x11)
    call assert_equal(m[1], '-*-courier-medium-r-normal-*-*-')
    call assert_equal(m[2], '180')
    call assert_equal(m[3], '-*-*-m-*-*')
    let m = matchlist('-*-courier-medium-r-normal-*-*-180.25-*-*-m-*-*',
            \ g:fontsize#regex_x11)
    call assert_equal(m[1], '-*-courier-medium-r-normal-*-*-')
    call assert_equal(m[2], '180.25')
    call assert_equal(m[3], '-*-*-m-*-*')

    " gui_haiku:
    let m = matchlist('Terminus (TTF) Medium/20', g:fontsize#regex_haiku)
    call assert_equal(m, [])
    let m = matchlist('Terminus (TTF)/Medium/20', g:fontsize#regex_haiku)
    call assert_equal(m[1], 'Terminus (TTF)/Medium/')
    call assert_equal(m[2], '20')
    call assert_equal(m[3], '')
    let m = matchlist('Terminus (TTF)/Medium/20.25', g:fontsize#regex_haiku)
    call assert_equal(m[1], 'Terminus (TTF)/Medium/')
    call assert_equal(m[2], '20.25')
    call assert_equal(m[3], '')

    " gui_other:
    let m = matchlist('Courier_New:11:cDEFAULT', g:fontsize#regex_other)
    call assert_equal(m, [])
    let m = matchlist('Courier_New:h11:cDEFAULT', g:fontsize#regex_other)
    call assert_equal(m[1], 'Courier_New:h')
    call assert_equal(m[2], '11')
    call assert_equal(m[3], ':cDEFAULT')
    let m = matchlist('Courier_New:h11.25:cDEFAULT', g:fontsize#regex_other)
    call assert_equal(m[1], 'Courier_New:h')
    call assert_equal(m[2], '11.25')
    call assert_equal(m[3], ':cDEFAULT')

    for e in v:errors
        echoerr e
    endfor
endfunction

function! fontsize#test()
    call fontsize#testNorm()
    call fontsize#testRegexes()
endfunction

" Setup default variables.
if !exists("g:fontsize#defaultSize")
    let g:fontsize#defaultSize = 0
endif
if g:fontsize#defaultSize == 0
    let g:fontsize#defaultSize = fontsize#getSize(fontsize#getFontName())
endif

if !exists("g:fontsize#stepSize")
    let g:fontsize#stepSize = 1
endif

" vim: sts=4 sw=4 tw=80 et ai:
