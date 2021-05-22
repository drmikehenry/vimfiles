" -------------------------------------------------------------
" For swapit plugin.
" -------------------------------------------------------------

" This file runs after the plugin/swapit.vim file.  Don't bother with
" modifying g:swap_list_dont_append to avoid the defaults, as we're just going
" to overwrite them below.

" See swapit.vim at bottom for original g:default_swap_list.
let g:default_swap_list = [
        \{'name':'yes/no', 'options': ['yes','no']},
        \{'name':'Yes/No', 'options': ['Yes','No']},
        \{'name':'YES/NO', 'options': ['YES','NO']},
        \{'name':'true/false', 'options': ['true','false']},
        \{'name':'True/False', 'options': ['True','False']},
        \{'name':'TRUE/FALSE', 'options': ['TRUE','FALSE']},
        \{'name':'or/and', 'options': ['or','and']},
        \{'name':'Or/And', 'options': ['Or','And']},
        \{'name':'OR/AND', 'options': ['OR','AND']},
        \{'name':'on/off', 'options': ['on','off']},
        \{'name':'On/Off', 'options': ['On','Off']},
        \{'name':'ON/OFF', 'options': ['ON','OFF']},
        \]
