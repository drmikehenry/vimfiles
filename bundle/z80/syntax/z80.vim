syn case ignore

set isk=a-z,A-Z,48-57,',.,_

syn sync fromstart

" Common Z80 Assembly instructions
syn keyword z80Inst adc add and bit call ccf cp cpd cpdr cpi cpir cpl
syn keyword z80Inst daa dec di djnz ei ex exx halt im in
syn keyword z80Inst inc ind ini indr inir jp jr ld ldd lddr ldi ldir
syn keyword z80Inst neg nop or otdr otir out outd outi push pop
syn keyword z80Inst res ret reti retn rl rla rlc rlca rld
syn keyword z80Inst rr rra rrc rrca rrd rst sbc scf set sl1 sla slia sll sra
syn keyword z80Inst srl sub xor

" Grab the condition too
syn match z80Inst "\s\+jp\s\+n\=[covz]\>" "Match Z C O V NZ NC NO NV
syn match z80Inst "\s\+jp\s\+p[elo]\=\>" "Match P PE PO PL
syn match z80Inst "\s\+jp\s\+mi\=\>" "Match M MI
syn match z80Inst "\s\+jp\s\+eq\>" "Match EQ
syn match z80Inst "\s\+jp\s\+[gn]e\>" "Match NE GE
syn match z80Inst "\s\+jp\s\+lt\>" "Match LT
syn match z80Inst "\s\+jp\s\+sn\=f\>" "Match SF SNF

syn match z80Inst "\s\+jr\s\+n\=[zc]\>" "Match Z C NZ NC
syn match z80Inst "\s\+jr\s\+eq\>" "Match EQ
syn match z80Inst "\s\+jr\s\+[gn]e\>" "Match NE GE
syn match z80Inst "\s\+jr\s\+lt\>" "Match LT

syn match z80Inst "\s\+call\s\+n\=[covz]\>" "Match Z C O V NZ NC NO NV
syn match z80Inst "\s\+call\s\+p[elo]\=\>" "Match P PE PO PL
syn match z80Inst "\s\+call\s\+mi\=\>" "Match M MI
syn match z80Inst "\s\+call\s\+eq\>" "Match EQ
syn match z80Inst "\s\+call\s\+[gn]e\>" "Match NE GE
syn match z80Inst "\s\+call\s\+lt\>" "Match LT
syn match z80Inst "\s\+call\s\+sn\=f\>" "Match SF SNF

syn match z80Inst "\s\+ret\s\+n\=[covz]\>" "Match Z C O V NZ NC NO NV
syn match z80Inst "\s\+ret\s\+p[elo]\=\>" "Match P PE PO PL
syn match z80Inst "\s\+ret\s\+mi\=\>" "Match M MI
syn match z80Inst "\s\+ret\s\+eq\>" "Match EQ
syn match z80Inst "\s\+ret\s\+[gn]e\>" "Match NE GE
syn match z80Inst "\s\+ret\s\+lt\>" "Match LT
syn match z80Inst "\s\+ret\s\+sn\=f\>" "Match SF SNF

" Registers
syn keyword z80Reg af af' bc de hl ix ixh ixl iy iyh iyl
syn keyword z80Reg sp a b c d e f h i l r

" Directives
syn keyword z80PreProc equ org map ds defs dw defw db defb module endmodule
syn keyword z80PreProc include incbin macro endmacro repeat rept endrepeat endr
syn keyword z80PreProc ifdef ifndef if else endif rotate defpage page echo error

syn keyword z80PreProc .equ .org .map .ds .defs .dw .defw .db .defb .module .endmodule
syn keyword z80PreProc .include .incbin .macro .endmacro .repeat .rept .endrepeat .endr
syn keyword z80PreProc .ifdef .ifndef .if .else .endif .rotate .defpage .page .echo .error

" Strings
syn region z80String start=/"/ skip=/\\"/ end=/"/ oneline
syn region z80String start=/'/ end=/'/ oneline

" Labels
syn match z80Lbl "[A-Z_.?][A-Z_.?0-9]*:\="
syn region z80Lbl2 start="(" end=")" oneline contains=z80Number,z80Lbl,z80Lbl2,z80Other

" Operators
syn match z80Other "[~+\-*/%^&=!<>]"

" Numbers
syn match z80Number "\<\$\>"
syn match z80Number "\<[01]\+b\>"
syn match z80Number "\<\d\x*h\>"
syn match z80Number "\<\d\+\>"
syn match z80Number "\<%[01]\+\>"
syn match z80Number "\$[0-9a-fA-F]\+"
syn match z80Number "\<&[01]\+\>"
syn match z80Number "\<0x[0-9a-fA-F]\+\>"

" Indirect register access
syn region z80Reg start=/(ix/ end=/)/ keepend oneline contains=z80Lbl,z80Number,z80Reg,z80Other
syn region z80Reg start=/(iy/ end=/)/ keepend oneline contains=z80Lbl,z80Number,z80Reg,z80Other
syn match z80Reg "(b\=c)"
syn match z80Reg "(de)"
syn match z80Reg "(hl)"
syn match z80Reg "(sp)"

" Todo
syn keyword	cTodo		contained TODO FIXME XXX

" Comments
syn match z80Comment ";.*$" contains=cTodo
syn match z80Comment "^\*$"
syn region z80Comment2 start="\<\.endasm\>" skip="\n" end="\<\.asm\>" keepend contains=z80Comment,z80Comment2 
syn region z80Comment3 start="^#comment\>" skip="\n" end="^#endcomment\>" keepend
syn region z80Comment start="\/\*" end="\*\/" contains=cTodo
syn region z80Comment start="\/\*" end="\*\/" contains=cTodo

hi def link cTodo		Todo

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_z80_syntax_inits")
if version < 508
let did_z80_syntax_inits = 1
command -nargs=+ HiLink hi link <args>
else
command -nargs=+ HiLink hi def link <args>
endif

HiLink z80Reg Constant
HiLink z80Lbl Type
HiLink z80Lbl2 Type
HiLink z80Comment Comment
HiLink z80Comment2 Comment
HiLink z80Inst Statement
HiLink z80Include Include
HiLink z80PreProc PreProc
HiLink z80Number Number
HiLink z80String String
HiLink z80Other Operator
HiLink z80Todo Todo

delcommand HiLink
endif

let b:current_syntax = "z80"
set ts=8
set sw=8
" vim: ts=8

