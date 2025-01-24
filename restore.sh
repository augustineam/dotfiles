#!/bin/zsh


echo 'Copying dotfiles from ./dotfiles to ~/'

pushd ./dotfiles

find ./ -type f -exec cp -vf {} ~/{} \;

popd
