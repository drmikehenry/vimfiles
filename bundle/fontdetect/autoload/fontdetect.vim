" Detect installed fonts.

" Distributed under Vim's |license|; see |fontdetect.txt| for details.

if exists("loaded_fontdetect")
    finish
endif
let loaded_fontdetect = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" Private functions.

" Query Windows registry to return list of all installed font families.
function! fontdetect#_listFontFamiliesUsingWindowsRegistry()
    if !executable("reg")
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

if has("python")
" Python function for detecting installed font families using Cocoa.
python << endpython
def fontdetect_listFontFamiliesUsingCocoa():
    try:
        import Cocoa
    except ImportError:
        return []
    manager = Cocoa.NSFontManager.sharedFontManager()
    fontFamilies = list(manager.availableFontFamilies())
    return fontFamilies
endpython
endif

" Use Cocoa font manager to return list of all installed font families.
function! fontdetect#_listFontFamiliesUsingCocoa()
    if has("python")
        return pyeval("fontdetect_listFontFamiliesUsingCocoa()")
    else
        return []
    endif
endfunction

" Use fontconfig's ``fc-list`` to return list of all installed font families.
function! fontdetect#_listFontFamiliesUsingFontconfig()
    if !executable("fc-list")
        return []
    endif
    let fcOutput = system("fc-list --format '%{family}\n'")
    return split(fcOutput, '\n')
endfunction

function! fontdetect#_fontDict()
    if exists('g:fontdetect#_cachedFontDict')
        return g:fontdetect#_cachedFontDict
    endif
    if has("win32")
        let families = fontdetect#_listFontFamiliesUsingWindowsRegistry()
    elseif has("macunix")
        let families = fontdetect#_listFontFamiliesUsingCocoa()
        if len(families) == 0
            " Try falling back on Fontconfig.
            let families = fontdetect#_listFontFamiliesUsingFontconfig()
        endif
    elseif executable("fc-list")
        let families = fontdetect#_listFontFamiliesUsingFontconfig()
    else
        let families = []
    endif
    if len(families) == 0
        echomsg "No way to detect fonts"
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
    return ""
endfunction

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
