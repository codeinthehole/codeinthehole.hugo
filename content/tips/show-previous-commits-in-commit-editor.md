---
{
  "aliases": ["/writing/enhancing-your-git-commit-editor"],
  "slug": "enhancing-your-git-commit-editor",
  "title": "Enhancing your Git commit editor",
  "description": "Commit message pedantry taken to a new level",
  "tags": ["git"],
  "date": "2013-08-08",
}
---

Confession: I am a pedant, especially around commit messages.

I often find myself writing very similar commit messages (like "Bump version to
0.4.3") and want to ensure I use the same wording each time. Thanks to
[@LuRsT](https://twitter.com/LuRsT), I learnt how to employ Git's
[prepare-commit-msg](http://git-scm.com/book/en/Customizing-Git-Git-Hooks#Client-Side-Hooks)
hook to display the last 5 commit messages when I'm editing a commit message.

Use the following `.git/hooks/prepare-commit-msg` hook:

```bash
#!/bin/sh

NUM_COMMITS=5
FORMAT="# %h %s [%an]"
COMMITS="$(git log --pretty="${FORMAT}" -${NUM_COMMITS})"
HEADER="#
# Last ${NUM_COMMITS} commits
# ----------------------"

recent_commits() {
    echo "${HEADER}"
    echo "${COMMITS}"
}

COMMIT_FILE=$1
SOURCE=$2
SHA=$3

case "$SOURCE" in
merge|squash|message)
    ;;
""|commit|template)
    if [ -z "$SHA" ]; then
        recent_commits >> $COMMIT_FILE
    fi
    ;;
*)
    echo "Unexpected type '$SOURCE' in prepare-commit-msg hook" >&2
    exit 1
esac
```

then your default commit template looks like this:

![image](/images/screenshots/git-commit-editor.png)
