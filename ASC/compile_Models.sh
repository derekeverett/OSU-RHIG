#!/bin/bash

module load intel/18.0.0
module load cuda
module load cmake/3.7.2

for dir in ../Models/*/; do
    cd $dir
    sh cleanMake.sh
    cd ../
done

