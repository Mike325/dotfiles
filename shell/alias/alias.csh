#!/usr/bin/env tcsh

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Some useful alias                                             #
#                                                                              #
#                                     -`                                       #
#                     ...            .o+`                                      #
#                  .+++s+   .h`.    `ooo/                                      #
#                 `+++%++  .h+++   `+oooo:                                     #
#                 +++o+++ .hhs++. `+oooooo:                                    #
#                 +s%%so%.hohhoo'  'oooooo+:                                   #
#                 `+ooohs+h+sh++`/:  ++oooo+:                                  #
#                  hh+o+hoso+h+`/++++.+++++++:                                 #
#                   `+h+++h.+ `/++++++++++++++:                                #
#                            `/+++ooooooooooooo/`                              #
#                           ./ooosssso++osssssso+`                             #
#                          .oossssso-````/osssss::`                            #
#                         -osssssso.      :ssss``to.                           #
#                        :osssssss/  Mike  osssl   +                           #
#                       /ossssssss/   8a   +sssslb                             #
#                     `/ossssso+/:-        -:/+ossss'.-                        #
#                    `+sso+:-`                 `.-/+oso:                       #
#                   `++:.                           `-/+/                      #
#                   .`   github.com/mike325/dotfiles   `/                      #
#                                                                              #
################################################################################

################################################################################
#                          Set the default text editor                         #
################################################################################

if ( `where vim` != "" ) then
    if ( `where nvim` != "" ) then
        alias cdvi "cd ~/.vim"
        alias cdvim "cd ~/.config/nvim"
        # NOTE: This is set inside Neovim settings
        # shellcheck disable=SC2154
        if ( ! ($?nvr) ) then
            setenv MANPAGER "nvim -R --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal readonly nomodifiable ft=man' -"
            # setenv GIT_PAGER "nvim --cmd 'let g:minimal=1' --cmd 'setlocal modifiable noswapfile nobackup noundofile' -c 'setlocal ft=git readonly nomodifiable' - "
            setenv EDITOR "nvim"
            alias vi "nvim --cmd 'let g:minimal=1'"
            alias viu "nvim -u NONE"
            # Fucking typos
            alias nvi "nvim"
            alias vnim "nvim"
        else
            setenv MANPAGER "nvr -cc 'setlocal modifiable' -c 'silent! setlocal ft=man' --remote-tab -"
            # setenv GIT_PAGER "nvr -cc 'setlocal modifiable' -c 'setlocal ft=git readonly nomodifiable' --remote-tab -"
            setenv EDITOR "nvr --remote-tab-wait"
            alias vi "nvr --remote-silent"
            alias nvi "nvr --remote-silent"
            alias nvim "nvr --remote-silent"
            alias vnim "nvr --remote-silent"
        endif
    else
        alias cdvim "cd ~/.vim"
        setenv MANPAGER "env MAN_PN=1 vim --cmd 'let g:minimal=1 --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=man readonly nomodifiable' +MANPAGER -"
        # setenv GIT_PAGER "vim --cmd 'let g:minimal=1' --cmd 'setlocal noswapfile nobackup noundofile' -c 'setlocal ft=git readonly nomodifiable' -"
        setenv EDITOR "vim"

        alias vi "vim --cmd 'let g:minimal=1'"
        alias viu "vim -u NONE"
    endif
endif


################################################################################
#                          Fix my common typos                                 #
################################################################################

alias gti "git"
alias got "git"
alias gut "git"
alias gi "git"

if ( `where nvim` != "" ) then
    alias bim "nvim"
    alias cim "nvim"
    alias im "nvim"
else
    alias bim "vim"
    alias cim "vim"
    alias im "vim"
endif

alias bi "vi"
alias ci "vi"

alias py "python"
alias py2 "python2"
alias py3 "python3"


################################################################################
#                        Some useful shortcuts                                 #
################################################################################

if ( `where thefuck` != "" ) then
    alias fuck 'set fucked_cmd=`history -h 2 | head -n 1` && eval `thefuck ${fucked_cmd}`'

    # Yep tons of fucks
    alias guck 'fuck'
    alias fukc 'fuck'
    alias gukc 'fuck'
    alias fuvk 'fuck'
endif

alias sshkey 'ssh-keygen -t rsa -b 4096 -C "${MAIL:-mickiller.25@gmail.com}"'

alias user "whoami"
alias j "jobs"

# Check all user process
alias psu 'ps -u $USER'

alias cl "clear"

alias q "exit"

# Show used ports
alias ports "netstat -tulpn"

alias grep "grep --color -n"

alias grepo "grep -o"
alias grepe "grep -E"

alias ls 'ls --color'
alias la "ls -A"
alias ll "ls -lh"
alias lla "ls -lhA"

# This way sudo commands get the alias of the account
# ( $EUID -ne 0 ) && alias sudo 'sudo '

# laod kernel module for virtualbox
# ( $EUID -ne 0 ) && alias vbk "sudo modprobe vboxdrv"

################################################################################
#             Functions to move around dirs and other simple stuff             #
#                                                                              #
#                      NO FUCKING FUNCTIONS IN TCSH                            #
################################################################################

alias bk "cd .."

alias rl "rm -rf ./.log"

if ( `where fzf` != "" ) then
    if ( `where git` != "" ) then
        if ( `where fd` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || fd --type f --hidden --follow --color always -E "*.spl" -E "*.aux" -E "*.out" -E "*.o" -E "*.pyc" -E "*.gz" -E "*.pdf" -E "*.sw" -E "*.swp" -E "*.swap" -E "*.com" -E "*.exe" -E "*.so" -E "*/cache/*" -E "*/__pycache__/*" -E "*/tmp/*" -E ".git/*" -E ".svn/*" -E ".xml" -E "*.bin" -E "*.7z" -E "*.dmg" -E "*.gz" -E "*.iso" -E "*.jar" -E "*.rar" -E "*.tar" -E "*.zip" -E "TAGS" -E "tags" -E "GTAGS" -E "COMMIT_EDITMSG" . .  '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
            setenv FZF_ALT_C_COMMAND "fd --color always -t d . $HOME"
        else if ( `where rg` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || rg --line-number --column --with-filename --color always --no-search-zip --hidden --trim --files . '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        else if ( `where ag` != "" ) then
            setenv FZF_DEFAULT_COMMAND 'git --no-pager ls-files -co --exclude-standard || ag -l --follow --color --nogroup --hidden --ignore "*.spl" --ignore "*.aux" --ignore "*.out" --ignore "*.o" --ignore "*.pyc" --ignore "*.gz" --ignore "*.pdf" --ignore "*.sw" --ignore "*.swp" --ignore "*.swap" --ignore "*.com" --ignore "*.exe" --ignore "*.so" --ignore "/cache/" --ignore "/__pycache__/" --ignore "/tmp/" --ignore ".git/" --ignore ".svn/" --ignore ".xml" --ignore "*.log" --ignore "*.bin" --ignore "*.7z" --ignore "*.dmg" --ignore "*.gz" --ignore "*.iso" --ignore "*.jar" --ignore "*.rar" --ignore "*.tar" --ignore "*.zip" --ignore "TAGS" --ignore "tags" --ignore "GTAGS" --ignore "COMMIT_EDITMSG" -g "" '
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        else
            setenv FZF_DEFAULT_COMMAND "git --no-pager ls-files -co --exclude-standard || find . -iname '*'"
            setenv FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        endif
    endif
    setenv FZF_CTRL_R_OPTS '--sort'

    setenv FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --ansi'
    # Use ~~ as the trigger sequence instead of the default **
    setenv FZF_COMPLETION_TRIGGER '**'

    # Options to fzf command
    setenv FZF_COMPLETION_OPTS '+c -x'
endif
