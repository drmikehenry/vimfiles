"=============================================================================
" FILE: autoload/incsearch.vim
" AUTHOR: haya14busa
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"
" vimlint:
" @vimlint(EVL103, 1, a:cmdline)
" @vimlint(EVL102, 1, v:errmsg)
" @vimlint(EVL102, 1, v:warningmsg)
" @vimlint(EVL102, 1, v:searchforward)
"=============================================================================
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

let s:TRUE = !0
let s:FALSE = 0
let s:DIRECTION = { 'forward': 1, 'backward': 0 } " see :h v:searchforward

" based on: https://github.com/deris/vim-magicalize/blob/433e38c1e83b1bdea4f83ab99dc19d070932380c/autoload/magicalize.vim#L52-L53
" improve to work with repetitive espaced slash like \V\V
" NOTE: \@1<= doesn't work to detect \v\v\v\v
let s:escaped_backslash     = '\m\%(^\|[^\\]\)\%(\\\\\)*'
let s:non_escaped_backslash = '\m\%(\%(^\|[^\\]\)\%(\\\\\)*\)\@<=\\'

" Option:
let g:incsearch#emacs_like_keymap      = get(g: , 'incsearch#emacs_like_keymap'      , s:FALSE)
let g:incsearch#highlight              = get(g: , 'incsearch#highlight'              , {})
let g:incsearch#separate_highlight     = get(g: , 'incsearch#separate_highlight'     , s:FALSE)
let g:incsearch#consistent_n_direction = get(g: , 'incsearch#consistent_n_direction' , s:FALSE)
let g:incsearch#vim_cmdline_keymap     = get(g: , 'incsearch#vim_cmdline_keymap'     , s:TRUE)
let g:incsearch#smart_backward_word    = get(g: , 'incsearch#smart_backward_word'    , s:TRUE)
let g:incsearch#no_inc_hlsearch        = get(g: , 'incsearch#no_inc_hlsearch'        , s:FALSE)
" This changes error and warning emulation way slightly
let g:incsearch#do_not_save_error_message_history =
\   get(g:, 'incsearch#do_not_save_error_message_history', s:FALSE)
let g:incsearch#auto_nohlsearch = get(g: , 'incsearch#auto_nohlsearch' , s:FALSE)
" assert g:incsearch#magic =~# \\[mMvV]
let g:incsearch#magic           = get(g: , 'incsearch#magic'           , '')

" Debug:
let g:incsearch#debug = get(g:, 'incsearch#debug', s:FALSE)

let s:V = vital#of(g:incsearch#debug ? 'vital' : 'incsearch')

" Utility:
let s:U = incsearch#util#import()

" Highlight:
let s:hi = g:incsearch#highlight#_hi

" CommandLine Interface: {{{
let s:cli = s:V.import('Over.Commandline').make_default("/")
let s:modules = s:V.import('Over.Commandline.Modules')

" Add modules
call s:cli.connect('BufferComplete')
call s:cli.connect('Cancel')
call s:cli.connect('CursorMove')
call s:cli.connect('Digraphs')
call s:cli.connect('Delete')
call s:cli.connect('DrawCommandline')
call s:cli.connect('ExceptionExit')
call s:cli.connect('LiteralInsert')
" call s:cli.connect('Exit')
" NOTE:
" <CR> in {rhs} wil be remapped even after exiting vital-over comman line
" interface, so do not use <Over>(exit)
" See also s:cli.keymapping()
let s:incsearch_exit = {
\   "name" : "IncsearchExit",
\   "exit_code" : 0
\}
function! s:incsearch_exit.on_char_pre(cmdline) abort
  if   a:cmdline.is_input("\<CR>")
  \ || a:cmdline.is_input("\<NL>")
    call a:cmdline.setchar("")
    call a:cmdline.exit(self.exit_code)
  endif
endfunction
call s:cli.connect(s:incsearch_exit)

" Lazy connect
let s:InsertRegister = s:modules.get('InsertRegister').make()

call s:cli.connect('Paste')
" XXX: better handling.
if expand("%:p") !=# expand("<sfile>:p")
  let s:Doautocmd = s:modules.get('Doautocmd')
  call s:cli.connect(s:Doautocmd.make('IncSearch'))
endif
call s:cli.connect(s:modules.get('ExceptionMessage').make('incsearch.vim: ', 'echom'))
call s:cli.connect(s:modules.get('History').make('/'))
call s:cli.connect(s:modules.get('NoInsert').make_special_chars())

" Dynamic Module Loading Management
let s:KeyMapping = s:modules.get('KeyMapping')
let s:emacs_like = s:KeyMapping.make_emacs()
let s:vim_cmap = s:KeyMapping.make_vim_cmdline_mapping()
let s:smartbackword = s:modules.get('IgnoreRegexpBackwardWord').make()
function! s:emacs_like._condition() abort
  return g:incsearch#emacs_like_keymap
endfunction
function! s:vim_cmap._condition() abort
  return g:incsearch#vim_cmdline_keymap
endfunction
function! s:smartbackword._condition() abort
  return g:incsearch#smart_backward_word
endfunction
let s:module_management =  {
\   'name' : 'IncsearchModuleManagement',
\   'modules' : [
\       s:emacs_like, s:vim_cmap, s:smartbackword
\   ]
\}
let s:backward_word = s:cli.backward_word
function! s:module_management.on_enter(cmdline) abort
  for module in self.modules
    if has_key(module, '_condition') && ! module._condition()
      call a:cmdline.disconnect(module.name)
      if module.name ==# 'IgnoreRegexpBackwardWord'
        function! a:cmdline.backward_word(...) abort
          return call(s:backward_word, a:000, self)
        endfunction
      endif
    elseif empty(a:cmdline.get_module(module.name))
      call a:cmdline.connect(module)
      if has_key(module, 'on_enter')
        call module.on_enter(a:cmdline)
      endif
    endif
  endfor
endfunction
function! s:module_management.priority(event) abort
  " NOTE: to overwrite backward_word() with default function
  return a:event ==# 'on_enter' ? 5 : 0
endfunction
call s:cli.connect(s:module_management)
unlet s:KeyMapping s:emacs_like s:vim_cmap s:smartbackword s:incsearch_exit

let s:pattern_saver =  {
\   'name' : 'PatternSaver',
\   'pattern' : '',
\   'hlsearch' : &hlsearch
\}
function! s:pattern_saver.on_enter(cmdline) abort
  if ! g:incsearch#no_inc_hlsearch
    let self.pattern = @/
    let self.hlsearch = &hlsearch
    if exists('v:hlsearch')
      let self.vhlsearch = v:hlsearch
    endif
    set hlsearch | nohlsearch
  endif
endfunction
function! s:pattern_saver.on_leave(cmdline) abort
  if ! g:incsearch#no_inc_hlsearch
    let is_cancel = a:cmdline.exit_code()
    if is_cancel
      let @/ = self.pattern
    endif
    let &hlsearch = self.hlsearch
    if exists('v:hlsearch')
      let v:hlsearch = self.vhlsearch
    endif
  endif
endfunction
call s:cli.connect(s:pattern_saver)

let s:default_keymappings = {
\   "\<Tab>"   : {
\       "key" : "<Over>(incsearch-next)",
\       "noremap" : 1,
\   },
\   "\<S-Tab>"   : {
\       "key" : "<Over>(incsearch-prev)",
\       "noremap" : 1,
\   },
\   "\<C-j>"   : {
\       "key" : "<Over>(incsearch-scroll-f)",
\       "noremap" : 1,
\   },
\   "\<C-k>"   : {
\       "key" : "<Over>(incsearch-scroll-b)",
\       "noremap" : 1,
\   },
\   "\<C-l>"   : {
\       "key" : "<Over>(buffer-complete)",
\       "noremap" : 1,
\   },
\   "\<CR>"   : {
\       "key": "\<CR>",
\       "noremap": 1
\   },
\ }

" https://github.com/haya14busa/incsearch.vim/issues/35
if has('mac')
  call extend(s:default_keymappings, {
  \   '"+gP'   : {
  \       'key': "\<C-r>+",
  \       'noremap': 1
  \   },
  \ })
endif

" FIXME: arguments?
function! s:cli.keymapping(...) abort
  return extend(copy(s:default_keymappings), g:incsearch_cli_key_mappings)
endfunction

let s:inc = {
\   "name" : "incsearch",
\}

" NOTE: for InsertRegister handling
function! s:inc.priority(event) abort
  return a:event is# 'on_char' ? 10 : 0
endfunction

function! s:inc.on_enter(cmdline) abort
  nohlsearch " disable previous highlight
  let s:w = winsaveview()
  let hgm = incsearch#highlight#hgm()
  let c = hgm.cursor
  call s:hi.add(c.group, c.group, '\%#', c.priority)
  call incsearch#highlight#update()

  " XXX: Manipulate search history for magic option
  " In the first place, I want to omit magic flag when histadd(), but
  " when returning cmd as expr mapping and feedkeys() cannot handle it, so
  " remove no user intended magic flag at on_enter.
  " Maybe I can also handle it with autocmd, should I use autocmd instead?
  let hist = histget('/', -1)
  if len(hist) > 2 && hist[:1] ==# s:magic()
    call histdel('/', -1)
    call histadd('/', hist[2:])
  endif
endfunction

function! s:inc.on_leave(cmdline) abort
  call s:hi.disable_all()
  call s:hi.delete_all()
  " redraw: hide pseud-cursor
  redraw " need to redraw for handling non-<expr> mappings
  if a:cmdline.getline() ==# ''
    echo ''
  else
    echo a:cmdline.get_prompt() . a:cmdline.getline()
  endif
  " NOTE:
  "   push rest of keymappings with feedkeys()
  "   FIXME: assume 'noremap' but it should take care wheter or not the
  "   mappings should be remapped or not
  if a:cmdline.input_key_stack_string() != ''
    call feedkeys(a:cmdline.input_key_stack_string(), 'n')
  endif
endfunction

" Avoid search-related error while incremental searching
function! s:on_searching(func, ...) abort
  try
    return call(a:func, a:000)
  catch /E16:/  " E16: Invalid range  (with /\_[a- )
  catch /E33:/  " E33: No previous substitute regular expression
  catch /E53:/  " E53: Unmatched %(
  catch /E54:/
  catch /E55:/
  catch /E62:/  " E62: Nested \= (with /a\=\=)
  catch /E63:/  " E63: invalid use of \_
  catch /E64:/  " E64: \@ follows nothing
  catch /E65:/  " E65: Illegal back reference
  catch /E66:/  " E66: \z( not allowed here
  catch /E67:/  " E67: \z1 et al. not allowed here
  catch /E68:/  " E68: Invalid character after \z (with /\za & re=1)
  catch /E69:/  " E69: Missing ] after \%[
  catch /E70:/  " E70: Empty \%[]
  catch /E71:/  " E71: Invalid character after \%
  catch /E554:/
  catch /E678:/ " E678: Invalid character after \%[dxouU]
  catch /E864:/ " E864: \%#= can only be followed by 0, 1, or 2. The
                "       automatic engine will be used
  catch /E865:/ " E865: (NFA) Regexp end encountered prematurely
  catch /E866:/ " E866: (NFA regexp) Misplaced @
  catch /E867:/ " E867: (NFA) Unknown operator
  catch /E869:/ " E869: (NFA) Unknown operator '\@m
  catch /E870:/ " E870: (NFA regexp) Error reading repetition limits
  catch /E871:/ " E871: (NFA regexp) Can't have a multi follow a multi !
  catch /E874:/ " E874: (NFA) Could not pop the stack ! (with \&)
  catch /E877:/ " E877: (NFA regexp) Invalid character class: 109
  catch /E888:/ " E888: (NFA regexp) cannot repeat (with /\ze*)
    call s:hi.disable_all()
  catch
    echohl ErrorMsg | echom v:throwpoint . " " . v:exception | echohl None
  endtry
endfunction

function! s:on_char_pre(cmdline) abort
  " NOTE:
  " `:call a:cmdline.setchar('')` as soon as possible!
  let [pattern, offset] = s:cli_parse_pattern(a:cmdline)

  " Interactive :h last-pattern if pattern is empty
  if ( a:cmdline.is_input("<Over>(incsearch-next)")
  \ || a:cmdline.is_input("<Over>(incsearch-prev)")
  \ ) && empty(pattern)
    call a:cmdline.setchar('')
    " Use history instead of @/ to work with magic option and converter
    call a:cmdline.setline(histget('/', -1) . (empty(offset) ? '' : a:cmdline._base_key) . offset)
    " Just insert last-pattern and do not count up, but the incsearch-prev
    " should move the cursor to reversed directly, so do not return if the
    " command is prev
    if a:cmdline.is_input("<Over>(incsearch-next)") | return | endif
  endif

  if a:cmdline.is_input("<Over>(incsearch-next)")
    call a:cmdline.setchar('')
    if a:cmdline.flag ==# 'n' " exit stay mode
      let a:cmdline.flag = ''
    else
      let a:cmdline._vcount1 += 1
    endif
  elseif a:cmdline.is_input("<Over>(incsearch-prev)")
    call a:cmdline.setchar('')
    if a:cmdline.flag ==# 'n' " exit stay mode
      let a:cmdline.flag = ''
    endif
    let a:cmdline._vcount1 -= 1
    if a:cmdline._vcount1 < 1
      let a:cmdline._vcount1 += s:U.count_pattern(pattern)
    endif
  elseif (a:cmdline.is_input("<Over>(incsearch-scroll-f)")
  \ &&   (a:cmdline.flag ==# '' || a:cmdline.flag ==# 'n'))
  \ ||   (a:cmdline.is_input("<Over>(incsearch-scroll-b)") && a:cmdline.flag ==# 'b')
    call a:cmdline.setchar('')
    if a:cmdline.flag ==# 'n' | let a:cmdline.flag = '' | endif
    let pos_expr = a:cmdline.is_input("<Over>(incsearch-scroll-f)") ? 'w$' : 'w0'
    let to_col = a:cmdline.is_input("<Over>(incsearch-scroll-f)")
    \          ? s:U.get_max_col(pos_expr) : 1
    let [from, to] = [getpos('.')[1:2], [line(pos_expr), to_col]]
    let cnt = s:U.count_pattern(pattern, from, to)
    let a:cmdline._vcount1 += cnt
  elseif (a:cmdline.is_input("<Over>(incsearch-scroll-b)")
  \ &&   (a:cmdline.flag ==# '' || a:cmdline.flag ==# 'n'))
  \ ||   (a:cmdline.is_input("<Over>(incsearch-scroll-f)") && a:cmdline.flag ==# 'b')
    call a:cmdline.setchar('')
    if a:cmdline.flag ==# 'n'
      let a:cmdline.flag = ''
      let a:cmdline._vcount1 -= 1
    endif
    let pos_expr = a:cmdline.is_input("<Over>(incsearch-scroll-f)") ? 'w$' : 'w0'
    let to_col = a:cmdline.is_input("<Over>(incsearch-scroll-f)")
    \          ? s:U.get_max_col(pos_expr) : 1
    let [from, to] = [getpos('.')[1:2], [line(pos_expr), to_col]]
    let cnt = s:U.count_pattern(pattern, from, to)
    let a:cmdline._vcount1 -= cnt
    if a:cmdline._vcount1 < 1
      let a:cmdline._vcount1 += s:U.count_pattern(pattern)
    endif
  endif

  " Handle nowrapscan:
  "   if you `:set nowrapscan`, you can't move to the reversed direction
  if &wrapscan == s:FALSE && (
  \    a:cmdline.is_input("<Over>(incsearch-next)")
  \ || a:cmdline.is_input("<Over>(incsearch-prev)")
  \ || a:cmdline.is_input("<Over>(incsearch-scroll-f)")
  \ || a:cmdline.is_input("<Over>(incsearch-scroll-b)")
  \ )
    call a:cmdline.setchar('')
    let [from, to] = [[s:w.lnum, s:w.col],
    \       a:cmdline.flag !=# 'b'
    \       ? [line('$'), s:U.get_max_col('$')]
    \       : [1, 1]
    \   ]
    let max_cnt = s:U.count_pattern(pattern, from, to)
    let a:cmdline._vcount1 = min([max_cnt, a:cmdline._vcount1])
  endif
endfunction

function! s:on_char(cmdline) abort
  let [raw_pattern, offset] = s:cli_parse_pattern(a:cmdline)

  if raw_pattern ==# ''
    call s:hi.disable_all()
    nohlsearch
    return
  endif

  " For InsertRegister
  if a:cmdline.get_tap_key() ==# "\<C-r>"
    let p = a:cmdline.getpos()
    " Remove `"`
    let raw_pattern = raw_pattern[:p-1] . raw_pattern[p+1:]
    let w = winsaveview()
    call cursor(line('.'), col('.') + len(a:cmdline.backward_word()))
    call s:InsertRegister.reset()
    call winrestview(w)
  endif

  let pattern = s:convert(raw_pattern)

  " Improved Incremental cursor move!
  call s:move_cursor(a:cmdline, pattern, offset)

  " Improved Incremental highlighing!
  " case: because matchadd() doesn't handle 'ignorecase' nor 'smartcase'
  let case = incsearch#detect_case(raw_pattern)
  let should_separate = g:incsearch#separate_highlight && a:cmdline.flag !=# 'n'
  let d = (a:cmdline.flag !=# 'b' ? s:DIRECTION.forward : s:DIRECTION.backward)
  call incsearch#highlight#incremental_highlight(
  \   pattern . case, should_separate, d, [s:w.lnum, s:w.col])

  " functional `normal! zz` after scroll for <expr> mappings
  if ( a:cmdline.is_input("<Over>(incsearch-scroll-f)")
  \ || a:cmdline.is_input("<Over>(incsearch-scroll-b)"))
    call winrestview({'topline': max([1, line('.') - winheight(0) / 2])})
  endif
endfunction

" Caveat: It handle :h last-pattern, so be careful if you want to pass empty
" string as a pattern
function! s:move_cursor(cli, pattern, ...) abort
  let offset = get(a:, 1, '')
  if a:cli.flag ==# 'n' " skip if stay mode
    return
  endif
  call winrestview(s:w)
  " pseud-move cursor position: this is restored afterward if called by
  " <expr> mappings
  if a:cli._is_expr
    for _ in range(a:cli._vcount1)
      " NOTE: This cannot handle {offset} for cursor position
      call search(a:pattern, a:cli.flag)
    endfor
  else
    " More precise cursor position while searching
    " Caveat:
    "   This block contains `normal`, please make sure <expr> mappings
    "   doesn't reach this block
    let is_visual_mode = s:U.is_visual(mode(1))
    let cmd = s:with_ignore_foldopen(
    \   function('s:build_search_cmd'),
    \   a:cli, 'n', s:combine_pattern(a:cli, a:pattern, offset), a:cli._base_key)
    " NOTE:
    " :silent!
    "   Shut up errors! because this is just for the cursor emulation
    "   while searching
    silent! call s:execute_search(cmd)
    if is_visual_mode
      let w = winsaveview()
      normal! gv
      call winrestview(w)
      call incsearch#highlight#emulate_visual_highlight()
    endif
  endif
endfunction

function! s:inc.on_char_pre(cmdline) abort
  call s:on_searching(function('s:on_char_pre'), a:cmdline)
endfunction

function! s:inc.on_char(cmdline) abort
  call s:on_searching(function('s:on_char'), a:cmdline)
endfunction

call s:cli.connect(s:inc)

"" partial deepcopy() for cli.connect(module) instead of copy()
function! s:copy_cli(cli) abort
  let cli = copy(a:cli)
  let cli.variables = deepcopy(a:cli.variables)
  return cli
endfunction

function! s:make_cli(config) abort
  let cli = s:copy_cli(s:cli)
  let cli._base_key = a:config.command
  let cli._vcount1 = a:config.count1
  let cli._is_expr = a:config.is_expr
  let cli._mode = a:config.mode
  let cli._pattern = a:config.pattern
  for module in a:config.modules
    call cli.connect(module)
  endfor
  call cli.connect(s:InsertRegister)
  return cli
endfunction

"}}}

" Main: {{{

" @return vital-over command-line interface object. it's experimental!!!
function! incsearch#cli() abort
  try
    " It returns current cli object
    return s:Doautocmd.get_cmdline()
  catch /vital-over(_incsearch) Exception/
    " If there are no current cli object, return default one
    return s:cli
  endtry
endfunction

"" NOTE: this global variable is only for handling config from go_wrap func
" It avoids to make config string temporarily
let g:incsearch#_go_config = {}

"" This is main API assuming used by <expr> mappings
" ARGS:
"   @config See autoload/incsearch/config.vim
" RETURN:
"   Return primitive search commands (like `3/pattern<CR>`) if config.is_expr
"   is TRUE, return excute command to call incsearch.vim's inner API.
"   To handle dot repeat, make sure that config.is_expr is true. If you do not
"   specify config.is_expr, it automatically set config.is_expr TRUE for
"   operator-pending mode
" USAGE:
"   :noremap <silent><expr> <Plug>(incsearch-forward)  incsearch#go({'command': '/'})
"   " FIXME?: Calling this with feedkeys() is ugly... Reason: incsearch#go()
"   is optimize the situation which calling from <expr> mappings, and do not
"   take care from calling directly or some defined command.
"   :call feedkeys(incsearch#go(), 'n')
" @api
function! incsearch#go(...) abort
  let config = incsearch#config#make(get(a:, 1, {}))
  " FIXME?: this condition should not be config.is_expr?
  if config.is_expr
    return incsearch#_go(config)
  else
    let g:incsearch#_go_config = config
    let esc = s:U.is_visual(g:incsearch#_go_config.mode) ? "\<ESC>" : ''
    return printf("%s:\<C-u>call incsearch#_go(g:incsearch#_go_config)\<CR>", esc)
  endif
endfunction

"" Debuggin incsearch.vim interface for calling from function call
" USAGE:
"   :call incsearch#call({'pattern': @/})
" @api for debugging
function! incsearch#call(...) abort
  return incsearch#_go(incsearch#config#make(get(a:, 1, {})))
endfunction

" IMPORTANT NOTE:
"   Calling `incsearch#go()` and executing command which returned from
"   `incsearch#go()` have to result in the same cursor move.
" @return command: String to search
function! incsearch#_go(config) abort
  let Search = function(a:config.is_stay ? 'incsearch#stay' : 'incsearch#search')
  if s:U.is_visual(a:config.mode) && !a:config.is_expr
    normal! gv
  endif
  let cli = s:make_cli(a:config)
  let cmd = Search(cli)
  if !a:config.is_expr
    let should_set_jumplist = (cli.flag !=# 'n')
    call s:set_search_related_stuff(cli, cmd, should_set_jumplist)
    if a:config.mode is# 'no'
      call s:set_vimrepeat(cmd)
    endif
  endif
  return cmd
endfunction

"" To handle recursive mapping, map command to <Plug>(_incsearch-dotrepeat)
" temporarily
" https://github.com/tpope/vim-repeat
" https://github.com/kana/vim-repeat
function! s:set_vimrepeat(cmd) abort
  execute 'noremap' '<Plug>(_incsearch-dotrepeat)' a:cmd
  silent! call repeat#set("\<Plug>(_incsearch-dotrepeat)")
endfunction

" similar to incsearch#forward() but do not move the cursor unless explicitly
" move the cursor while searching
" @expr but sometimes called by non-<expr>
" @return: command which is excutable with expr-mappings or `exec 'normal!'`
function! incsearch#stay(cli) abort
  let input = s:get_input(a:cli, '')

  let [raw_pattern, offset] = s:cli_parse_pattern(a:cli)
  let pattern = s:convert(raw_pattern)

  " execute histadd manually
  if a:cli.flag ==# 'n' && input !=# '' && (a:cli._is_expr || empty(offset))
    call histadd('/', input)
    let @/ = pattern
  endif

  if a:cli.flag ==# 'n' " stay
    " NOTE: do not move cursor but need to handle {offset} for n & N ...! {{{
    " FIXME: cannot set {offset} if in operator-pending mode because this
    " have to use feedkeys()
    let is_cancel = a:cli.exit_code()
    if is_cancel
      call s:cleanup_cmdline()
    elseif !empty(offset) && mode(1) !=# 'no'
      let cmd = s:with_ignore_foldopen(
      \   function('s:generate_command'), a:cli, input, '/')
      call feedkeys(cmd, 'n')
      " XXX: string()... use <SNR> or <SID>? But it doesn't work well.
      call s:U.silent_feedkeys(":\<C-u>call winrestview(". string(s:w) . ")\<CR>", 'winrestview', 'n')
      call incsearch#auto_nohlsearch(2)
    else
      call incsearch#auto_nohlsearch(0)
    endif
    " }}}
    return s:U.is_visual(a:cli._mode) ? "\<ESC>gv" : "\<ESC>" " just exit
  else " exit stay mode while searching
    call incsearch#auto_nohlsearch(1)
    return s:generate_command(a:cli, input, '/') " assume '/'
  endif
endfunction

function! incsearch#search(cli) abort
  let input = s:get_input(a:cli, a:cli._base_key)
  let [pattern, offset] = incsearch#parse_pattern(input, a:cli._base_key)
  call incsearch#auto_nohlsearch(1) " NOTE: `.` repeat doesn't handle this
  return s:generate_command(
  \   a:cli, s:combine_pattern(a:cli, s:convert(pattern), offset), a:cli._base_key)
endfunction

function! s:get_input(cli, search_key) abort
  " if search_key is empty, it means `stay` & do not move cursor
  let prompt = a:search_key ==# '' ? '/' : a:search_key
  call a:cli.set_prompt(prompt)
  let a:cli.flag = a:search_key ==# '/' ? ''
  \              : a:search_key ==# '?' ? 'b'
  \              : a:search_key ==# ''  ? 'n'
  \              : ''

  " Handle visual mode highlight
  if s:U.is_visual(a:cli._mode)
    let visual_hl = incsearch#highlight#get_visual_hlobj()
    try
      call incsearch#highlight#turn_off(visual_hl)
      call incsearch#highlight#emulate_visual_highlight(a:cli._mode, visual_hl)
      let input = a:cli.get(a:cli._pattern)
    finally
      call incsearch#highlight#turn_on(visual_hl)
    endtry
  else
    let input = a:cli.get(a:cli._pattern)
  endif
  return input
endfunction

function! s:generate_command(cli, pattern, search_key) abort
  if (a:cli.exit_code() == 0)
    let v = winsaveview()
    try
      call winrestview(s:w)
      call a:cli.callevent('on_execute_pre') " XXX: side-effect!
    finally
      call winrestview(v)
    endtry
    call a:cli.callevent('on_execute') " XXX: side-effect!
    return s:build_search_cmd(a:cli, a:cli._mode, a:pattern, a:search_key)
  else " Cancel
    return s:U.is_visual(a:cli._mode) ? '\<ESC>gv' : "\<ESC>"
  endif
endfunction

function! s:build_search_cmd(cli, mode, pattern, search_key) abort
  let op = (a:mode == 'no')      ? v:operator
  \      : s:U.is_visual(a:mode) ? 'gv'
  \      : ''
  let zv = (&foldopen =~# '\vsearch|all' && a:mode !=# 'no' ? 'zv' : '')
  " NOTE:
  "   Should I consider o_v, o_V, and o_CTRL-V cases and do not
  "   <Esc>? <Esc> exists for flexible v:count with using s:cli._vcount1,
  "   but, if you do not move the cursor while incremental searching,
  "   there are no need to use <Esc>.
  return printf("\<Esc>\"%s%s%s%s%s\<CR>%s",
  \   v:register, op, a:cli._vcount1, a:search_key, a:pattern, zv)
endfunction

" Assume the cursor move is already done.
" This function handle search related stuff which doesn't be set by :execute
" in function like @/, hisory, jumplist, offset, error & warning emulation.
function! s:set_search_related_stuff(cli, cmd, ...) abort
  " For stay motion
  let should_set_jumplist = get(a:, 1, s:TRUE)
  let is_cancel = a:cli.exit_code()
  if is_cancel
    " Restore cursor position and return
    " NOTE: Should I request on_cancel event to vital-over and use it?
    call winrestview(s:w)
    call s:cleanup_cmdline()
    return
  endif
  let [raw_pattern, offset] = s:cli_parse_pattern(a:cli)
  let should_execute = !empty(offset) || empty(raw_pattern)
  if should_execute
    " Execute with feedkeys() to work with
    "  1. :h {offset} for `n` and `N`
    "  2. empty input (:h last-pattern)
    "  NOTE: Don't use feedkeys() as much as possible to avoid flickering
    call winrestview(s:w)
    call feedkeys(a:cmd, 'n')
    if g:incsearch#consistent_n_direction
      call s:_silent_searchforward(s:DIRECTION.forward)
    endif
  else
    " Add history if necessary
    " Do not save converted pattern to history
    let pattern = s:convert(raw_pattern)
    let input = s:combine_pattern(a:cli, raw_pattern, offset)
    call histadd(a:cli._base_key, input)
    let @/ = pattern

    " Emulate errors, and handling `n` and `N` preparation {{{
    let target_view = winsaveview()
    call winrestview(s:w) " Get back start position temporarily for emulation
    " Set jump list
    if should_set_jumplist
      normal! m`
    endif
    let d = (a:cli._base_key == '/' ? s:DIRECTION.forward : s:DIRECTION.backward)
    call s:emulate_search_error(d)
    call winrestview(target_view)
    "}}}

    " Emulate warning {{{
    " NOTE:
    " - It should use :h echomsg considering emulation of default
    "   warning messages remain in the :h message-history, but it'll mess
    "   up the message-history unnecessary, so it use :h echo
    " - Echo warning message after winrestview() to avoid flickering
    " - See :h shortmess
    if &shortmess !~# 's' && g:incsearch#do_not_save_error_message_history
      let from = [s:w.lnum, s:w.col]
      let to = [target_view.lnum, target_view.col]
      let old_warningmsg = v:warningmsg
      let v:warningmsg =
      \   ( d == s:DIRECTION.forward && !s:U.is_pos_less_equal(from, to)
      \   ? 'search hit BOTTOM, continuing at TOP'
      \   : d == s:DIRECTION.backward && s:U.is_pos_less_equal(from, to)
      \   ? 'search hit TOP, continuing at BOTTOM'
      \   : '' )
      if v:warningmsg !=# ''
        call s:Warning(v:warningmsg)
      else
        let v:warningmsg = old_warningmsg
      endif
    endif
    "}}}

    call s:silent_after_search()

    " Open fold
    if &foldopen =~# '\vsearch|all'
      normal! zv
    endif
  endif
endfunction

" Make sure move cursor by search related action __after__ calling this
" function because the first move event just set nested autocmd which
" does :nohlsearch
" @expr
function! incsearch#auto_nohlsearch(nest) abort
  " NOTE: see this value inside this function in order to toggle auto
  " :nohlsearch feature easily with g:incsearch#auto_nohlsearch option
  if !g:incsearch#auto_nohlsearch | return '' | endif
  let cmd = s:U.is_visual(mode(1))
  \   ? 'call feedkeys(":\<C-u>nohlsearch\<CR>" . (mode(1) =~# "[vV\<C-v>]" ? "gv" : ""), "n")
  \     '
  \   : 'call s:U.silent_feedkeys(":\<C-u>nohlsearch\<CR>" . (mode(1) =~# "[vV\<C-v>]" ? "gv" : ""), "nohlsearch", "n")
  \     '
  " NOTE: :h autocmd-searchpat
  "   You cannot implement this feature without feedkeys() bacause of
  "   :h autocmd-searchpat
  augroup incsearch-auto-nohlsearch
    autocmd!
    " NOTE: this break . unit with c{text-object}
    " side-effect: InsertLeave & InsertEnter are called with i_CTRL-\_CTRL-O
    " autocmd InsertEnter * call feedkeys("\<C-\>\<C-o>:nohlsearch\<CR>", "n")
    " \   | autocmd! incsearch-auto-nohlsearch
    execute join([
    \   'autocmd CursorMoved *'
    \ , repeat('autocmd incsearch-auto-nohlsearch CursorMoved * ', a:nest)
    \ , cmd
    \ , '| autocmd! incsearch-auto-nohlsearch'
    \ ], ' ')
  augroup END
  return ''
endfunction

"}}}

" Helper: {{{
" @return [pattern, offset]
function! incsearch#parse_pattern(expr, search_key) abort
  " search_key : '/' or '?'
  " expr       : {pattern\/pattern}/{offset}
  " expr       : {pattern}/;/{newpattern} :h //;
  " return     : [{pattern\/pattern}, {offset}]
  let very_magic = '\v'
  let pattern  = '(%(\\.|.){-})'
  let slash = '(\' . a:search_key . '&[^\\"|[:alnum:][:blank:]])'
  let offset = '(.*)'

  let parse_pattern = very_magic . pattern . '%(' . slash . offset . ')?$'
  let result = matchlist(a:expr, parse_pattern)[1:3]
  if type(result) == type(0) || empty(result)
    return []
  endif
  unlet result[1]
  return result
endfunction

" CommandLine Interface parse pattern wrapper
function! s:cli_parse_pattern(cli) abort
  if v:version == 704 && !has('patch421')
    " Ignore \ze* which clash vim 7.4 without 421 patch
    " Assume `\m`
    let [p, o] = incsearch#parse_pattern(a:cli.getline(), a:cli._base_key)
    let p = (p =~# s:non_escaped_backslash . 'z[se]\%(\*\|\\+\)' ? '' : p)
    return [p, o]
  else
    return incsearch#parse_pattern(a:cli.getline(), a:cli._base_key)
  endif
endfunction

function! s:combine_pattern(cli, pattern, offset) abort
  return empty(a:offset) ? a:pattern : a:pattern . a:cli._base_key . a:offset
endfunction

" convert implementation. assume pattern is not empty
function! s:_convert(pattern) abort
  return s:magic() . a:pattern
endfunction

function! s:convert(pattern) abort
  " TODO: convert pattern if required in addition to appending magic flag
  return a:pattern is# '' ? a:pattern : s:_convert(a:pattern)
endfunction

function! incsearch#detect_case(pattern) abort
  " Ignore \%C, \%U, \%V for smartcase detection
  let p = substitute(a:pattern, s:non_escaped_backslash . '%[CUV]', '', 'g')
  " Explicit \c has highest priority
  if p =~# s:non_escaped_backslash . 'c'
    return '\c'
  endif
  if p =~# s:non_escaped_backslash . 'C' || &ignorecase == s:FALSE
    return '\C' " noignorecase or explicit \C
  endif
  if &smartcase == s:FALSE
    return '\c' " ignorecase & nosmartcase
  endif
  " Find uppercase letter which isn't escaped
  if p =~# s:escaped_backslash . '[A-Z]'
    return '\C' " smartcase with [A-Z]
  else
    return '\c' " smartcase without [A-Z]
  endif
endfunction

function! s:silent_after_search(...) abort " arg: mode(1)
  " :h function-search-undo
  if get(a:, 1, mode(1)) !=# 'no' " guard for operator-mapping
    call s:_silent_hlsearch()
    call s:_silent_searchforward()
  endif
endfunction

function! s:_silent_hlsearch() abort
  " Handle :set hlsearch
  call s:U.silent_feedkeys(":let &hlsearch=&hlsearch\<CR>", 'hlsearch', 'n')
endfunction

function! s:_silent_searchforward(...) abort
  " NOTE: You have to 'exec normal! `/` or `?`' before calling this
  " function to update v:searchforward
  let direction = get(a:, 1,
  \   (g:incsearch#consistent_n_direction == s:TRUE)
  \   ? s:DIRECTION.forward : v:searchforward)
  call s:U.silent_feedkeys(
  \   ":let v:searchforward=" . direction . "\<CR>",
  \   'searchforward', 'n')
endfunction

function! s:emulate_search_error(direction) abort
  let keyseq = (a:direction == s:DIRECTION.forward ? '/' : '?')
  let old_errmsg = v:errmsg
  let v:errmsg = ''
  " NOTE:
  "   - XXX: Handle `n` and `N` preparation with s:silent_after_search()
  "   - silent!: Do not show error and warning message, because it also
  "     echo v:throwpoint for error and save messages in message-history
  "   - Unlike v:errmsg, v:warningmsg doesn't set if it use :silent!
  let w = winsaveview()
  " Get first error
  silent! call s:execute_search(keyseq . "\<CR>")
  call winrestview(w)
  if g:incsearch#do_not_save_error_message_history
    if v:errmsg != ''
      call s:Error(v:errmsg)
    else
      let v:errmsg = old_errmsg
    endif
  else
    " NOTE: show more than two errors e.g. `/\za`
    let last_error = v:errmsg
    try
      " Do not use silent! to show warning
      call s:execute_search(keyseq . "\<CR>")
    catch /^Vim\%((\a\+)\)\=:E/
      let first_error = matchlist(v:exception, '\v^Vim%(\(\a+\))=:(E.*)$')[1]
      call s:Error(first_error, 'echom')
      if last_error != '' && last_error !=# first_error
        call s:Error(last_error, 'echom')
      endif
    finally
      call winrestview(w)
    endtry
    if v:errmsg == ''
      let v:errmsg = old_errmsg
    endif
  endif
endfunction

function! s:cleanup_cmdline() abort
  redraw | echo ''
endfunction

" Should I use :h echoerr ? But it save the messages in message-history
function! s:Error(msg, ...) abort
  return call(function('s:_echohl'), [a:msg, 'ErrorMsg'] + a:000)
endfunction

function! s:Warning(msg, ...) abort
  return call(function('s:_echohl'), [a:msg, 'WarningMsg'] + a:000)
endfunction

function! s:_echohl(msg, hlgroup, ...) abort
  let echocmd = get(a:, 1, 'echo')
  redraw | echo ''
  exec 'echohl' a:hlgroup
  exec echocmd string(a:msg)
  echohl None
endfunction

" Not to generate command with zv
function! s:with_ignore_foldopen(F, ...) abort
  let foldopen_save = &foldopen
  let &foldopen=''
  try
    return call(a:F, a:000)
  finally
    let &foldopen = foldopen_save
  endtry
endfunction

" Try to avoid side-effect as much as possible except cursor movement
let s:has_keeppattern = v:version > 704 || v:version == 704 && has('patch083')
let s:keeppattern = (s:has_keeppattern ? 'keeppattern' : '')
function! s:_execute_search(cmd) abort
  " :nohlsearch
  "   Please do not highlight at the first place if you set back
  "   info! I'll handle it myself :h function-search-undo
  execute s:keeppattern 'keepjumps' 'normal!' a:cmd | nohlsearch
endfunction
if s:has_keeppattern
  function! s:execute_search(...) abort
    return call(function('s:_execute_search'), a:000)
  endfunction
else
  function! s:execute_search(...) abort
    " keeppattern emulation
    let p = @/
    let r = call(function('s:_execute_search'), a:000)
    " NOTE: `let @/ = p` reset v:searchforward
    let d = v:searchforward
    let @/ = p
    let v:searchforward = d
    return r
  endfunction
endif

function! s:magic() abort
  let m = g:incsearch#magic
  return (len(m) == 2 && m =~# '\\[mMvV]' ? m : '')
endfunction

"}}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=2 shiftwidth=2
" vim: foldmethod=marker
" }}}
