" Tests for vimrc.

let s:tc = unittest#testcase#new("ListManip")

function! s:tc.test_Flatten()
    call self.assert_equal([],              Flatten([]))
    call self.assert_equal([],              Flatten([[]]))
    call self.assert_equal([],              Flatten([[[]]]))
    call self.assert_equal([1],             Flatten([1]))
    call self.assert_equal([1],             Flatten([[1]]))
    call self.assert_equal([1, 2, 3, 4],    Flatten([1, [2], [[3], 4]]))
endfunction

let s:tc = unittest#testcase#new("PathManip")

function! s:tc.test_PathEscape()
    call self.assert_equal('',              PathEscape(''))
    call self.assert_equal('p',             PathEscape('p'))
    call self.assert_equal('\\p',           PathEscape('\p'))
    call self.assert_equal('\\\\p',         PathEscape('\\p'))
    call self.assert_equal('\\\,p',         PathEscape('\,p'))
endfunction

function! s:tc.test_PathUnescape()
    call self.assert_equal('',              PathUnescape(''))
    call self.assert_equal('p',             PathUnescape('p'))
    call self.assert_equal('\p',            PathUnescape('\p'))
    call self.assert_equal('\p',            PathUnescape('\\p'))
    call self.assert_equal(',p',            PathUnescape('\,p'))
    call self.assert_equal('\,p',           PathUnescape('\\,p'))
    call self.assert_equal('\,p',           PathUnescape('\\\,p'))
    call self.assert_equal('\,p',           PathUnescape('\\\,p'))
endfunction

function! s:tc.test_PathSplit()
    call self.assert_equal([],                  PathSplit(''))
    call self.assert_equal(['p'],               PathSplit('p'))
    call self.assert_equal(['p', 'q'],          PathSplit('p,q'))
    call self.assert_equal(['p,q'],             PathSplit('p\,q'))
    call self.assert_equal(['p\q'],             PathSplit('p\\q'))
    call self.assert_equal(['p\', 'q'],         PathSplit('p\\,q'))
    call self.assert_equal(['p\,q'],            PathSplit('p\\\,q'))
    call self.assert_equal(['p', 'q', 'r'],     PathSplit('p,q,r'))
endfunction

function! s:tc.test_PathJoin()
    call self.assert_equal('',                  PathJoin(''))
    call self.assert_equal('',                  PathJoin([]))
    call self.assert_equal('',                  PathJoin(['']))
    call self.assert_equal(',',                 PathJoin(['', '']))
    call self.assert_equal(',',                 PathJoin(['', ''], []))
    call self.assert_equal('p,q,r',             PathJoin('p', 'q', 'r'))
    call self.assert_equal('p,\,,r',            PathJoin('p', ',', 'r'))
    call self.assert_equal('\\,\\\,',           PathJoin('\', '\,'))
endfunction
