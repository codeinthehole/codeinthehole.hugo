+++
date = "2017-06-06T21:30:36+01:00"
title = "Git tips for working with pull requests"
tags = ['git', 'jq']
description = "Using the Github API to quickly jump to a PR detail page."
+++

I spend at least 50% of each day reviewing, amended (and occasionally merging)
pull requests, adding both commits and comments. As such I often want to quickly
jump from a terminal window to the pull request detail page to check previous
comments or add new.

Even with the excellent [hub](https://hub.github.com/) git wrapper, there's no
easy way to do this. I can jump to the pull request _list_ page with:

```bash
git pulls
```

where `pulls` is aliased in `~/.gitconfig` as:

```ini
pulls = !hub browse -- pulls
```

but there's no easy way to jump to the pull request _detail_ page in one
command[^1].

So we use a bash script that makes a HTTP call to the Github API and parses the
response with `jq`. Here's the source to `open-github-pr-page.sh` which just
needs to be somewhere on your path[^2]:

```bash
#!/bin/bash
#
# Open the Github pull request detail page for the current branch
#
# Requires:
#
# - A GITHUB_AUTH_TOKEN env var
# - httpie and jq.

GITHUB_ORG=$(git config --local remote.origin.url | cut -d: -f2 | cut -d/ -f1)
GITHUB_REPO=$(git config --local remote.origin.url | cut -d/ -f2 | cut -d. -f1)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

fetch_pr_detail_url() {
    http https://api.github.com/repos/$GITHUB_ORG/$GITHUB_REPO/pulls \
        head=="$GITHUB_ORG:$BRANCH" \
        Authorization:"token $GITHUB_AUTH_TOKEN" | jq -r '.[].html_url'
}

main() {
    if [ -z "$GITHUB_AUTH_TOKEN" ]; then
        echo "A GITHUB_AUTH_TOKEN env var is required"
        exit 1
    fi

    GITHUB_PULL_URL=$(fetch_pr_detail_url)

    if [ -z "$GITHUB_PULL_URL" ]; then
        echo "No pull request found from branch $BRANCH"
        exit 1
    else
        open "$GITHUB_PULL_URL"
    fi
}

main
```

For this to work, you need to create a personal API token and export it as an
`GITHUB_AUTH_TOKEN` env var in your `~/.bashrc`.

Alias this to something memorable, such as:

```ini
openpr = "!f() { open-github-pr-page.sh; }; f"
```

I would use `git pr` but I've already got that aliased to _create_ a new pull
request:

```ini
pr = !git publish && hub pull-request
```

where

```ini
publish = !git push -u origin $(git branchname)
branchname = !git rev-parse --abbrev-ref HEAD
```

Works a treat.

[^1]:
    Although you can get there with a command _and_ a click using the hub
    command:

    ```bash
    git compare
    ```

    which opens a page with a link to the pull request detail page, if one
    exists.

[^2]: I use `~/Dropbox/bin/` for this kind of thing.
