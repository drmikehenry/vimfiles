" Detect installed fonts.

" Distributed under Vim's |license|; see |fontdetect.txt| for details.

if exists('g:autoloaded_fontdetect')
    finish
endif
let g:autoloaded_fontdetect = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" Private functions and variables.

" Query Windows registry to return list of all installed font families.
function! fontdetect#_listFontFamiliesUsingWindowsRegistry()
    if !executable('reg')
        return []
    endif
    let regOutput = system('reg query "HKLM\SOFTWARE\Microsoft' .
                \ '\Windows NT\CurrentVersion\Fonts"')

    " Remove registry key at start of output.
    let regOutput = substitute(regOutput,
            \ '.\{-}HKEY_LOCAL_MACHINE.\{-}\n',
            \ '', '')

    " Remove blank lines.
    let regOutput = substitute(regOutput, '\n\n\+', '\n', 'g')

    " Extract font family from each line.  Lines have one of the following
    " formats; all begin with leading spaces and can have spaces in the
    " font family portion:
    "   Font family REG_SZ FontFilename
    "   Font family (TrueType) REG_SZ FontFilename
    "   Font family 1,2,3 (TrueType) REG_SZ FontFilename
    " Throw away everything before and after the font family.
    " Assume that any '(' is not part of the family name.
    " Assume digits followed by comma indicates point size.
    let regOutput = substitute(regOutput,
            \ ' *\(.\{-}\)\ *' .
            \ '\((\|\d\+,\|REG_SZ\)' .
            \ '.\{-}\n',
            \ '\1\n', 'g')

    return split(regOutput, '\n')
endfunction

" Double any quotes in string, then wrap with quotes for eval().
function! fontdetect#_quote(string)
    return "'" . substitute(a:string, "'", "''", 'g') . "'"
endfunction

" Use fontconfig's ``fc-list`` to return list of all installed font families.
function! fontdetect#_listFontFamiliesUsingFontconfig()
    if !executable('fc-list')
        return []
    endif
    let fcOutput = system("fc-list --format '%{family}\n'")
    return split(fcOutput, '\n')
endfunction

" Helper for processing entries from ``atsutil``.
function! fontdetect#_stripEntry(s)
    let ret = substitute(a:s, '^\s\+', '', '')
    return substitute(ret, '\s\+$', '', '')
endfunction

" Use macOS's ``atsutil`` to return a list of all installed fonts.
" This technique returns more than expected as it includes variant
" names (bold, italic, etc.).  But it does include the family too.
" Note: atsutil has been around since OS X 10.5.
function! fontdetect#_listFontFamiliesUsingAtsutil()
    if !executable("atsutil")
        return []
    endif

    let atsOutput = system('atsutil fonts -list')
    let atsOutput = split(atsOutput, '\n',)

    " Drop all headings
    let atsOutput = filter(atsOutput, 'v:val !~ ":$"')

    " Remove all leading and trailing whitespace.
    let atsOutput = map(atsOutput, 'fontdetect#_stripEntry(v:val)')

    return atsOutput
endfunction

function! fontdetect#_fontDict()
    if exists('g:fontdetect#_cachedFontDict')
        return g:fontdetect#_cachedFontDict
    endif
    if has('win32')
        let families = fontdetect#_listFontFamiliesUsingWindowsRegistry()
    elseif has('macunix')
        let families = fontdetect#_listFontFamiliesUsingAtsutil()
        if len(families) == 0
            " Try falling back on Fontconfig.
            let families = fontdetect#_listFontFamiliesUsingFontconfig()
        endif
    elseif executable('fc-list')
        let families = fontdetect#_listFontFamiliesUsingFontconfig()
    else
        let families = []
    endif
    if len(families) == 0
        echomsg 'No way to detect fonts'
    endif
    let g:fontdetect#_cachedFontDict = {}
    for fontFamily in families
        let g:fontdetect#_cachedFontDict[fontFamily] = 1
    endfor
    return g:fontdetect#_cachedFontDict
endfunction

" Public functions.

function! fontdetect#hasFontFamily(fontFamily)
    return has_key(fontdetect#_fontDict(), a:fontFamily)
endfunction

function! fontdetect#firstFontFamily(fontFamilies)
    for fontFamily in a:fontFamilies
        if fontdetect#hasFontFamily(fontFamily)
            return fontFamily
        endif
    endfor
    return ''
endfunction

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
