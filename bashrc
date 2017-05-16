#!/usr/bin/env bash

################################################################################
#                                                                              #
#   Author: Mike 8a                                                            #
#   Description: Small shell configs                                           #
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

# Path to the bash it configuration
if [[ -d "$HOME/.bash-it" ]]; then
    export BASH_IT="$HOME/.bash-it"
elif [[ -d "$HOME/.bash_it" ]]; then
    export BASH_IT="$HOME/.bash_it"
fi

# Lock and Load a custom theme file
# location ~/.bash_it/themes/
export BASH_IT_THEME='bakke'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
# export SHORT_HOSTNAME=$(hostname -s)

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

################################################################################
#                               Some vim stuff                                 #
# Use <C-s> in terminal vim                                                    #
[[ $- == *i* ]] && stty -ixon                                                  #
# Set vi keys in the shell                                                     #
set -o vi
################################################################################

################################################################################
#                         Make some dir that I normally use                    #
################################################################################
[[ $HOME/.local/bin ]] && mkdir -p "$HOME/.local/bin"
[[ $HOME/.local/lib ]] && mkdir -p "$HOME/.local/lib"
[[ $HOME/.local/share ]] && mkdir -p "$HOME/.local/share"
[[ $HOME/.local/golang/src ]] && mkdir -p "$HOME/.local/golang/src"

if [[ -d $HOME/.local/bin/ ]]; then
    export PATH="$HOME/.local/bin/:$PATH"
fi

if [[ -f $HOME/.local/lib/pythonstartup.py ]]; then
    export PYTHONSTARTUP="$HOME/.local/lib/pythonstartup.py"
fi

if [[ -d $HOME/.local/neovim/bin ]]; then
    export PATH="$HOME/.local/neovim/bin:$PATH"
fi

if [[ -d $HOME/.local/golang/bin ]]; then
    export PATH="$HOME/.local/golang/bin:$PATH"
fi

if [[ -d $HOME/.local/golang/src ]]; then
    export GOPATH="$HOME/.local/golang/src"
fi

################################################################################
#                       Load the settings, alias and framework                 #
################################################################################

# We don't need this stuff if we are in a non interactive session
if [[ $- == *i* ]]; then

    # Load host settings
    if [[ -f ~/.shell_settings ]]; then
        source ~/.shell_settings
    fi

    # Load Bash It after set host settings
    if [[ -f "$BASH_IT/bash_it.sh" ]]; then
        source $BASH_IT/bash_it.sh

        # A like my normal sl
        unalias sl
    fi

    # Load alias after bash-it to give them higher priority
    if [[ -f ~/.shell_alias ]]; then
        source ~/.shell_alias
    fi

fi
