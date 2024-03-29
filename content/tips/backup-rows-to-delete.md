---
{
  "aliases":
    ["/writing/backing-up-database-rows-in-postgres-before-deleting-them"],
  "slug": "backing-up-database-rows-in-postgres-before-deleting-them",
  "date": "2015-03-19",
  "tags": ["postgres"],
  "title": "Backing up Postgres database rows before deleting them",
  "description": "Quick tip on avoiding accidental data loss",
}
---

> Hmmm, this delete statement is taking longer than I thought it would...

If you ever have to manually run a SQL delete statement in `psql`, you can
back-up the rows you're about to delete:

```postgres
\copy ( select * from $table where id in ( ... ) ) to '/tmp/backup.csv'
```

and, if you've got your filter clause wrong (we've all done it), restore them
with:

```postgres
\copy $table from '/tmp/backup.csv'
```

Moderately useful.
