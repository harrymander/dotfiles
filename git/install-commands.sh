#!/bin/bash

set -e

THISDIR=$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")

if [ -z "$PREFIX" ]; then
    PREFIX=$HOME/.local
fi

link-git-command() {(
    local target=$PREFIX/bin/$1
    >&2 echo "Creating symlink '$target'"
    ln -sf "$THISDIR/$1" "$target"
)}

mkdir -p "${PREFIX}/bin"
link-git-command git-com
link-git-command git-rebase-commit
link-git-command git-pushall
