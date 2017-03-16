# codeinthehole.com

This repo contains the source for http://codeinthehole.com, a Hugo-powered blog.

## Installation

Install Hugo from Brew:

    $ brew install hugo

This site was developed using Hugo v0.18.1.

The `makefile` contains targets for running a local server, building the
deployable `public/` folder, building the CSS and viewing the file tree
structure.

## Write a new article

Use something like:

    $ hugo new news/some-article-name.md

where `news` is the "section" of the article.

## Deploy

With:

    $ ./deploy.sh

This builds and commits the HTML files into `public/` which is part of a separate
repository.
