# codeinthehole.com

This repo contains the source for http://codeinthehole.com, a Hugo-powered blog.

## Installation

Install Hugo from Brew:

    $ brew install hugo

This site is developed using Hugo v0.62.2.

The `makefile` contains targets for running a local server, building the
deployable `public/` folder, building the CSS and viewing the file tree
structure.

## Write a new article

Use something like:

    $ hugo new news/some-article-name.md

where `news` is the "section" of the article. The possible sections are:

- `books`
- `guides`
- `lists`
- `news`
- `projects`
- `talks`
- `tidbits`
- `tips`

## Write a new static page

Create, say, `content/newpage.md` with header:

```
+++ 
title = "My new page"
type = "info"
hidefromhome = true
+++
```

## Deploy

With:

    $ make deploy

This builds and commits the HTML files into `public/` which is part of a
[separate repository](https://github.com/codeinthehole/codeinthehole.github.io).
