#!/usr/bin/env bash

rm -rf content/writing/*
mkdir -p content/writing/

# Start with a sample
for f in posts/*.rst
do
    filename=$(basename $f)
    ./convert.sh $f > content/writing/${filename/rst/md}
done
