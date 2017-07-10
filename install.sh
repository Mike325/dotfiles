#!/usr/bin/env bash

#   Author: Mike 8a
#   Description: Install all my basic configs and scripts
#
#                              -`
#              ...            .o+`
#           .+++s+   .h`.    `ooo/
#          `+++%++  .h+++   `+oooo:
#          +++o+++ .hhs++. `+oooooo:
#          +s%%so%.hohhoo'  'oooooo+:
#          `+ooohs+h+sh++`/:  ++oooo+:
#           hh+o+hoso+h+`/++++.+++++++:
#            `+h+++h.+ `/++++++++++++++:
#                     `/+++ooooooooooooo/`
#                    ./ooosssso++osssssso+`
#                   .oossssso-````/osssss::`
#                  -osssssso.      :ssss``to.
#                 :osssssss/  Mike  osssl   +
#                /ossssssss/   8a   +sssslb
#              `/ossssso+/:-        -:/+ossss'.-
#             `+sso+:-`                 `.-/+oso:
#            `++:.                           `-/+/
#            .`   github.com/mike325/dotfiles   `/

_ALL=1
_ALIAS=0
_VIM=0
_NVIM=0
_BIN=0
_SHELL_FRAMEWORK=0
_EMACS=0
_DOTFILES=0
_GIT=0
_FORCE_INSTALL=0

_NAME="$0"
_NAME="${_NAME##*/}"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH="$(realpath $_SCRIPT_PATH)"
else
    pushd "$_SCRIPT_PATH" > /dev/null
    _SCRIPT_PATH="$(pwd -P)"
    popd > /dev/null
fi

_CMD="ln -s"
_BASE_URL="https://github.com/mike325"

_DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"
_IS_WINDOWS=0

# Windows stuff
if [[ $(uname --all) =~ MINGW ]]; then
    _CURRENT_SHELL="$(ps | grep `echo $$` | awk '{ print $8 }')"
    _CURRENT_SHELL="${_CURRENT_SHELL##*/}"
    # Windows does not support links we will use cp instead
    _IS_WINDOWS=1
    _CMD="cp -rf"
else
    _CURRENT_SHELL="$(ps | grep `echo $$` | awk '{ print $4 }')"
fi

function help_user() {
    echo ""
    echo "  Simple installer of this dotfiles, by default install (link) all settings and configurations"
    echo "  if any flag ins given, the script will install just want is being told to do."
    echo "      By default command (if none flag is given): $_NAME -s -a -e -v -n -b -g"
    echo ""
    echo "  Usage:"
    echo "      $_NAME [OPTIONAL]"
    echo ""
    echo "      Optional Flags"
    echo "          -f, --force"
    echo "              Force installation, remove all previous conflict files before installing"
    echo "              This flag is always disable by default"
    echo ""
    echo "          -s, --shell_frameworks"
    echo "              Install shell frameworks, bash-it or oh-my-zsh according to the current shell"
    echo "              Current shell:   $_CURRENT_SHELL"
    echo ""
    echo "          -c, --copy"
    echo "              By default all dotfiles are linked using 'ln -s' command, this flag change"
    echo "              the command to 'cp -rf' this way you can remove the folder after installation"
    echo "              but you need to re-download the files each time you want to update the files"
    echo "              ----    Option not valid in windows platforms"
    echo "              ----    WARNING!!! if you use the option -f/--force all host Setting will be deleted!!!"
    echo ""
    echo "          -a, --alias"
    echo "              Install shell alias and shell basic configurations \${SHELL}rc for bash and zsh"
    echo ""
    echo "          -d, --dotfiles"
    echo "              Download my dotfiles repo in case, this options is meant to be used in case this"
    echo "              script is standalone executed"
    echo "                  URL: https://github.com/mike325/dotfiles"
    echo ""
    echo "          -e, --emacs"
    echo "              Download and install my evil Emacs dotfiles and install systemd's emacs.service"
    echo "                  URL: https://github.com/mike325/.emacs.d"
    echo ""
    echo "          -v, --vim"
    echo "              Download and install my Vim dotfiles"
    echo "                  URL: https://github.com/mike325/.vim"
    echo ""
    echo "          -n, --neovim"
    echo "              Download and install my Vim dotfiles in Neovim's dir."
    echo "              Check if vim dotfiles are already install and copy/link (depends of '-c/copy' flag)"
    echo "              them, otherwise download them from my vim's dotfiles repo"
    echo "                  URL: https://github.com/mike325/.vim"
    echo ""
    echo "          -b, --bin"
    echo "              Install shell functions and scripts in $HOME/.local/bin"
    echo ""
    echo "          -g, --git"
    echo "              Install my gitconfigs, hooks and templates"
    echo ""
    echo "          -h, --help"
    echo "              Display help, if you are seeing this, that means that you already know it (nice)"
    echo ""
}

function warn_msg() {
    WARN_MESSAGE="$1"
    printf "[!]     ---- Warning!!! $WARN_MESSAGE \n"
}

function error_msg() {
    ERROR_MESSAGE="$1"
    printf "[X]     ---- Error!!!   $ERROR_MESSAGE \n"
}

function status_msg() {
    STATUS_MESSAGGE="$1"
    printf "[*]     ---- $STATUS_MESSAGGE \n"
}

function execute_cmd() {
    local pre_cmd="$1"
    local post_cmd="$2"

    if [[ $_FORCE_INSTALL -eq 1 ]]; then
        rm -rf "$post_cmd"
    elif [[ -f "$post_cmd" ]] || [[ -d "$post_cmd" ]]; then
        warn_msg "Skipping ${post_cmd##*/}, already exists in ${post_cmd%/*}"
        return 1
    fi

    sh -c "$_CMD $pre_cmd $post_cmd"

    (( $? == 0 )) && return 0 || return "$?"
}

function clone_repo() {
    local repo="$1"
    local dest="$2"

    if hash git 2>/dev/null; then
        if [[ $_FORCE_INSTALL -eq 1 ]]; then
            rm -rf "$post_cmd"
        else
            warn_msg "Skipping ${repo##*/}, already exists in $dest"
            return 1
        fi

        if [[ ! -d "$dest" ]]; then
            git clone --recursive "$repo" "$dest"
        fi
    else
        error_msg "Git command is not available"
        return 2
    fi

    (( $? == 0 )) && return 0 || return "$?"
}


function setup_scripts() {
    status_msg "Getting shell functions and scripts"

    for script in ${_SCRIPT_PATH}/bin/*; do
        local scriptname="${script##*/}"

        local file_basename="${scriptname%%.*}"
        local file_extention="${scriptname##*.}"

        execute_cmd "$script" "$HOME/.local/bin/$file_basename"
    done

    status_msg "Getting python startup script"
    execute_cmd "${_SCRIPT_PATH}/scripts/pythonstartup.py" "$HOME/.local/lib/pythonstartup.py"

    status_msg "Getting ctags defaults"
    execute_cmd "${_SCRIPT_PATH}/ctags" "$HOME/.ctags"
}

function setup_alias() {
    # Currently just ZSH and BASH are the available shells
    status_msg "Getting Shell init file"
    if [[ $_CURRENT_SHELL =~ bash ]] || [[ $_CURRENT_SHELL =~ zsh ]]; then
        execute_cmd "${_SCRIPT_PATH}/shell/shellrc" "$HOME/.${_CURRENT_SHELL}rc"
        # execute_cmd "${_SCRIPT_PATH}/shell/${_CURRENT_SHELL}_settings" "$HOME/.config/shell/shell_specific"

        (( $? != 0 )) && return $?

        status_msg "Getting shell configs"
        execute_cmd "${_SCRIPT_PATH}/shell/" "$HOME/.config/shell"

        # Since we could fail linking/copying the dir, lets check it first
        (( $? != 0 )) && return $?
        [[ ! -d  "$HOME/.config/shell/host" ]] && mkdir -p  "$HOME/.config/shell/host"
    else
        warn_msg "Current shell ( $_CURRENT_SHELL ) is unsupported"
    fi
}

function setup_git() {
    status_msg "Installing Global Git settings"
    execute_cmd "${_SCRIPT_PATH}/git/gitconfig" "$HOME/.gitconfig"

    status_msg "Installing Global Git templates and hooks"
    execute_cmd "${_SCRIPT_PATH}/git" "$HOME/.config/git"

    status_msg "Setting up local git commands"
    [[ ! -d "$HOME/.config/git/host" ]] && mkdir -p "$HOME/.config/git/host"
}

function get_vim_dotfiles() {
    status_msg "Cloning vim dotfiles in $HOME/.config/nvim"

    clone_repo "$_BASE_URL/.vim" "$HOME/.vim"

    # If we couldn't clone our repo, return
    (( $? != 0 )) && return $?

    execute_cmd "$HOME/.vim/init.vim" "$HOME/.vimrc"
    (( $? == 0 )) && return 0 || return "$?"
}

function get_nvim_dotfiles() {
    status_msg "Running Neovim install script"

    # Since no all systems have sudo/root access lets assume all dependencies are
    # already installed; Lets clone neovim in $HOME/.local/neovim and install pip libs
    ${_SCRIPT_PATH}/bin/get_nvim.sh -c -d "$HOME/.local/" -p

    # If we couldn't clone our repo, return
    (( $? != 0 )) && return $?

    # if the current command creates a symbolic link and we already have some vim
    # settings, lets use them
    status_msg "Checking existing vim dotfiles"
    if [[ "$_CMD" == "ln -s" ]] && [[ -d "$HOME/.vim" ]]; then
        status_msg "Linking current vim dotfiles"
        execute_cmd "$HOME/.vim" "$HOME/.config/nvim"
    else
        status_msg "Cloning vim dotfiles in $HOME/.config/nvim"
        clone_repo "$_BASE_URL/.vim" "$HOME/.vim"
    fi

    (( $? == 0 )) && return 0 || return "$?"
}

function get_emacs_dotfiles() {
    status_msg "Installing Evil Emacs"

    clone_repo "$_BASE_URL/.emacs.d" "$HOME/.emacs.d"

    # If we couldn't clone our repo, return
    (( $? != 0 )) && return $?

    mkdir -p "$HOME/.config/systemd/user"
    execute_cmd "${_SCRIPT_PATH}/services/emacs.service" "$HOME/.config/systemd/user/emacs.service"

    (( $? == 0 )) && return 0 || return "$?"
}

function setup_shell_framework() {
    status_msg "Getting shell framework"

    ${_SCRIPT_PATH}/bin/get_shell.sh

    (( $? == 0 )) && return 0 || return "$?"
}

function get_dotfiles() {
    _SCRIPT_PATH="$HOME/.local/dotfiles"

    status_msg "Installing dotfiles in $_SCRIPT_PATH"

    mkdir -p "$HOME/.local/"
    clone_repo "$_BASE_URL/dotfiles" "$HOME/dotfiles"

    (( $? == 0 )) && return 0 || return "$?"
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -c|--copy)
            _CMD="cp -rf"
            ;;
        -a|--alias)
            _ALIAS=1
            _ALL=0
            ;;
        -s|--shell_frameworks)
            _SHELL_FRAMEWORK=1
            _ALL=0
            ;;
        -f|--force)
            _FORCE_INSTALL=1
            ;;
        -d|--dotfiles)
            _DOTFILES=1
            ;;
        -e|--emacs)
            _EMACS=1
            _ALL=0
            ;;
        -v|--vim)
            _VIM=1
            _ALL=0
            ;;
        -n|--neovim)
            _NVIM=1
            _ALL=0
            ;;
        -b|--bin)
            _BIN=1
            _ALL=0
            ;;
        -g|--git)
            _GIT=1
            _ALL=0
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
    esac
    shift
done

[[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
[[ ! -d "$HOME/.local/lib" ]] && mkdir -p  "$HOME/.local/lib/"

# If the user request the dotfiles or the script path doesn't have the full files
# (the command may be executed using `curl`)
if [[ $_DOTFILES -eq 1 ]] || [[ ! -f "${_SCRIPT_PATH}/shell/alias" ]]; then
    get_dotfiles
    if (( $? != 0 )); then
       error_msg "Could not install dotfiles"
       exit 1
    fi
fi

if [[ $_ALL -eq 1 ]]; then
    setup_scripts
    setup_alias
    setup_shell_framework
    setup_git
    get_vim_dotfiles
    get_nvim_dotfiles
    get_emacs_dotfiles
else
    [[ $_BIN -eq 1 ]] && setup_scripts
    [[ $_ALIAS -eq 1 ]] && setup_alias
    [[ $_SHELL_FRAMEWORK -eq 1 ]] && setup_shell_framework
    [[ $_GIT -eq 1 ]] && setup_git
    [[ $_VIM -eq 1 ]] && get_vim_dotfiles
    [[ $_NVIM -eq 1 ]] && get_nvim_dotfiles
    [[ $_EMACS -eq 1 ]] && get_emacs_dotfiles
fi