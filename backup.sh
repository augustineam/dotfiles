#!/bin/bash


echo 'Copying dotfiles from ~/ to ./dotfiles'

pushd ./dotfiles

find ./ -type f -exec cp -avf ~/{} {} \;

popd
