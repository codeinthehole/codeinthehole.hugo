---
{
  "aliases": ["/writing/a-useful-git-post-checkout-hook-for-python-repos"],
  "description": "Cleaning up after yourself",
  "slug": "a-useful-git-post-checkout-hook-for-python-repos",
  "date": "2013-04-23",
  "title": "A useful Git post-checkout hook for Python repos",
}
---

Every now and again, an innocent python developer checks out a new git branch
then proceeds to bang their head against a bug caused by an orphaned `.pyc` file
from the previous branch. Since `*.pyc` files are typically in the repo's
`.gitignore` file, they are not removed when switching branches and can cause
issues if the corresponding `.py` is removed.

This can be neatly addressed through a 'post checkout' hook which deletes all
such files. Here is such a script, which also removes empty folders and prints a
summary:

```bash
#!/usr/bin/env bash

# Delete .pyc files and empty directories from root of project
cd ./$(git rev-parse --show-cdup)

# Clean-up
find . -name ".DS_Store" -delete

NUM_PYC_FILES=$( find . -name "*.pyc" | wc -l | tr -d ' ' )
if [ $NUM_PYC_FILES -gt 0 ]; then
    find . -name "*.pyc" -delete
    printf "\e[00;31mDeleted $NUM_PYC_FILES .pyc files\e[00m\n"
fi

NUM_EMPTY_DIRS=$( find . -type d -empty | wc -l | tr -d ' ' )
if [ $NUM_EMPTY_DIRS -gt 0 ]; then
    find . -type d -empty -delete
    printf "\e[00;31mDeleted $NUM_EMPTY_DIRS empty directories\e[00m\n"
fi
```

Sample output:

![image](/images/screenshots/post-checkout.png)

Inspiration:

<blockquote class="twitter-tweet"><p>Finally automated. Stop being bitten by residual .pyc files when switching branches in git.
<a
href="http://t.co/JWZOst25Jy"
title="http://stackoverflow.com/questions/1504724/a-git-hook-for-whenever-i-change-branches">stackoverflow.com/questions/1504…</a></p>&mdash;
Maik Hoepfel (@maikhoepfel) <a
href="https://twitter.com/maikhoepfel/status/318437021221806080">March 31,
2013</a></blockquote>

The above version is an extension of the snippets in the referenced
[Stack Overflow question](http://stackoverflow.com/questions/1504724/a-git-hook-for-whenever-i-change-branches).

<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
