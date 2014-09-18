from test.vim_test_case import VimTestCase as _VimTest
from test.constant import *

# Test for bug 1251994  {{{#
class Bug1251994(_VimTest):
    snippets = ("test", "${2:#2} ${1:#1};$0")
    keys = "  test" + EX + "hello" + JF + "world" + JF + "blub"
    wanted = "  world hello;blub"
# End: 1251994  #}}}

# Test for https://github.com/SirVer/ultisnips/issues/157 (virtualedit) {{{#
class VirtualEdit(_VimTest):
    snippets = ("pd", "padding: ${1:0}px")
    keys = "\t\t\tpd" + EX + "2"
    wanted = "\t\t\tpadding: 2px"

    def _extra_options_pre_init(self, vim_config):
        vim_config.append('set virtualedit=all')
        vim_config.append('set noexpandtab')
# End: 1251994  #}}}

# Test for Github Pull Request #134 - Retain unnamed register {{{#
class RetainsTheUnnamedRegister(_VimTest):
    snippets = ("test", "${1:hello} ${2:world} ${0}")
    keys = "yank" + ESC + "by4lea test" + EX + "HELLO" + JF + JF + ESC + "p"
    wanted = "yank HELLO world yank"
class RetainsTheUnnamedRegister_ButOnlyOnce(_VimTest):
    snippets = ("test", "${1:hello} ${2:world} ${0}")
    keys = "blahfasel" + ESC + "v" + 4*ARR_L + "xotest" + EX + ESC + ARR_U + "v0xo" + ESC + "p"
    wanted = "\nblah\nhello world "
# End: Github Pull Request # 134 #}}}


