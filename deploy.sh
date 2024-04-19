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

function main() {
    verify_preconditions

    # Get SHA of current commit.
    SHA=`git log --pretty=format:'%h' -n 1`

    echo "Building site"
    build_site

    echo "Deploying site"
    deploy_site "$SHA"

    echo "Pushing commits"
    git push origin master
}

function verify_preconditions() {
    # Check we're on master 
    if [ "$(git rev-parse --abbrev-ref HEAD)" != "master" ]
    then
        echo "Wrong branch - deploys can only happen on master"
        exit 1
    fi
    
    # Check working tree is clean
    if ! git diff-index --quiet HEAD --
    then
        echo "Dirty tree - ensure all changes are committed before deploying"
        exit 1
    fi

    # Check markdownlint passes
    if ! markdownlint .
    then
        echo "Markdownlint is not passing"
        exit 1
    fi

    # Check Prettier passes
    if ! prettier --check content/ README.md
    then
        echo "Prettier is not passing"
        exit 1
    fi
}

function build_site() {
    # Remove existing site contents to ensure it's a clean build.
    rm -rf public/*

    # Build source into public.
    hugo
}

function deploy_site() {
    local commit_sha="$1"

    # Change dir into embedded repo
    cd public

    # Commit changes to embedded repo.
    git add -A

    local msg=$(commit_message "$commit_sha")
    git commit -m "$msg"

    # Pull just in case there are any upstream changes
    git pull --rebase

    # Push up to Github which will trigger an update to the Github Pages site.
    git push origin master 

    cd ..
}

function commit_message() {
    local commit_sha="$1"
    local commit_url="https://github.com/codeinthehole/codeinthehole.hugo/commit/$commit_sha"
    echo "Built from $commit_url"
}

main
