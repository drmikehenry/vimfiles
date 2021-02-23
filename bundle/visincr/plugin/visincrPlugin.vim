" visincrPlugin.vim: Visual-block incremented lists
"  Author:      Charles E. Campbell
"  Date:        Jan 06, 2016
"  Public Interface Only
"
"  (James 2:19,20 WEB) You believe that God is one. You do well!
"                      The demons also believe, and shudder.
"                      But do you want to know, vain man, that
"                      faith apart from works is dead?

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_visincrPlugin")
  finish
endif
let g:loaded_visincrPlugin = "v21h"
let s:keepcpo              = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Methods: {{{1
let s:I      = 0 
let s:II     = 1 
let s:IMOD   = 2 
let s:IREP   = 3 
let s:IMDY   = 4 
let s:IYMD   = 5 
let s:IDMY   = 6 
let s:ID     = 7 
let s:IM     = 8 
let s:IA     = 9 
let s:IX     = 10
let s:IIX    = 11
let s:IB     = 12
let s:IIB    = 13
let s:IO     = 14
let s:IIO    = 15
let s:IR     = 16
let s:IIR    = 17
let s:IPOW   = 18
let s:IIPOW  = 19
let s:RI     = 20
let s:RII    = 21
let s:RIMOD  = 22
let s:RIREP  = 23
let s:RIMDY  = 24
let s:RIYMD  = 25
let s:RIDMY  = 26
let s:RID    = 27
let s:RIM    = 28
let s:RIA    = 29
let s:RIX    = 30
let s:RIIX   = 31
let s:RIB    = 32
let s:RIIB   = 33
let s:RIO    = 34
let s:RIIO   = 35
let s:RIR    = 36
let s:RIIR   = 37
let s:RIPOW  = 38
let s:RIIPOW = 39

" ------------------------------------------------------------------------------
" Public Interface: {{{1
if !exists("g:visincr_longcmd")
  com! -range -complete=expression -nargs=* I     call visincr#VisBlockIncr(s:I     , <f-args>)
  com! -range -complete=expression -nargs=* II    call visincr#VisBlockIncr(s:II    , <f-args>)
  com! -range -complete=expression -nargs=* IMOD  call visincr#VisBlockIncr(s:IMOD  , <f-args>)
  com! -range -complete=expression -nargs=* IREP  call visincr#VisBlockIncr(s:IREP  , <f-args>)
  com! -range -complete=expression -nargs=* IMDY  call visincr#VisBlockIncr(s:IMDY  , <f-args>)
  com! -range -complete=expression -nargs=* IYMD  call visincr#VisBlockIncr(s:IYMD  , <f-args>)
  com! -range -complete=expression -nargs=* IDMY  call visincr#VisBlockIncr(s:IDMY  , <f-args>)
  com! -range -complete=expression -nargs=? ID    call visincr#VisBlockIncr(s:ID    , <f-args>)
  com! -range -complete=expression -nargs=? IM    call visincr#VisBlockIncr(s:IM    , <f-args>)
  com! -range -complete=expression -nargs=? IA    call visincr#VisBlockIncr(s:IA    , <f-args>)
  com! -range -complete=expression -nargs=? IX    call visincr#VisBlockIncr(s:IX    , <f-args>)
  com! -range -complete=expression -nargs=? IIX   call visincr#VisBlockIncr(s:IIX   , <f-args>)
  com! -range -complete=expression -nargs=* IB    call visincr#VisBlockIncr(s:IB    , <f-args>)
  com! -range -complete=expression -nargs=* IIB   call visincr#VisBlockIncr(s:IIB   , <f-args>)
  com! -range -complete=expression -nargs=* IO    call visincr#VisBlockIncr(s:IO    , <f-args>)
  com! -range -complete=expression -nargs=* IIO   call visincr#VisBlockIncr(s:IIO   , <f-args>)
  com! -range -complete=expression -nargs=? IR    call visincr#VisBlockIncr(s:IR    , <f-args>)
  com! -range -complete=expression -nargs=? IIR   call visincr#VisBlockIncr(s:IIR   , <f-args>)
  com! -range -complete=expression -nargs=* IPOW  call visincr#VisBlockIncr(s:IPOW  , <f-args>)
  com! -range -complete=expression -nargs=* IIPOW call visincr#VisBlockIncr(s:IIPOW , <f-args>)

  com! -range -complete=expression -nargs=* RI     call visincr#VisBlockIncr(s:RI     , <f-args>)
  com! -range -complete=expression -nargs=* RII    call visincr#VisBlockIncr(s:RII    , <f-args>)
  com! -range -complete=expression -nargs=* RIMOD  call visincr#VisBlockIncr(s:RIMOD  , <f-args>)
  com! -range -complete=expression -nargs=* RIREP  call visincr#VisBlockIncr(s:RIREP  , <f-args>)
  com! -range -complete=expression -nargs=* RIMDY  call visincr#VisBlockIncr(s:RIMDY  , <f-args>)
  com! -range -complete=expression -nargs=* RIYMD  call visincr#VisBlockIncr(s:RIYMD  , <f-args>)
  com! -range -complete=expression -nargs=* RIDMY  call visincr#VisBlockIncr(s:RIDMY  , <f-args>)
  com! -range -complete=expression -nargs=? RID    call visincr#VisBlockIncr(s:RID    , <f-args>)
  com! -range -complete=expression -nargs=? RIM    call visincr#VisBlockIncr(s:RIM    , <f-args>)
  com! -range -complete=expression -nargs=? RIA    call visincr#VisBlockIncr(s:RIA    , <f-args>)
  com! -range -complete=expression -nargs=? RIX    call visincr#VisBlockIncr(s:RIX    , <f-args>)
  com! -range -complete=expression -nargs=? RIIX   call visincr#VisBlockIncr(s:RIIX   , <f-args>)
  com! -range -complete=expression -nargs=* RIB    call visincr#VisBlockIncr(s:RIB    , <f-args>)
  com! -range -complete=expression -nargs=* RIIB   call visincr#VisBlockIncr(s:RIIB   , <f-args>)
  com! -range -complete=expression -nargs=* RIO    call visincr#VisBlockIncr(s:RIO    , <f-args>)
  com! -range -complete=expression -nargs=* RIIO   call visincr#VisBlockIncr(s:RIIO   , <f-args>)
  com! -range -complete=expression -nargs=? RIR    call visincr#VisBlockIncr(s:RIR    , <f-args>)
  com! -range -complete=expression -nargs=? RIIR   call visincr#VisBlockIncr(s:RIIR   , <f-args>)
  com! -range -complete=expression -nargs=* RIPOW  call visincr#VisBlockIncr(s:RIPOW  , <f-args>)
  com! -range -complete=expression -nargs=* RIIPOW call visincr#VisBlockIncr(s:RIIPOW , <f-args>)

else
  com! -range -complete=expression -nargs=* VI_I     call visincr#VisBlockIncr(s:I     , <f-args>)
  com! -range -complete=expression -nargs=* VI_II    call visincr#VisBlockIncr(s:II    , <f-args>)
  com! -range -complete=expression -nargs=* VI_IMOD  call visincr#VisBlockIncr(s:IMOD  , <f-args>)
  com! -range -complete=expression -nargs=* VI_IREP  call visincr#VisBlockIncr(s:IREP  , <f-args>)
  com! -range -complete=expression -nargs=* VI_IMDY  call visincr#VisBlockIncr(s:IMDY  , <f-args>)
  com! -range -complete=expression -nargs=* VI_IYMD  call visincr#VisBlockIncr(s:IYMD  , <f-args>)
  com! -range -complete=expression -nargs=* VI_IDMY  call visincr#VisBlockIncr(s:IDMY  , <f-args>)
  com! -range -complete=expression -nargs=? VI_ID    call visincr#VisBlockIncr(s:ID    , <f-args>)
  com! -range -complete=expression -nargs=? VI_IM    call visincr#VisBlockIncr(s:IM    , <f-args>)
  com! -range -complete=expression -nargs=? VI_IA    call visincr#VisBlockIncr(s:IA    , <f-args>)
  com! -range -complete=expression -nargs=? VI_IX    call visincr#VisBlockIncr(s:IX    , <f-args>)
  com! -range -complete=expression -nargs=? VI_IIX   call visincr#VisBlockIncr(s:IIX   , <f-args>)
  com! -range -complete=expression -nargs=* VI_IB    call visincr#VisBlockIncr(s:IB    , <f-args>)
  com! -range -complete=expression -nargs=* VI_IIB   call visincr#VisBlockIncr(s:IIB   , <f-args>)
  com! -range -complete=expression -nargs=* VI_IO    call visincr#VisBlockIncr(s:IO    , <f-args>)
  com! -range -complete=expression -nargs=* VI_IIO   call visincr#VisBlockIncr(s:IIO   , <f-args>)
  com! -range -complete=expression -nargs=? VI_IR    call visincr#VisBlockIncr(s:IR    , <f-args>)
  com! -range -complete=expression -nargs=? VI_IIR   call visincr#VisBlockIncr(s:IIR   , <f-args>)
  com! -range -complete=expression -nargs=* VI_IPOW  call visincr#VisBlockIncr(s:IPOW  , <f-args>)
  com! -range -complete=expression -nargs=* VI_IIPOW call visincr#VisBlockIncr(s:IIPOW , <f-args>)

  com! -range -complete=expression -nargs=* VI_RI     call visincr#VisBlockIncr(s:RI     , <f-args>)
  com! -range -complete=expression -nargs=* VI_RII    call visincr#VisBlockIncr(s:RII    , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIMOD  call visincr#VisBlockIncr(s:RIMOD  , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIREP  call visincr#VisBlockIncr(s:RIREP  , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIMDY  call visincr#VisBlockIncr(s:RIMDY  , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIYMD  call visincr#VisBlockIncr(s:RIYMD  , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIDMY  call visincr#VisBlockIncr(s:RIDMY  , <f-args>)
  com! -range -complete=expression -nargs=? VI_RID    call visincr#VisBlockIncr(s:RID    , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIM    call visincr#VisBlockIncr(s:RIM    , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIA    call visincr#VisBlockIncr(s:RIA    , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIX    call visincr#VisBlockIncr(s:RIX    , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIIX   call visincr#VisBlockIncr(s:RIIX   , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIB    call visincr#VisBlockIncr(s:RIB    , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIIB   call visincr#VisBlockIncr(s:RIIB   , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIO    call visincr#VisBlockIncr(s:RIO    , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIIO   call visincr#VisBlockIncr(s:RIIO   , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIR    call visincr#VisBlockIncr(s:RIR    , <f-args>)
  com! -range -complete=expression -nargs=? VI_RIIR   call visincr#VisBlockIncr(s:RIIR   , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIPOW  call visincr#VisBlockIncr(s:RIPOW  , <f-args>)
  com! -range -complete=expression -nargs=* VI_RIIPOW call visincr#VisBlockIncr(s:RIIPOW , <f-args>)
endif

" ---------------------------------------------------------------------
"  Restoration And Modelines: {{{1
"  vim: ts=4 fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
