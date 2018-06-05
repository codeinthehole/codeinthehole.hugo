#!/usr/bin/env bash
# 
# Deployment script
#
# Deploying involves:
#
# - Building a fresh set of static pages.
# - Committing the modified files to the git submodule with a useful
#   commit message that links back to the commit of the parent repo.
# - Pushing all changes up to Github.

set -eu -o pipefail

# Remove old public folder contents
rm -rf public/*

# Check working tree is clean
if ! git diff-index --quiet HEAD --
then
    echo "Dirty tree - aborting!"
    exit 1
fi

SHA=`git log --pretty=format:'%h' -n 1`
COMMIT_URL="https://github.com/codeinthehole/codeinthehole.hugo/commit/$SHA"
COMMIT_MSG="Built from $COMMIT_URL"

# Build source into public
echo "Building public HTML pages"
hugo
echo

# Commit and push submodule
echo "Committing changes"
cd public
git add -A
git commit -m "$COMMIT_MSG"
git pull --rebase  # just in case a change has been made remotely (like a custom domain tweak)
echo

echo "Pushing changes to Github"
git push origin master 

# Push to main repo
cd -
git push origin master
