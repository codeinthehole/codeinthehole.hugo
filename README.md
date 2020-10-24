# codeinthehole.com

This repo contains the source for https://codeinthehole.com, a Hugo-powered blog.

## Local development

### Install

Clone the repo then clone the Github Pages repo that contains compiled static files:

    $ git clone https://github.com/codeinthehole/codeinthehole.hugo.git blog
    $ cd blog
    $ git clone https://github.com/codeinthehole/codeinthehole.github.io public

Install Hugo via HomeBrew:

    $ brew install hugo

Last time I checked, I was using Hugo v0.75.1.

Run the local HTTP server with `make run`.

The `makefile` contains targets for running a local server (`make run`).

### Create a blog post

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

### Create a static page

Create, say, `content/newpage.md` with header:

```
+++ 
title = "My new page"
type = "info"
hidefromhome = true
+++
```

## Deploy

From `master`, run:

    $ make deploy

This builds and commits the HTML files into `public/` which is part of a
[separate repository](https://github.com/codeinthehole/codeinthehole.github.io).
