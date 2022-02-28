+++
title = "Software development tips – part 1"
date = 2020-02-26T10:04:16Z
description = "Topics: development, tools and effective teams."
tags = ["productivity", "vim", "teams", "tools"]
+++

On software development:

- Everything you create that has a name lives in a namespace. Remember this.
  Ensure the names you pick are unique and unambiguous within their namespace.

- If a `500 Internal Server Error` HTTP response can be induced from your web
  app through a carefully crafted request, it needs fixing. Don't assume
  anything about the incoming request.

On tools:

- Using [Alfred](https://www.alfredapp.com/) with a well-stocked cupboard of
  Chrome bookmarks is a _massive_ productivity win. Stop wasting time in
  Chrome's address bar.

- Use [ripgrep](https://github.com/BurntSushi/ripgrep) for search (and
  `set grepprg=rg\ --vimgrep\ --smart-case` in `~/.vimrc` too).

- Use [fzf](https://github.com/junegunn/fzf) for fuzzy finding, especially via
  the [`junegunn/fzf.vim`](https://github.com/junegunn/fzf.vim) Vim plugin.

- [onetimesecret.com](https://onetimesecret.com/) is useful for securely sharing
  secrets.

On effective development teams:

- Document your work coding conventions so you can refer to them in code-review.
  You'll need this a lot when onboarding new starters. Octopus Energy's
  [open-source coding conventions](https://github.com/octoenergy/conventions/blob/master/python.md)
  have been a great recruiting tool.

More to come.
