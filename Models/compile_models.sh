#!/bin/bash

for dir in */; do
    cd $dir
    git fetch
    git stash
    git pull origin master
    cd ../
done

