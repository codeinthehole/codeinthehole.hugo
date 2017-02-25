#!/usr/bin/env bash

rm -rf content/writing/*

for f in posts/000*.rst
do
    filename=$(basename $f)
    ./convert.sh $f > content/writing/${filename/rst/md}
done
