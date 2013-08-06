" On my Dvorak keyboard, I much prefer the use of , as the leader.
let mapleader=","

" Don't use Powerline on 8-color terminals... it just doesn't look good.
if !has("gui_running") && &t_Co == 8
    let g:EnablePowerline = 0
endif
