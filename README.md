# codeinthehole.com

This repo contains the source for <https://codeinthehole.com>, a Hugo-powered
blog.

## Local development

### Install

Clone this repo, then clone the repo that contains compiled static files into
the `public` folder:

```sh
git clone https://github.com/codeinthehole/codeinthehole.hugo.git blog
cd blog
git clone https://github.com/codeinthehole/codeinthehole.github.io public
```

Install Hugo via HomeBrew:

```sh
brew install hugo
```

Last time I checked, I was using Hugo v0.100.

Check everything is working by running a local HTTP server with `make run`.

### Linting

The `makefile` contains targets for linting markdown files with `markdownlint`
and `prettier`:

```sh
make lint
```

### Create a blog post

Use something like:

```sh
hugo new news/some-article-name.md
```

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

```toml
+++
title = "My new page"
type = "info"
hidefromhome = true
+++
```

## Deploy

From `master`, run:

```sh
make deploy
```

This builds and commits the HTML files into `public/` which is part of a
[separate repository](https://github.com/codeinthehole/codeinthehole.github.io).
