---
{
  "aliases": ["/writing/linking-to-github"],
  "title": "Linking to Github",
  "tags": ["git", "commandlinefu"],
  "date": "2014-07-17",
  "slug": "linking-to-github",
  "description": "Git aliases for grabbing Github links",
}
---

It was rightly
[pointed out yesterday](http://andrew.yurisich.com/work/2014/07/16/dont-link-that-line-number/)
that it's dangerous to link to lines or blocks of code on Github without
explicitly specifying the commit hash in the URL. On this theme, consider this
git command:

```bash
$ git browse -u -- commit/$(git rev-parse HEAD)
https://github.com/tangentlabs/django-oscar/commit/17851d4b66922f8d7e203e2b469040690c84a0db
```

This emits the Github URL to the `HEAD` commit on the current branch, specifying
the commit hash in the URL. Note that the `browse` subcommand is provided by the
excellent [hub](https://hub.github.com/) library.

Pasting links to commits is common, both for mailing list posts and within
discussion on Github itself. Getting the correct URL quickly is useful.

We can streamline further using an alias:

```bash
# ~/.gitconfig

[alias]
url = !hub browse -u -- commit/$(git rev-parse HEAD)
```

so we can run:

```bash
$ git url
https://github.com/tangentlabs/django-oscar/commit/17851d4b66922f8d7e203e2b469040690c84a0db
```

to get the expanded `HEAD` URL. Even better, we can parameterise:

```bash
# ~/.gitconfig

[alias]
url = "!f() { sha=$(git rev-parse ${1:-HEAD}); hub browse -u -- commit/$sha; }; f"
```

so we can now specify a commit:

```bash
$ git url
https://github.com/tangentlabs/django-oscar/commit/17851d4b66922f8d7e203e2b469040690c84a0db

$ git url head
https://github.com/tangentlabs/django-oscar/commit/17851d4b66922f8d7e203e2b469040690c84a0db

$ git url head^
https://github.com/tangentlabs/django-oscar/commit/f49d055befc90897c030e0447a98d512cca4265b
```

Several times a day, I run one of the above, piping the output into the
clipboard for easy pasting:

```bash
$ git url | clipboard
https://github.com/tangentlabs/django-oscar/commit/17851d4b66922f8d7e203e2b469040690c84a0db
```

where:

```bash
# ~/.bashrc

alias clipboard='pbcopy'  # osx clipboard
```

Here's a few more useful git aliases based on the `browse` subcommand:

```bash
# ~/.gitconfig

[alias]
commits = !hub browse -- commits
issues = !hub browse -- issues
wiki = !hub browse -- wiki
settings = !hub browse -- settings
```
