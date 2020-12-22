#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1090,SC1117

! hash is_wsl 2>/dev/null && is_wsl() { return 0; }
! hash is_64bits 2>/dev/null && is_64bits() { return 0; }
! hash is_windows 2>/dev/null && is_windows() { return 0; }

# Set vi keys
set -o vi

# Make backspace delete in a sane way
stty erase '^?'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s autocd
shopt -s globstar
shopt -s cdspell
shopt -s direxpand
shopt -s dirspell
shopt -s nocaseglob

# HISTCONTROL=ignoreboth
HISTCONTROL='erasedups:ignoreboth'
HISTFILESIZE=9999
HISTSIZE=9999
PROMPT_COMMAND='history -a'
shopt -s histappend histverify

# Path to the bash it configuration
if [[ -d "$HOME/.bash-it" ]]; then
    export BASH_IT="$HOME/.bash-it"
elif [[ -d "$HOME/.bash_it" ]]; then
    export BASH_IT="$HOME/.bash_it"
else

    export black="\[\e[0;30m\]"
    export red="\[\e[0;31m\]"
    export green="\[\e[0;32m\]"
    export yellow="\[\e[0;33m\]"
    export blue="\[\e[0;34m\]"
    export purple="\[\e[0;35m\]"
    export cyan="\[\e[0;36m\]"
    export white="\[\e[0;37m\]"
    export orange="\[\e[0;91m\]"
    export normal="\[\e[0m\]"
    export reset_color="\[\e[39m\]"

    # These colors are meant to be used with `echo -e`
    export echo_black="\033[0;30m"
    export echo_red="\033[0;31m"
    export echo_green="\033[0;32m"
    export echo_yellow="\033[0;33m"
    export echo_blue="\033[0;34m"
    export echo_purple="\033[0;35m"
    export echo_cyan="\033[0;36m"
    export echo_white="\033[0;37;1m"
    export echo_orange="\033[0;91m"
    export echo_normal="\033[0m"
    export echo_reset_color="\033[39m"

fi

# location ~/.bash_it/themes/
# Load it just in case it's not defined yet
if is_windows || ! is_64bits ; then
    [[ -z $BASH_IT_THEME ]] && export BASH_IT_THEME='demula'
else
    [[ -z $BASH_IT_THEME ]] && export BASH_IT_THEME='bakke'
fi

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
# [[ -z $GIT_HOSTING ]] &&  export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
# export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
# export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
# [[ -z $SCM_CHECK ]] && export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
# export SHORT_HOSTNAME=$(hostname -s)

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
# export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).

# INFO: Use enviroment variables to avoid shellcheck errors in bash_completion file
if ! shopt -oq posix; then

    COMPLETIONS="/usr/share/bash-completion"
    if [ -f "$COMPLETIONS/bash_completion" ]; then
        # shellcheck disable=SC1091
        source "$COMPLETIONS/bash_completion"
    fi

    COMPLETIONS="/etc"
    if [ -f "$COMPLETIONS/bash_completion" ]; then
        # shellcheck disable=SC1091
        source "$COMPLETIONS/bash_completion"
    fi
fi

# pip bash completion start
if hash pip 2>/dev/null || hash pip2 2>/dev/null || hash pip3 2>/dev/null ; then
    function _pip_completion()
    {
        # shellcheck disable=SC2207
        COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                    COMP_CWORD=$COMP_CWORD \
                    PIP_AUTO_COMPLETE=1 $1 ) )
    }
    hash pip 2>/dev/null && complete -o default -F _pip_completion pip
    hash pip2 2>/dev/null && complete -o default -F _pip_completion pip2
    hash pip3 2>/dev/null && complete -o default -F _pip_completion pip3
fi
# pip bash completion end

if hash fzf 2>/dev/null; then
    # shellcheck disable=SC1091
    [[ -f "$HOME/.fzf.bash" ]] && source "$HOME/.fzf.bash"
fi

if [[ -f "$BASH_IT/bash_it.sh" ]]; then
    # shellcheck disable=SC1091
    source "$BASH_IT/bash_it.sh"
else

    __schroot_name(){
        if [[ -n ${SCHROOT_CHROOT_NAME} ]]; then
            echo -e "${echo_red}(${SCHROOT_CHROOT_NAME})${echo_reset_color} "
        fi
    }

    __git_branch(){
        if hash git 2>/dev/null; then
            local branch
            branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
            if [[ -n $branch ]]; then
                echo -e " ${echo_blue}| ${branch} |${echo_reset_color} "
            fi
        fi
    }

    PS1="\n$(__schroot_name)${purple}\u${reset_color} at ${cyan}\h${reset_color}: ${green}\w${reset_color}\$(__git_branch) \n→ "
fi

if hash tmux 2>/dev/null; then
    bind '"\C-a":"tmux a || tmux new -s main\n"'
fi
