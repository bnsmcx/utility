#!/bin/bash

dir=${PWD##*/}
cd ..
zip $dir.zip $dir/*
rm -r $dir
echo "Packed $dir. . . ."
exec zsh 

