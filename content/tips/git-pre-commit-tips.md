---
{
  "aliases": ["/writing/tips-for-using-a-git-pre-commit-hook"],
  "slug": "tips-for-using-a-git-pre-commit-hook",
  "tags": ["git"],
  "description": "Yet another git tips article",
  "date": "2012-03-05",
  "title": "Tips for using a git pre-commit hook",
}
---

Here's a few tips for using a
[Git pre-commit hook](http://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).

### Keep your hook script in source control

Commit your hook script (say `pre-commit.sh`) at the root of your project and
include the installation instructions in your README/documentation to encourage
all developers use it.

Installation is nothing more than:

```bash
ln -s ../../pre-commit.sh .git/hooks/pre-commit
```

Then everyone benefits from running the same set of tests before committing and
updates are picked up automatically.

### Stash unstaged changes before running tests

Ensure that unstaged code isn't tested within your pre-commit script. This is
missed by many sample pre-commit scripts but is easily achieved with
`git stash`:

```bash
# pre-commit.sh
STASH_NAME="pre-commit-$(date +%s)"
git stash save --quiet --keep-index --include-untracked $STASH_NAME

# Test prospective commit
...

STASHES=$(git stash list)
if [[ $STASHES == *"$STASH_NAME" ]]; then
  git stash pop --quiet
fi
```

### Run your test suite before each commit

Obviously.

It's best to have a script (say `run_tests.sh`) that encapsulates the standard
arguments to your test runner so your pre-commit script doesn't fall out of
date. Something like:

```bash
# pre-commit.sh
git stash -q --keep-index
./run_tests.sh
RESULT=$?
git stash pop -q
[ $RESULT -ne 0 ] && exit 1
exit 0
```

where a sample `run_tests.sh` implementation for a Django project may look like:

```python
# run_tests.sh
./manage.py test --settings=settings_test -v 2
```

### Skip the pre-commit hook sometimes

Be aware of the `--no-verify` option to `git commit`. This bypasses the
pre-commit hook when committing, which is useful if you have just manually run
your test suite and don't need to see it run again when committing.

I use git aliases to make this easy:

```bash
# ~/.bash_aliases
alias gc='git commit'
alias gcv='git commit --no-verify'
```

### Search yo.. code for debugging code

At some point, someone will try and commit a file containing

```bash
import pdb; pdb.set_trace()
```

or some other debugging code. This can be easily avoided using the
`pre-commit.sh` file to grep the staged codebase and abort the commit if
forbidden strings are found.

Here's an example that looks for `console.log`:

```bash
FILES_PATTERN='\.(js|coffee)(\..+)?$'
FORBIDDEN='console.log'
git diff --cached --name-only | \
    grep -E $FILES_PATTERN | \
    GREP_COLOR='4;5;37;41' xargs grep --color --with-filename -n $FORBIDDEN && echo 'COMMIT REJECTED Found "$FORBIDDEN" references. Please remove them before committing' && exit 1
```

It's straightforward to extend this code block to search for other terms.
