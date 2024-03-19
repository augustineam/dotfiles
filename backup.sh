#!/bin/bash


echo 'Copying dotfiles from ~/ to ./dotfiles'

pushd ./dotfiles

find ./ -type f -exec cp -vf ~/{} {} \;

popd

pacman -Qenq > pkgs/native
pacman -Qemq > pkgs/foreign
