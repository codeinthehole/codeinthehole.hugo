---
{
  "aliases": ["/writing/configuring-logging-for-postgresapp"],
  "tags": ["postgres"],
  "date": "2013-01-14",
  "slug": "configuring-logging-for-postgresapp",
  "title": "Configuring logging for Postgres.app",
  "description": "The recommended way of debugging SQL problems",
}
---

### Problem

You're using [Postgres.app](http://postgresapp.com/) on a Mac for local
development but are getting SQL errors from your application. You're seeing an
error message:

```bash
ERROR:  current transaction is aborted, commands ignored until end of
transaction block
```

This isn't useful: you want to know which query is generating the error.

### Solution

Turn on Postgres logging and watch the log files when the error is generated.

This is done by editing the `postgresql.conf` config file, whose location can be
found from the "Server Settings" option in the Postgres.app window. It's
normally somewhere like
`~/Library/Application Support/Postgres/var-12/postgresql.conf`.

Edit in these settings:

```ini
# Collect logs printed to STDERR.
log_destination = stderr
logging_collector = on

# Log all statements.
log_statement = all

# Need to use somewhere writable by the Postgres process.
log_directory = '/tmp/'
log_filename = 'postgres.log'
```

then restart Postgres. You can then watch the log file to find out which queries
are failing.

### Discussion

By default, Postgres.app does not have logging enabled which makes local
debugging difficult.
