---
{
  "aliases":
    ["/writing/coloured-output-while-doing-tdd-with-django-and-fabric"],
  "title": "Coloured output while doing TDD with Django and Fabric",
  "description": "Providing simple coloured feedback",
  "tags": ["python", "testing"],
  "date": "2011-04-20",
  "slug": "coloured-output-while-doing-tdd-with-django-and-fabric",
}
---

I'm a big fan of using PHPUnit with console colours turned on (using the
`--colors` option). Eg:

![image](/images/screenshots/phpunit.jpg)

It helps gets into the natural "red, green, refactor" rhythm.

I'm currently totally immersed in Django, and greatly miss the lack of colour
support within the "test" management command. A simple workaround for this is to
use Fabric with a few modified color commands. Your fabric file should include
the following:

```python
from fabric.colors import _wrap_with

green_bg = _wrap_with('42')
red_bg = _wrap_with('41')

# Set the list of apps to test
env.test_apps = "app1 app2"

def test():
    with settings(warn_only=True):
        result = local('./manage.py test %(test_apps)s --settings=settings_test -v 2 --failfast' % env, capture=False)
    if result.failed:
        print red_bg("Some tests failed")
    else:
        print
        print green_bg("All tests passed - have a banana!")
```

You can choose your own success and failure messages.

Now we have lovely colours while doing TDD in Django:

![image](/images/screenshots/fab.jpg)
