---
{
  "aliases": ["/writing/the-british-way-of-dealing-with-foreign-apis"],
  "slug": "the-british-way-of-dealing-with-foreign-apis",
  "date": "2011-02-04",
  "tags": ["python"],
  "title": "The British way of dealing with foreign APIs.",
  "description": "A bad joke told in Python",
}
---

A bad joke told in Python:

```python
def call_foreign_api(str):
    try:
        foreign_api(str)
    except NotUnderstoodError:
        foreign_api(str.upper())
```
