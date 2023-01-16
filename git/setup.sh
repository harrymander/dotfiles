#!/bin/bash

if [ -f "$HOME/.gitconfig" ]; then
	read -rp ".gitconfig already exists, overwrite? [Y/n] " yn
	case $yn in
		[Yy]*) ;;
		*) echo "Aborted."; exit;;
	esac
fi

if [ -z "$PREFIX" ]; then
	PREFIX=/$HOME/.local
fi

read -rp 'Enter default git user name: ' username
read -rp 'Enter default git email address: ' email

cat > "$HOME/.gitconfig" << EOF
[user]
	name = ${username}
	email = ${email}
[include]
    path = $(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")/gitconfig
EOF

set -v
mkdir -p "${PREFIX}/bin"
ln -s "$(realpath "$(dirname "$0")/git-com")" "$PREFIX/bin"
