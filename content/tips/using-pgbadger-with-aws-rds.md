+++
title = "Using pgbadger with AWS RDS"
date = 2017-08-29T14:08:08+01:00
description = "Two gotchas that I wasted time on."
tags = ["AWS", "postgres"]
+++

There's two non-obvious things to know when starting to use
[pgbadger](http://dalibo.github.io/pgbadger/) with AWS RDS.

First, set:

```ini
log_statement = None
```

Don't set this to _all_ as the
[AWS docs](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html)
suggest.

Further, don't waste your time trying to add a DB parameter to set
`log_line_prefix` to pgbadger's recommended value: it's not possible[^1].
Instead tell pgbadger about the log format that RDS insists on:

```bash
pgbadger -f stderr -p '%t:%r:%u@%d:[%p]:' postgres.log
```

Hope that saves you some time. Note that the `-f stderr` is required for
pgbadger v10 and above[^2]:

[^1]: See <https://forums.aws.amazon.com/thread.jspa?threadID=145342>

[^2]: See <https://github.com/darold/pgbadger/issues/443>
