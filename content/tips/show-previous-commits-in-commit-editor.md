{
    "aliases": ["/writing/enhancing-your-git-commit-editor"],
    "slug": "enhancing-your-git-commit-editor",
    "title": "Enhancing your git commit editor",
    "description": "Commit message pedantry taken to a new level",
    "tags": [
        "git"
    ],
    "date": "2013-08-08"
}

Confession: I am a pedant, especially around commit messages.

I often find myself writing very similar commit messages (like "Bump
version to 0.4.3") and want to ensure I use the same wording each time.
Thanks to [@LuRsT](https://twitter.com/LuRsT), I learnt how to employ
git's
[prepare-commit-msg](http://git-scm.com/book/en/Customizing-Git-Git-Hooks#Client-Side-Hooks)
hook to display the last 5 commit messages when I'm editing a commit
message.

Use the following `.git/hooks/prepare-commit-msg` hook:

``` bash
#!/bin/sh

BRANCH_NAME=$(git branch | grep '*' | sed 's/* //')
if [ $BRANCH_NAME != '(no branch)' ]
then
    echo "#" >> $1
    echo "# Last 5 commit messages" >> $1
    echo "# ----------------------" >> $1
    COMMITS=`git log --pretty=format:"# %h %s [%an]" -5`
    echo "${COMMITS}" >> $1
fi
```

then your default commit template looks like this:

![image](/images/screenshots/git-commit-editor.png)

Note, using `echo "${COMMITS}"` (instead of `echo $COMMITS`) ensures
newlines are preserved (which I learnt in [this Stack Overflow
answer](http://stackoverflow.com/questions/754395/losing-newline-after-assigning-grep-result-to-a-shell-variable)).
Also we don't echo commit messages while rebasing as it has [strange
side-effects](http://gmurphey.com/2013/02/02/ignoring-git-hooks-when-rebasing.html).
