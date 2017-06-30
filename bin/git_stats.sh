#!/usr/bin/env bash

#   Author: Awesome work from https://github.com/esc/git-stats
#   Description: Get statistics of the current git dir (CWD)
#
#                                     -`
#                     ...            .o+`
#                  .+++s+   .h`.    `ooo/
#                 `+++%++  .h+++   `+oooo:
#                 +++o+++ .hhs++. `+oooooo:
#                 +s%%so%.hohhoo'  'oooooo+:
#                 `+ooohs+h+sh++`/:  ++oooo+:
#                  hh+o+hoso+h+`/++++.+++++++:
#                   `+h+++h.+ `/++++++++++++++:
#                            `/+++ooooooooooooo/`
#                           ./ooosssso++osssssso+`
#                          .oossssso-````/osssss::`
#                         -osssssso.      :ssss``to.
#                        :osssssss/  Mike  osssl   +
#                       /ossssssss/   8a   +sssslb
#                     `/ossssso+/:-        -:/+ossss'.-
#                    `+sso+:-`                 `.-/+oso:
#                   `++:.                           `-/+/
#                   .`   github.com/mike325/dotfiles   `/

NAME="$0"
NAME="${NAME##*/}"

function help_user() {
    echo ""
    echo "  Get statistics of the current git dir (CWD)"
    echo ""
    echo "  Usage:"
    echo "      $NAME [OPTIONAL]"
    echo "          Ex."
    echo "          $ $NAME"
    echo ""
    echo "      Optional Flags"
    echo "          -h, --help"
    echo "              Display help and exit. If you are seeing this, that means that you already know it (nice)"
    echo ""
    echo "          -w"
    echo "              Add '-w' to 'git log', check 'git log --help' for more info"
    echo ""
    echo "          -M"
    echo "              Add '-M' to 'git log', check 'git log --help' for more info"
    echo ""
    echo "          -C"
    echo "              Add '-C' and '--find-copies-harder' to 'git log', check 'git log --help' for more info"
    echo ""
}

for key in "$@"; do
    case "$key" in
        -h|--help)
            help_user
            exit 0
            ;;
    esac
done

if [[ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]]; then
    echo "Number of commits per author:"
    git --no-pager shortlog -sn --all
    AUTHORS=$( git shortlog -sn --all | cut -f2 | cut -f1 -d' ')
    LOGOPTS=""
    if [[  "$1" == '-w' ]]; then
        LOGOPTS="$LOGOPTS -w"
        shift
    fi
    if [[  "$1" == '-M' ]]; then
        LOGOPTS="$LOGOPTS -M"
        shift
    fi
    if [[  "$1" == '-C' ]]; then
        LOGOPTS="$LOGOPTS -C --find-copies-harder"
        shift
    fi
    for a in $AUTHORS
    do
        echo '-------------------'
        echo "Statistics for: $a"
        echo -n "Number of files changed: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f3 | sort -iu | wc -l
        echo -n "Number of lines added: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f1 | awk '{s+=$1} END {print s}'
        echo -n "Number of lines deleted: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f2 | awk '{s+=$1} END {print s}'
        echo -n "Number of merges: "
        git log $LOGOPTS --all --merges --author=$a | grep -c '^commit'
    done
else
    echo "    ---- [X] Error You're currently not in a git repository"
    exit 1
fi
