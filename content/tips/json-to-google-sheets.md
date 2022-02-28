+++
date = "2017-05-16T21:52:21+01:00"
title = "Converting JSON into CSV data for Google Sheets"
tags = ["jq", "loggly"]
description = "Another note-to-self on how to use JQ."

+++

Like many people, I use Google Sheets to quickly create and share tabular data.
As well as
[creating spreadsheets by pasting results generated in `psql`](/tips/copying-postgres-output-into-a-spreadsheet/),
I often create reports from JSON files using
[JQ](https://stedolan.github.io/jq/). This post is a note-to-self on how to do
this.

Here's a command to create a tab-separated report from a JSON events file
exported from Loggly:

```bash
$ cat loggly_events.json | \
    jq -r '.events[].event.json |
           select(.params | has("payment_day")) |
           [.timestamp, .account, .params.payment_day] |
           @tsv' | clipboard
```

Note:

- The `-r` option instructs JQ to output raw strings, not quoted JSON strings.

- `@tsv` is a JQ format string for
  [outputting tab-separated values](https://stedolan.github.io/jq/manual/#Formatstringsandescaping).

- The `clipboard` command is an alias for `pbcopy`, the system clipboard on
  OS-X.
