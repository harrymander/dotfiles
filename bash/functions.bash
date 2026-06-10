# shellcheck shell=bash

# Various useful shell functions and aliases. Source this file in .bashrc.

# Open multiple files with xdg-open
open() {
    for i in "$@"; do
        2>/dev/null xdg-open "$i"
    done
}

venv() {
    if [[ "$1" = "--help" ]]; then
        cat << EOF
Usage: ${FUNCNAME[@]} [VENV-DIR]

Activate a Python virtual environment in the specified directory. If no
directory is provided, first looks under the current directory for a
directory named .venv, if there is no virtualenv located there, checks
if there is a virtualenv managed by a Python dependency manager in the
current dir or any of its parent dirs and activates it if it exists. The
following dependency managers are checked in this order:

  1. uv
  2. poetry
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
        _find_managed_venv() {
            >&2 echo "Not a virtualenv directory: $venv_dir; searching for venv with uv..."
            local uv_venv
            if uv_venv=$(uv run --no-sync --frozen python -c 'import sys; print(sys.prefix) if sys.base_prefix != sys.prefix else sys.exit(1)'); then
                activate="source '$uv_venv/bin/activate'"
                return 0
            fi

            >&2 echo "No uv managed project in dir or parents; trying Poetry..."
            activate=$(poetry env activate) || return 1
        }

        _find_managed_venv || return 1
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
    find "$HOME/Pictures/Screenshots" -maxdepth 1 -iname "screenshot from *" |
    sort --ignore-case --reverse |
    head -n 1'
alias rsync="rsync --verbose --info=progress2"

pydocs() { zeal "python:$*"; }
cppref() { zeal "cpp:$*"; }
cref() { zeal "c:$*"; }

__urlencode() {
    # From https://stackoverflow.com/a/34407620
    printf "%s" "${*}" | jq --slurp --raw-input --raw-output @uri
}

__open_browser() {
    local prefix=$1; shift
    "${BROWSER:-xdg-open}" "${prefix}$(__urlencode "${*}")"
}

google() {
    __open_browser "https://google.com/search?q=" "${*}"
}

gpt() {
    __open_browser "https://chatgpt.com/?q=" "${*}"
}

wiki() {
    __open_browser "https://${WIKI_LANG:-en}.wikipedia.org/wiki/" "${*}"
}

__uv_run() {
    # Separate out --with/-w args
    local with_args=()
    local args=()
    while [[ $# -gt 0 ]]; do
        arg="$1"; shift
        case "$arg" in
        -w|--with)
            with_args+=( "$arg" "$1" )
            shift
            ;;
        --with=*)
            with_args+=( "$arg" )
            ;;
        --)
            break
            ;;
        *)
            args+=( "$arg" )
        esac
    done

    >&2 echo uv run --frozen "${with_args[@]}" "${args[@]}" "$@"
    uv run --frozen "${with_args[@]}" "${args[@]}" "$@"
}

alias py='__uv_run python3'
alias ipdb='PYTHONBREAKPOINT=ipdb.set_trace __uv_run --with=ipdb ipdb'
alias ipy='PYTHONBREAKPOINT=ipdb.set_trace __uv_run --with=ipdb --with=ipython ipython'

# Run pytest, entering ipdb on errors. Requires pytest to be installed in the
# venv/project.
alias ipytest='
    __uv_run --with ipdb python3 \
    -m pytest \
    --pdb --pdbcls=IPython.terminal.debugger:TerminalPdb'

alias fgit='git -c "interactive.diffFilter=diff-so-fancy --patch" \
                -c "core.pager=diff-so-fancy | less --tabs=4 -RF"'
