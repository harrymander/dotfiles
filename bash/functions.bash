# shellcheck shell=bash

# Various useful shell functions and aliases. Source this file in .bashrc.

# Open multiple files with xdg-open
open() {
    for i in "$@"; do
        xdg-open "$i"
    done
}

venv() {
    if [[ "$1" = "--help" ]]; then
        cat << EOF
Usage: ${FUNCNAME[@]} [VENV-DIR]

Activate a Python virtual environment in the specified directory. If no
directory is provided, first looks under the current directory for a directory
named .venv, if there is no virtualenv located there, activates the virtualenv
managed by Poetry if the current dir or any of its parent dirs is a Poetry
project.
EOF
    return
    fi

    local venv_dir
    if [[ "$1" ]]; then
        venv_dir=$1
        if ! [[ -e "$venv_dir" ]]; then
            >&2 echo "Path does not exist: $venv_dir"
            return 1
        fi
        if ! [[ -d "$venv_dir" ]]; then
            >&2 echo "Not a directory: $venv_dir"
            return 1
        fi
    else
        venv_dir=.venv
    fi

    if [[ "$VIRTUAL_ENV" ]]; then
        >&2 echo "virtualenv already activated: $VIRTUAL_ENV"
        return 1
    fi

    local activate
    local venv_path=$venv_dir/bin/activate
    if [[ -f "$venv_path" ]]; then
        activate="source '$venv_path'"
    elif [[ "$1" ]]; then
        >&2 echo "Not a virtualenv directory: $venv_dir"
        return 1
    else
        >&2 echo "Not a virtualenv directory: $venv_dir; trying Poetry..."
        if ! activate=$(poetry env activate); then
            return 1
        fi
    fi

    >&2 echo "$activate"
    eval "$activate"
}

# Change to parent directory of argument
cdd() {
    local dir
    dir=$(dirname -- "$1")
    >&2 echo "$dir"

    # shellcheck disable=SC2164
    cd -- "$dir"
}

alias last-screenshot='
    find "$HOME/Pictures/Screenshots" -maxdepth 1 -name "Screenshot from *" |
    sort -r |
    head -n 1'
alias rsync="rsync --verbose --info=progress2"

pydocs() { zeal "python:$*"; }
cppref() { zeal "cpp:$*"; }
cref() { zeal "c:$*"; }
