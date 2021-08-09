#!/usr/bin/env python
# vim:set fileencoding=utf8:

import sys
import re
import setpypath

from sniputil import put

from sniputil import snip, bsnip, wsnip, snip
from sniputil import abbr, babbr, wabbr


put(r"""
priority -5

global !p
from sniputil import betterVisual
endglobal
""")

bsnip("fn", "fn name(?) -> ? {}", r"""
fn ${1:function_name}($2)${3/..*/ -> /}${3:Result<${4:()}, Box<dyn std::error::Error>>} {
    `!p betterVisual(snip)`$0
}
""")

bsnip("pfn", "pub fn name(?) -> ? {}", r"""
pub fn ${1:function_name}($2)${3/..*/ -> /}${3:Result<${4:()}, Box<dyn std::error::Error>>} {
    `!p betterVisual(snip)`$0
}
""")

bsnip("new", "pub fn new(?) -> Self {}", r"""
pub fn new($1) -> Self {
    Self { $0 }
}
""")

wsnip("pr", "println!(...)", r"""
println!("$1"${1/[^{]*({)?.*/(?1:, :\);)/}$2${1/[^{]*({)?.*/(?1:\);:)/}
""")

wsnip("pri", "print!(...)", r"""
print!("$1"${1/[^{]*({)?.*/(?1:, :\);)/}$2${1/[^{]*({)?.*/(?1:\);:)/}
""")

wsnip("fmt", "format!(...)", r"""
format!("$1"${1/[^{]*({)?.*/(?1:, :\);)/}$2${1/[^{]*({)?.*/(?1:\);:)/}
""")

# 'if' snippets.
wsnip("if", "if ... {...}", r"""
if $1 {
    `!p betterVisual(snip)`$0
}
""")

wsnip("else", "else {...}", r"""
else {
    `!p betterVisual(snip)`$0
}
""", aliases=["el"])

wsnip("elif", "else if ... {...}", r"""
else if $1 {
    `!p betterVisual(snip)`$0
}
""", aliases = ["ei"])

wsnip("match", "match pattern { ? => ? }", r"""
match ${1:expression} {
    ${2:Some(thing)} => ${3:result}
}
""", aliases = ["m"])

# Loop snippets.

bsnip("for", "for ... in ... {...}", r"""
for ${1:var} in ${2:iter} {
    `!p betterVisual(snip)`$0
}
""", aliases=[])

bsnip("while", "while ... {...}", r"""
while $1 {
    `!p betterVisual(snip)`$0
}
""", aliases=["wh"])

bsnip("loop", "loop {...}", r"""
loop {
    `!p betterVisual(snip)`$0
}
""", aliases=[])

# TODO commenting.

wsnip("todo", "// TODO comment", r"""
// TODO: $0
}
""", aliases = [])

wsnip("fixme", "// FIXME comment", r"""
// FIXME: $0
}
""", aliases = [])

wsnip("re", "return ", r"""return """)

bsnip("struct", "struct {...}", r"""
struct ${1:Name} {
    `!p betterVisual(snip)`$0
}
""", aliases=["st"])

bsnip("impl", "impl Type/Trait for Type {...}", r"""
impl ${1:Type/Trait} for ${2:Type} {
    `!p betterVisual(snip)`$0
}
""", aliases=[])

bsnip("sti", "struct {...} with impl", r"""
struct ${1:Name} {
    `!p betterVisual(snip)`$0
}

impl $1 {
    pub fn new() -> Self {
        Self { }
    }
}
""")

bsnip("enum", "enum {...}", r"""
enum ${1:Name} {
    `!p betterVisual(snip)`$0
}
""", aliases=[])

bsnip("trait", "trait {...}", r"""
trait ${1:Name} {
    `!p betterVisual(snip)`$0
}
""", aliases=[])

bsnip("drop", "impl Drop for Type {...}", r"""
impl Drop for ${1:Name} {
    fn drop(&mut self) {
        `!p betterVisual(snip)`$0
    }
}
""", aliases=[])

snip("{", "multi-line brace", r"""
{
    $0
}
""")

wsnip("as", "assert!(...)", r"""
assert!($1);
""")

wsnip("ase", "assert_eq!(..., ...)", r"""
assert_eq!($1, $2);
""")

wsnip("asne", "assert_ne!(..., ...)", r"""
assert_ne!($1, $2);
""")

