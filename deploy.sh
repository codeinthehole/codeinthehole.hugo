#!/usr/bin/env bash

set -e

# Remove old public folder
rm -rf public/

# Check working tree is clean
if ! git diff-index --quiet HEAD --
then
    echo "Dirty tree - aborting!"
    exit 1
fi

SHA=`git log --pretty=format:'%h' -n 1`
COMMIT_URL="https://github.com/codeinthehole/codeinthehole.hugo/commit/$SHA"
COMMIT_MSG="Built from $COMMIT_URL"

## Build source into public
hugo

# Commit and push
cd public
git add -A
git commit -m "$COMMIT_MSG"
git push --set-upstream origin master

