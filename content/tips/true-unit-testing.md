---
{
  "aliases":
    ["/writing/disable-database-access-when-writing-unit-tests-in-django"],
  "date": "2013-04-22",
  "description": "A decorator for the testing puritan",
  "tags": ["django", "testing", "python"],
  "slug": "disable-database-access-when-writing-unit-tests-in-django",
  "title": "Disable database access when writing unit tests in Django",
}
---

Consider this curio:

```python
import mock
from django.utils.functional import curry

no_database = curry(
    mock.patch, 'django.db.backends.util.CursorWrapper',
    Mock(side_effect=RuntimeError("Using the database is not permitted")))
```

This snippet creates a decorator that can wrap a test case or method and raises
an exception if the database is accessed. This can be useful if you're a puritan
about _true_ unit tests.

Use by wrapping a `TestCase` subclass:

```python
from django.test import TestCase

@no_database()
class UnitTestCase(TestCase):
    ...
```

or method:

```python
from django.test import TestCase

class UnitTestCase(TestCase):

    @no_database()
    def test_something(self):
        ...
```

This snippet is a reformulation of one from Carl Meyer's excellent
['Testing and Django'](http://pyvideo.org/video/699/testing-and-django) (about
24 minutes in).

Challenge: create a similar decorator that prevents all file-system access in a
test method.
