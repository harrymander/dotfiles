#!/bin/bash

mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle
curl -fLo $HOME/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
curl -fLo $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

ln -sf $(dirname -- $(realpath -- ${BASH_SOURCE[0]}))/vimrc $HOME/.vim
echo 'runtime vimrc' > $HOME/.vimrc

vim +PlugInstall +qall
