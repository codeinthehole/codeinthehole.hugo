+++
date = "2017-03-16T10:30:02Z"
title = "Hugo"
tags = ["hugo"]
description = "Migrating a Django site to Hugo."

+++

I've migrated this site to [Hugo](https://gohugo.io/) so I can host it on Github
pages[^1].

Hugo is a fast and well thought-out static site generator, written in Golang.
It's easy to learn and has some neat features[^2] - the trickiest part is
understanding the difference between various ways pages are organised:
"sections", "types", "taxonomies" etc.

The Vim plugin [vim-markdown](https://github.com/plasticboy/vim-markdown)
provides good support for authoring Hugo posts since it supports
syntax-highlighting for:

- Github-style "fenced" code blocks and
- JSON or TOML front-matter.

Both things that Hugo supports.

Downside: you have to use git submodules to keep the `public` folder of HTML
files in a separate repo.

[^1]:
    Which lets you do neat things like link to the revision history of an
    article -- see below.

[^2]:
    Like footnotes in markdown (thanks to the
    [blackfriday](https://github.com/russross/blackfriday#extensions) library).
