#!/bin/sh

read -p 'Enter default git user name: ' username
read -p 'Enter default git email address: ' email

cat > $HOME/.gitconfig << EOF
[user]
	name = ${username}
	email = ${email}
[include]
	path = $(pwd)/$(dirname $0)/gitconfig
EOF
