---
{
  "aliases":
    [
      "/writing/using-pip-and-requirementstxt-to-install-from-the-head-of-a-github-branch",
    ],
  "slug": "using-pip-and-requirementstxt-to-install-from-the-head-of-a-github-branch",
  "description": "Always get the latest version",
  "title": "Using pip and requirements.txt to install from the HEAD of a Github branch",
  "date": "2011-08-20",
  "tags": ["python"],
}
---

### Problem

The python package installer pip can be used to install directly from Github,
like so:

```bash
pip install git+git://github.com/tangentlabs/django-oscar.git#egg=django-oscar
```

This will install from the HEAD of the master branch. However, when you use
`pip freeze` to export your dependencies (usually to a `requirements.txt` file),
pip will fix the reference to a specific commit by including its ID within the
URL:

```bash
$ pip freeze | grep oscar
-e git://github.com/tangentlabs/django-oscar.git@d636b803d98cd1d3edd01821d4fb2a01ce215ee4#egg=django_oscar-dev
```

Hence running `pip install -r requirements.txt` will not pick any commits after
d636b803 until `requirements.txt` is updated.

This isn't always the desired behaviour; in some circumstances, you would prefer
for `pip install -r requirements.txt` to always install the latest version from
Github.

### Solution

Simply delete the commit ID from URL - that is, change:

```bash
-e git://github.com/tangentlabs/django-oscar.git@d636b803d98cd1d3edd01821d4fb2a01ce215ee4#egg=django-oscar
```

to

```bash
-e git://github.com/tangentlabs/django-oscar.git#egg=django-oscar
```

This can be done by hand once you've used

```bash
pip freeze > requirements.txt
```

to create your requirements file, or by using sed:

```bash
pip freeze | sed 's/@[a-z0-9]\+//' > requirements.txt
```

### Discussion

The text between `@` and `#` in the github URL specifies the commit to install
from. Rather than a commit ID, a branch or tag name can be used also. Hence:

```bash
pip install -e git://github.com/tangentlabs/django-oscar.git@0.1#egg=django-oscar
```

will install the `0.1` tag, while:

```bash
pip install -e git://github.com/tangentlabs/django-oscar.git@releases/0.1#egg=django-oscar
```

will install from the HEAD of the `releases/0.1` branch.

For further information, consult the
[requirements file format documentation](http://www.pip-installer.org/en/latest/requirements.html#the-requirements-file-format).
