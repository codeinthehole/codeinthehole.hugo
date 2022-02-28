+++
title = "Joining between date and timestamp fields in Postgres"
date = 2017-11-16T15:50:04Z
description = "A note-to-self on avoiding DST issues when joining between tables."
tags = ["postgres"]
+++

Joining tables on `date` and `timestamp with timezone` fields in
Postgres[^django] needs careful handling because of time zones and
daylight-saving time.

To illustrate, assume we have two tables:

- `t1` which has a field of type `date` and a foreign-key `t2_id` to
- `t2` which has a field of `timestamp with timezone`.

We want to build SQL queries that join between these two tables with additional
date constraints on the join.

Assume the date values in `t1` correspond to the `Europe/London` time zone.

## Join rows where a timestamp value is _within_ the date

```sql
SELECT t1.*
FROM t1
JOIN t2 ON (
    t1.t2_id = t2.id AND
    t1.date_field = (t2.datetime_field AT TIME ZONE 'Europe/London')::DATE
)
```

Here we convert the datetime values to the `Europe/London` time zone before
casting to date.

## Join rows where a timestamp value is equal to midnight of the date

```sql
SELECT t1.*
FROM t1
JOIN t2 ON (
    t1.t2_id = t2.id AND
    t1.date_field::TIMESTAMP = t2.datetime_field AT TIME ZONE 'Europe/London'
)
```

Here we use the fact that
[type-casting](https://www.postgresql.org/docs/9.1/static/sql-expressions.html#SQL-SYNTAX-TYPE-CASTS)
a `date` field with `::TIMESTAMP` converts it to the midnight timestamp of the
date.

[^django]: Which correspond to time-zone-aware `datetime` values in Python.
