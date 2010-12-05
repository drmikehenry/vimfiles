" Tag Signature Balloon
"   Author: A. S. Budden
"## Date::   4th September 2009      ##
"## RevTag:: r319                    ##

if &cp || exists("g:loaded_tag_signature") || ! has('balloon_eval')
	finish
endif
let g:loaded_tag_signature = 1

if !exists('g:TagSignatureAllowFileLoading')
	let g:TagSignatureAllowFileLoading = 1
endif

function! FindTypeTag(cmd, filename)
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
						if (index - StartIndex) > 20
							for i in range(StartIndex+1, StartIndex+5)
								let s = s . "\n" . FileContents[i]
							endfor
							let s = s . "\n\n\t\t... [skipped] ...\n\n"
							for i in range(index-6, index)
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
	let s = ""

	if len(TagList) > 0
		if TagList[0]['cmd'] =~ '^\d\+$'
			" Handle links to specific lines in a source file
			let LineNum = str2nr(TagList[0]['cmd'])
			let FileName = TagList[0]['filename']
			if bufexists(FileName) && (len(getbufline(FileName, LineNum)) > 0)
				" An open source file
				let s = getbufline(FileName, LineNum)[0]
			elseif (g:TagSignatureAllowFileLoading == 1) && filereadable(FileName)
				" A non-open source file
				let s = readfile(FileName, '', LineNum)[LineNum-1]
			endif
		elseif index(keys(s:CStyleFunctionKindLookup), &ft) != -1
					\ && index(s:CStyleFunctionKindLookup[&ft], TagList[0]['kind']) != -1
					\ && has_key(TagList[0], 'signature')
			" Handle functions (combine the signature and name)
			let s = substitute(TagList[0]['cmd'], '^/\^\(.*\)\$/$', '\1', '')
			let ReturnType = substitute(s, '^\(.\{-}\)\s\+' . TagList[0]['name'] . '.*', '\1', '')
			if ReturnType != s
				let s = ReturnType . " " . TagList[0]['name'] . TagList[0]['signature']
				if len(s) > 60
					let s = substitute(s, ',\s\+', ',\n\t\t', 'g')
				endif
			endif
		elseif TagList[0]['kind'] == 't'
			if index(keys(s:CStyleTypeKindLookup), &ft) != -1
				" Typedefs - experimental
				let s = FindTypeTag(TagList[0]['cmd'], TagList[0]['filename'])
			endif
		elseif TagList[0]['kind'] == 'e'
			let s = ""
			if has_key(TagList[0], 'enum')
				let EnumName = 'typeref:enum:' . TagList[0]['kind']['enum']
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
			let s = substitute(TagList[0]['cmd'], '^/\^\(.*\)\$/$', '\1', '')
		endif

		" Strip leading and trailing spaces
		let s = substitute(s, '^\s*\(.\{-}\)\s*$/', '\1', '')
	endif
	return s
endfunction

set bexpr=GetTagSignature()
set ballooneval
