---
{
  "aliases": ["/writing/pypi-readme-badges"],
  "description": "Shiny badges using crate.io",
  "slug": "pypi-readme-badges",
  "title": "PyPI README badges",
  "tags": ["python"],
  "date": "2013-05-03",
}
---

Thanks to [@kuramanga](https://twitter.com/kuramanga), it's now possible to add
shiny PyPi badges to your Python project READMEs that indicate the latest
released version on PyPI and the total number of downloads.

[![django-oscar PyPi badges](/images/screenshots/oscar-pypi-badges.png)](https://github.com/tangentlabs/django-oscar)

This screenshot is taken from
[django-oscar](https://github.com/tangentlabs/django-oscar)'s README.

Embed these badges in your own repo as Restructured text:

```rst
.. image:: https://pypip.in/v/$REPO/badge.png
    :target: https://crate.io/packages/$REPO/
    :alt: Latest PyPI version

.. image:: https://pypip.in/d/$REPO/badge.png
    :target: https://crate.io/packages/$REPO/
    :alt: Number of PyPI downloads
```

or Markdown:

```markdown
[![PyPi version](https://pypip.in/v/$REPO/badge.png)](https://crate.io/packages/$REPO/)
[![PyPi downloads](https://pypip.in/d/$REPO/badge.png)](https://crate.io/packages/$REPO/)
```

The [code is available on Github](https://github.com/kura/pypipins), see also
Olivier Lacan's [shields](https://github.com/olivierlacan/shields) repo.
