#!/bin/bash

if [ -d "$HOME/.vim" ] || [ -f "$HOME/.vimrc" ]; then
    read -rp ".vim directory and/or .vimrc exist, overwrite? [Y/n]" yn
    case $yn in
        [Yy]*) ;;
        *) echo "Aborted."; exit;;
    esac
fi

mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle"
curl -fLo "$HOME/.vim/autoload/plug.vim" "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
curl -fLo "$HOME/.vim/autoload/pathogen.vim" "https://tpo.pe/pathogen.vim"

ln -sf "$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")/vimrc" "$HOME/.vim"
echo 'runtime vimrc' > "$HOME/.vimrc"

vim +PlugInstall +qall
