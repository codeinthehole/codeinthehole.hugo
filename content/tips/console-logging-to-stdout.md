---
{
  "aliases": ["/writing/console-logging-to-stdout-in-django"],
  "tags": ["django", "python"],
  "slug": "console-logging-to-stdout-in-django",
  "date": "2011-08-16",
  "title": "Console logging to STDOUT in Django",
  "description": "Undocumented option required to avoid STDERR",
}
---

### Problem

By default in Python (and Django), the documented console handler emits to
STDERR, but you want it to use STDOUT instead. This is often desired for
management commands that run as cronjobs.

### Solution

For Python 2.6, use the following LOGGING config in your settings to specify a
different output stream:

```python
import sys
LOGGING = {
    'handlers': {
        'console':{
            'level':'INFO',
            'class':'logging.StreamHandler',
            'strm': sys.stdout
        },
        ...
    }
}
```

For Python 2.7+, the keyword argument to the constructor of
`logging.StreamHandler` is `stream` rather than `strm`. Ensure you use the right
version.

### Discussion

[Django's logging docs](https://docs.djangoproject.com/en/dev/topics/logging/#an-example)
detail the following logging configuration for a console handler:

```python
LOGGING = {
    ...
    'handlers': {
        'console':{
            'level':'DEBUG',
            'class':'logging.StreamHandler',
            'formatter': 'simple'
        },
    },
    ...
}
```

however, the default output stream for `logging.StreamHandler` is STDERR. The
extra keyword argument in the solution alter this behaviour to use STDOUT.

Logging to STDERR means that any output from cron jobs is emailed to root. A
more desirable behaviour is for only genuine errors to trigger emails, while
normal output can be logged to file. Hence, a sensible cronjob file would look
something like:

```bash
SHELL=/bin/bash
MAILTO=alerts.someproject@yourcompany.co.uk

*/10 * * * * app source /venv/bin/activate && /app/manage.py do_something > /dev/null
```
