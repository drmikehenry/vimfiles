" If settings.py exists in current or any parent directory, assume Django.
if findfile("settings.py", expand("%:p:h") . ";") != ""
    source <sfile>:h/django_swapit.vim
endif
