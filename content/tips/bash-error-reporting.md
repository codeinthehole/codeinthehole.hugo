+++
title = "Bash error reporting"
date = 2017-09-30T22:44:03+01:00
description = "Two tips for better debugging of Bash scripts."
tags = ["bash"]
+++

Two tips:

## Fail fast

You probably already know that you can force Bash scripts to exit immediately if
there's an error (that is, if any command exits with a non-zero exit code)
using:

```bash
#!/usr/bin/env bash
set -e
```

but it's even better to use:

```bash
set -eu -o pipefail
```

so that the script:

- exits on an error (`-e`, equivalent to `-o errexit`);
- exits on an undefined variable (`-u`, equivalent to `-o nounset`);
- exits on an error in piped-together commands (`-o pipefail`)[^pgdump].

You can learn more about these built-ins with:

```bash
help set
```

## Fail noisy

Failing fast is all very well but, by default scripts fail silently offering no
debug information.

You can add:

```bash
set -x
```

to print each command before execution but it's easy to add simple error
handling using `trap`:.

```bash
function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR
```

Here we bind the `print_error` function to the `ERR` event and print out an
error message and offending line of the script (extracted using `sed`) to
STDERR.

Note the use of a `<<<` _here string_ and the `caller` built-in to assign the
line and filename of the error.

So running the script:

```bash
#!/usr/bin/env bash
set -eu -o pipefail

function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

false
```

gives:

```bash
$ ./script.sh
An error occurred in line 11 of file ./test.sh:
false
```

There are more sophisticated ways to handle errors in Bash scripts[^othertools]
but this is a concise, simple option to have to hand.

[^pgdump]:
    Without this `pg_dump ... | gzip` would not be treated as an error even if
    `pg_dump` exited with a non-zero exit code.

[^othertools]:
    See the
    [Bash infinity framework](https://invent.life/project/bash-infinity-framework)
    for example.

{{<comment>}} Background reading:

- <https://stelfox.net/blog/2013/11/fail-fast-in-bash-scripts/>
- <https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/>
- [Relevant Stack Overflow question](https://stackoverflow.com/questions/64786/error-handling-in-bash)
  {{</comment>}}
