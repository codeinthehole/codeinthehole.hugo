---
{
  "aliases": ["/writing/rewriting-codeintheholecom"],
  "title": "Rewriting codeinthehole.com",
  "tags": ["django"],
  "date": "2012-01-06",
  "description": "Yet another RST blog",
  "slug": "rewriting-codeintheholecom",
}
---

I rewrote this blog recently with the following aims:

- to make it as easy as possible to create a new article, using
  [reStructuredText](http://docutils.sourceforge.net/rst.html) (RST);
- to clean up and simplify the design, focussing on the readability of articles
  that include code snippets.

I knew that there were various static blogs out there, with many supporting RST,
but I still fancied the challenge of crafting something specific to my needs.
There's nothing wrong with wheel re-invention if you want to learn about wheels.

This article is a short summary.

### Technology

Django, Fabric and pygments - the
[source is on github](http://github.com/codeinthehole/codeinthehole.com). I
intend to pull out the generic blogging code into a separate library,
reStructuredBlog, at some point, hence the "rsb" acronym used in the codebase.

### Writing a post

My ideal for writing a blog post is:

1. Use vim to create a `.rst` file for the article;
2. Preview the article locally;
3. Publish to the remote server

This translates to:

#### Write

```bash
vim posts/my-new-article.rst
```

#### Preview

```bash
./manage.py rsb_article posts/my-new-article.rst
./manage.py runserver
```

This converts the RST file into a instance of `rsb.models.Article`, plucking out
the title, subtitle and any tags in the process.

Rinse and repeat the write and preview steps until happy.

#### Publish

```bash
fab prod publish posts/0036-my-new-article.rst
```

This copies the RST file up to the remote server and re-runs the `rsb_article`
management command to create the article in the production database.

### Design

<img src="/images/bookcovers/9781119998952.jpg" class="align-right" alt="Book cover" />

I recently read the excellent "Design for Hackers" by David Kadavy. Duly
inspired, I attempted to rework the design to be clean and pleasing on the eye.
The color scheme is deliberately kept simple; the fonts used are Verdana,
[Droid Serif](http://www.google.com/webfonts/specimen/Droid+Serif) and
[Inconsolata](http://www.google.com/webfonts/specimen/Inconsolata).

I was also influenced by the clean look of the personal sites of
[Steve Losh](http://stevelosh.com/), [Zach Holman](http://zachholman.com/) and
[Armin Ronacher](http://lucumr.pocoo.org/).

### Overall

I'm pleased that:

- The site isn't painfully ugly like the old;
- I can write articles easily and using my favourite tools (vim + RST);
- I can write articles on the tube on the way home;
- Github is now my backup of both code and content. For instance, you can
  [view the source of this article](https://raw.github.com/codeinthehole/codeinthehole.com/master/www/posts/0038-restructured-blog.rst).

Since I switched to Disqus for comments, I decided to drop all the old ones (not
that were that many), since I wasn't sure it was possible to migrate Apologies
to the comment authors.
