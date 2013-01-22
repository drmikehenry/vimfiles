" Tag Signature Balloon
"   Author: A. S. Budden
"## Date::   15th August 2012        ##

if v:version < 700
	finish
endif

try
	if &cp || ! has('balloon_eval') || (exists('g:loaded_tag_signature') && (g:plugin_development_mode != 1))
		throw "Already loaded"
	endif
catch
	finish
endtry
let g:loaded_tag_signature = 1

if !exists('g:TagSignatureAllowFileLoading')
	let g:TagSignatureAllowFileLoading = 1
endif

if !exists('g:TagSignatureMaxMatches')
	let g:TagSignatureMaxMatches = 1
endif

function! FindTypeTag(cmd, filename, maxlines)
	let s = ""
	let SearchString = substitute(a:cmd, '/\(.*\)/', '\1', '')
	let FileContents = readfile(a:filename)
	" Find the tag line (which will be the end of the typedef),
	" then search back for the start of the typedef
	"
	" This is a bit messy, but I haven't found a better way
	" of doing it.
	for index in range(len(FileContents))
		if FileContents[index] =~ SearchString
			" Search back to find the start
			if FileContents[index] !~ 'typedef'
				" This line doesn't contain the typedef
				for StartIndex in range(index-1, 0, -1)
					if FileContents[StartIndex] =~ 'typedef'
						" We've found the start and end
						let s = FileContents[StartIndex]
						if a:maxlines <= 6
							let s = s . "\n\t\t" . "... [skipped] ... " . "\n" . FileContents[index]
						elseif (index - StartIndex) > a:maxlines
							if a:maxlines < 12
								let BlockSize = (a:maxlines / 2) - 1
							else
								let BlockSize = 5
							endif

							for i in range(StartIndex+1, StartIndex+BlockSize)
								let s = s . "\n" . FileContents[i]
							endfor
							let s = s . "\n\n\t\t... [skipped] ...\n\n"
							for i in range(index-BlockSize, index)
								let s = s . "\n" . FileContents[i]
							endfor
						else
							for i in range(StartIndex+1, index)
								let s = s . "\n" . FileContents[i]
							endfor
						endif
						break
					endif
				endfor
			endif
			break
		endif
	endfor

	return s
endfunction

let s:CStyleFunctionKindLookup =
			\ {
			\     'java':       ['m'],
			\     'perl':       ['s'],
			\     'c#':         ['m'],
			\     'c':          ['f', 'p'],
			\     'c++':        ['f', 'p'],
			\     'javascript': ['f']
			\ }

let s:CStyleTypeKindLookup = 
			\ {
			\     'c': 't',
			\     'c++': 't'
			\ }

function! GetTagSignature()
	if v:beval_text !~ '^\k\+$'
		return
	endif

	let TagList = taglist('^' . v:beval_text . '$')
	let result = ""

	let MaxLines = 20 / g:TagSignatureMaxMatches

	if len(TagList) > 0
		let IndexCount = len(TagList)
		if IndexCount > g:TagSignatureMaxMatches
			let IndexCount = g:TagSignatureMaxMatches
		endif

		let result = ""

		let Index = 0
		while Index < IndexCount
			let s = ""

			if TagList[Index]['cmd'] =~ '^\d\+$'
				" Handle links to specific lines in a source file
				let LineNum = str2nr(TagList[Index]['cmd'])
				let FileName = TagList[Index]['filename']
				if bufexists(FileName) && (len(getbufline(FileName, LineNum)) > 0)
					" An open source file
					let s = getbufline(FileName, LineNum)[0]
				elseif (g:TagSignatureAllowFileLoading == 1) && filereadable(FileName)
					" A non-open source file
					let s = readfile(FileName, '', LineNum)[LineNum-1]
				endif
			elseif index(keys(s:CStyleFunctionKindLookup), &ft) != -1
						\ && index(s:CStyleFunctionKindLookup[&ft], TagList[Index]['kind']) != -1
						\ && has_key(TagList[Index], 'signature')
				" Handle functions (combine the signature and name)
				let s = substitute(TagList[Index]['cmd'], '^/\^\(.*\)\$/$', '\1', '')
				let ReturnType = substitute(s, '^\(.\{-}\)\s\+' . TagList[Index]['name'] . '.*', '\1', '')
				if ReturnType != s
					let s = ReturnType . " " . TagList[Index]['name'] . TagList[Index]['signature']
					if len(s) > 60
						let s = substitute(s, ',\s\+', ',\n\t\t', 'g')
					endif
				endif
			elseif TagList[Index]['kind'] == 't'
				if index(keys(s:CStyleTypeKindLookup), &ft) != -1
					" Typedefs - experimental
					let s = FindTypeTag(TagList[Index]['cmd'], TagList[Index]['filename'], MaxLines)
				endif
			elseif TagList[Index]['kind'] == 'e'
				let s = ""
				if has_key(TagList[Index], 'enum')
					let EnumName = 'typeref:enum:' . TagList[Index]['kind']['enum']
					" Ideally, we now find the typeref, but there's no built
					" in way to parse the tags file and it could be rather
					" slow reading it line-by-line.  Perhaps a separately built
					" database would be useful?
					"
					" If it works, find 'cmd' and 'filename' and pass to
					" let s = FindTypeTag(cmd, filename)
				endif
			endif

			if s == ""
				" Handle everything else
				let s = substitute(TagList[Index]['cmd'], '^/\^\(.*\)\$/$', '\1', '')
			endif

			" Strip leading and trailing spaces
			let s = substitute(s, '^\s*\(.\{-}\)\s*$/', '\1', '')

			let Index += 1

			if Index < IndexCount
				let s .= "\n======================\n"
			endif

			let result .= s
		endwhile
	endif
	return result
endfunction

set bexpr=GetTagSignature()
set ballooneval
