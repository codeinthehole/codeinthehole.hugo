---
{
  "aliases":
    ["/writing/csvfilter-a-python-command-line-tool-for-manipulating-csv-data"],
  "description": "Scratching a CSV itch",
  "date": "2012-04-01",
  "tags": ["python", "commandlinefu"],
  "slug": "csvfilter-a-python-command-line-tool-for-manipulating-csv-data",
  "title": "csvfilter - a Python command-line tool for manipulating CSV data",
}
---

### Problem

You want a unix-like tool for manipulating CSV data from the command-line.

The standard tools `cut` and `awk` aren't always suitable as they don't handle
quoting and escaping which are common in CSVs.

### Solution

Use the CSV manipulation function `csvfilter`, a simple Python library I've put
together.

Install with:

```bash
pip install csvfilter
```

Sample usage:

```bash
# Pluck columns 2, 5 and 6
cat in.csv | csvfilter -f 2,5,6 > out.csv

# Pluck all columns except 4
cat in.csv | csvfilter -f 4 -i > out.csv

# Skip header row
cat in.csv | csvfilter -s 1 > out.csv

# Work with pipe-separated data
cat in.csv | csvfilter -s 1,3 --delimiter="|" > out.csv
```

The above examples show `csvfilter` processing `sys.STDIN` but it can also act
directly on a file:

```bash
csvfilter -f 2,5,6 in.csv  > out.csv
```

Help:

```bash
$ csvfilter --help
Usage: csvfilter [options]

Options:
-h, --help            show this help message and exit
-f FIELDS, --fields=FIELDS
                        Specify which fields to pluck
-s SKIP, --skip=SKIP  Number of rows to skip
-d DELIMITER, --delimiter=DELIMITER
                        Delimiter of incoming CSV data
-i, --inverse         Invert the filter - ie drop the selected fields
--out-delimiter=OUT_DELIMITER
                        Delimiter to use for output
--out-quotechar=OUT_QUOTECHAR
                        Quote character to use for output
```

There is also a simple python API that allows you to add validators to determine
which rows are filtered out:

```python
from csvfilter import Processor

def contains_cheese(row):
    return 'cheese' in row

processor = Processor(fields=[1,2,3])
processor.add_validator(contains_cheese)
generator = processor.process(sys.stdin)

for cheesy_row in generator:
    do_something(cheesy_row)
```

### Discussion

It's possible to do basic CSV manipulation from the command-line using `cut` or
`awk` - for example:

```bash
cat in.csv | cut -d "," -f 0,1,2 > out.csv
```

or :

```bash
cat in.csv | awk 'BEGIN {FS=","} {print $1,$2,$3}' > out.csv
```

However neither `cut` or `awk` make it easy to handle CSVs with escaped
characters - hence the motivation for this tool.

I'm not the first to write such a utility - there are several others out there
(although none had quite the API I was looking for):

- [csvfix](https://bitbucket.org/neilb/csvfix/src)
- [dropcols](http://pypi.python.org/pypi/dropcols)
- [csvkit](https://github.com/onyxfish/csvkit)

[Source available on Github](http://github.com/codeinthehole/csvfilter).
