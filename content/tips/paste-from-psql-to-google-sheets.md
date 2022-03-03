---
{
  "aliases": ["/writing/copying-postgres-output-into-a-spreadsheet"],
  "title": "Copying Postgres output into a spreadsheet",
  "slug": "copying-postgres-output-into-a-spreadsheet",
  "description": "Quick tip on tweaking the output of psql",
  "date": "2015-09-02",
  "tags": ["postgres"],
}
---

I often need to grab information from a Postgres database and paste it into a
spreadsheet for sharing with others. Google Sheets needs the pasted data to be
tab-separated in order to be correctly split into columns. This isn't the
default behaviour for psql but here's how to configure psql's output to get it.

At a psql prompt, switch to unaligned output

```postgres
=> \a
```

set the field separator to a tab character:

```postgres
=> \f '\t'
```

and turn the pager off:

```postgres
=> \pset pager off
```

then the output from subsequent `SELECT ...` statements can be cleanly pasted
into your Google Doc.
