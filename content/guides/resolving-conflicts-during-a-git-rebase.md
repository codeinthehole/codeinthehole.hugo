+++
title = "Resolving conflicts during a Git rebase"
date = 2020-03-05
description = "Some collected tips from over the years."
tags = ["git"]
+++

<!--
INTRODUCTION

Not really anything new - just an article I can point team members to who are
having problem rebasing.

Broadly steps are:

1. Understand the purpose of YOUR commit that can't be applied (hence the
   conflict)

2. Understand the changes made to each conflicted file from the TARGET BRANCH
   (either just a simple diff or commit-by-commit)

3. Apply your changes carefully

LIT REVIEW
----------

Nothing notable:
- https://clubmate.fi/git-rebasing-workflow-and-resolving-merge-conflicts/
- https://docs.openstack.org/doc-contrib-guide/additional-git-workflow/rebase.html
- https://dev.to/jacqueline/another-conflict-resolving-conflicts-in-git-that-occur-when-using-rebase-3dho
- https://guides.codechewing.com/git/rebase-merge-conflicts

http://gitforteams.com/resources/rebasing.html
- A walkthrough of the conflict resolution journey

-->

Resolving conflicts from a Git rebase can be tricky. But don't worry -- here's a
comprehensive guide to how to resolve them.

There's three phases:

1. [Which commit of mine is conflicting?](#which-commit-of-mine-is-conflicting)
2. [What changes were made in the target branch that conflict with my commit?](http://localhost:1313/tips/resolving-git-conflicts/#what-changes-were-made-in-the-target-branch-that-conflict-with-my-commit)
3. [Resolve conflicts safely](#resolve-conflicts-safely)

These are accurate as of Git v2.23 and are for resolving conflicts using the
command line.

Let's walk through the process.

## A conflict happens

On your working branch, you run:

```bash
git rebase origin/master
```

and are faced with a wall-of-text:

```txt
Applying: Improve naming around create-import-process end-point
Recorded resolution for 'src/octoenergy/interfaces/apisite/data_import/views.py'.
Applying: Extract serializer creation into own method
Using index info to reconstruct a base tree...
M src/octoenergy/interfaces/apisite/data_import/views.py
Falling back to patching base and 3-way merge...
Auto-merging src/octoenergy/interfaces/apisite/data_import/views.py
Applying: Group tests into classes for Account data-import serializer
Using index info to reconstruct a base tree...
M src/tests/unit/common/domain/data_import/validation/test_accounts.py
Falling back to patching base and 3-way merge...
Auto-merging src/tests/unit/common/domain/data_import/validation/test_accounts.py
CONFLICT (content): Merge conflict in src/tests/unit/common/domain/data_import/validation/test_accounts.py
Recorded preimage for 'src/tests/unit/common/domain/data_import/validation/test_accounts.py'
error: Failed to merge in the changes.
Patch failed at 0003 Group tests into classes for Account data-import serializer
hint: Use 'git am --show-current-patch' to see the failed patch
Resolve all conflicts manually, mark them as resolved with
"git add/rm <conflicted_files>", then run "git rebase --continue".
You can instead skip this commit: run "git rebase --skip".
To abort and get back to the state before "git rebase", run "git rebase --abort".
```

Conflicts? Conflicts!

Often the conflicts are simple and easily resolved by eye-balling the files in
question. If that's true, good for you: resolve the conflicts using your
favourite editor and move on via:

```bash
git rebase --continue
```

However, if the conflicts are not trivially resolved, start by asking yourself
this:

## Which commit of mine is conflicting?

We can identify the conflicting commit in several ways:

- Look for the `Patch failed at $NUMBER $SUBJECT` line in the rebase output.
  This prints the subject of the commit that couldn't be applied. In the above
  example, the offending commit has subject
  `Group tests into class for Account data-import serializer`.

- Alternatively, follow the advice in the rebase output and run:

  ```bash
  git am --show-current-patch
  ```

  which is equivalent to running `git show` on the conflicting commit.

- As of Git v2.17, this option can be used with `git rebase` too:

  ```bash
  git rebase --show-current-patch
  ```

- Best of all, there is a `REBASE_HEAD` pseudo-ref that points to the
  conflicting commit, so you can do:

  ```bash
  git show REBASE_HEAD
  ```

  to view the commit, or:

  ```bash
  git rev-parse REBASE_HEAD
  ```

  to see the commit SHA.

It can be useful to open the Github detail page for the offending commit to
allow a quick glance at the diff in another window. If you use `hub` (and
Github), this can done with:

```bash
hub browse -- commit/$(git rev-parse REBASE_HEAD)
```

which, if you find it useful, could be alised as:

```ini
[alias]
openconflict = "!f() { hub browse -- commit/$(git rev-parse REBASE_HEAD); }; f"
```

in `~/.gitconfig`.

Now for the trickier question.

## What changes were made in the target branch that conflict with my commit?

<!--

Should it be default? Probably, yes.
https://stackoverflow.com/questions/27417656/should-diff3-be-default-conflictstyle-on-git

http://psung.blogspot.com/2011/02/reducing-merge-headaches-git-meets.html
Another recommendation for diff3 - also recommends enabling rerere with
$ git config --global rerere.enabled 1
to auto apply previous resolutions.

https://blog.nilbus.com/take-the-pain-out-of-git-conflict-resolution-use-diff3/
Good example/explanation

Sometimes hard to determine if a rename is involved.

-->

We understand what _we_ were trying to do, but we need to understand what
changes were made in the target branch that conflict. Two tips:

### Use the `diff3` format to see common ancestor code in conflict blocks

Globally enable this with:

```bash
git config --global merge.conflictstyle diff3
```

and then conflict blocks will be formatted like:

```diff
<<<<<<<< HEAD:path/to/file
content from target branch
|||||||| merged common ancestors:path/to/file
common ancestor content
========
content from your working branch
>>>>>>> Commit message:path/to/file
```

where the default conflict block has been extended with a new section, delimited
by `||||||||` and `========`, which reveals the _common ancestor code_.

Comparing the `HEAD` block to the common ancestor block will often reveal the
nature of the target-branch changes, allowing a straight-forward resolution.

For instance, breath easy if the common ancestor block is empty:

```diff
<<<<<<<< HEAD:path/to/file
content from target branch
|||||||| merged common ancestors:path/to/file
========
content from your working branch
>>>>>>> Commit message:path/to/file
```

as this means both branches have added lines; they haven't tried to update the
same lines. You can simply delete the merge conflict markers to resolve.

If eyeballing the conflicts is not sufficient to safely resolve, we need to dig
deeper.

### Examine the target branch changes in detail

Sometimes the conflicted blocks are large and you can't understand at a glance
what changes have been made in the target branch and why they were made. In this
situation, we may need to examine the individual changes made to each conflicted
`$FILEPATH` in order to understand how to resolve safely.

We can examine the overall diff:

```bash
git diff REBASE_HEAD...origin/master $FILEPATH
```

<!--

We can determine the "onto" value dynamically from .git/rebase-apply/onto

-->

or list the commits from the target branch that updated `$FILEPATH`:

```bash
git log REBASE_HEAD..origin/master $FILEPATH
```

and review how each modified `$FILEPATH` with:

```bash
git show $COMMIT_SHA -- $FILEPATH
```

Note the `git diff` command uses three dots while the `git log` command uses
two.

If there are lots of commits that modified `$FILEPATH`, it can be helpful to run
`git blame` and see which commits updated the conflicting block and focus your
attention on those.

This should provide enough information to understand the changes from the target
branch so you can resolve the conflicts.

## Resolve conflicts safely

A couple of things:

### Apply your changes to the target branch code

When manually editing conflicted files, always resolve conflicts by applying
your changes to the target branch block (labelled `HEAD`) as you understand your
changes better and are less likely to inadvertently break something.

For example: in the following diff:

```diff
<<<<<<<< HEAD
I like apples and pears
|||||||| merged common ancestors
I like apples
========
I love apples
>>>>>>> branch-a
```

Apply your change (replacing "like" with "love") to the `HEAD` block to give:

```diff
<<<<<<<< HEAD
I love apples and pears
|||||||| merged common ancestors
I like apples
========
I love apples
>>>>>>> working-branch
```

then remove the superseded lines and merge conflict markers to give:

```diff
I love apples and pears
```

### Wholesale accept changes

<!-- Refs:

https://til.hashrocket.com/posts/ce7bff8134-accept-your-own-changes-during-git-rebase
- Gets the ours/theirs thing the wrong way round!

https://demisx.github.io/git/rebase/2015/07/02/git-rebase-keep-my-branch-changes.html
- Talks about `git rebase -Xtheirs`

-->

Occasionally, you might know that the changes from one branch should be
accepted. This can be done using `git checkout` with a merge "strategy-option".
Beware that, when rebasing, the terminology is counter-intuitive.

To accept the changes from the _target branch_, use:

```bash
git checkout --ours -- $FILEPATH
```

To accept the changes made on your _working branch_, use:

```bash
git checkout --theirs -- $FILEPATH
```

As a rebase involves replaying your commits to the tip of the target branch,
each replayed commit is treated as "theirs" (even though you are the author)
while the existing target branch commits are "ours".

Even more sweepingly, you can auto-resolve conflicts using a specified strategy
when doing the rebase. Eg:

```bash
git rebase -Xtheirs origin/master
```

I've never used this much in practice though.

### Re-use recorded resolutions (aka `rerere`)

<!--
https://medium.com/@porteneuve/fix-conflicts-only-once-with-git-rerere-7d116b2cec67
- Good article

https://stackoverflow.com/questions/49500943/what-is-git-rerere-and-how-does-it-work
- Decent explanation here.

Records the conflicted diff hunks
Record resolution
-->

If you set:

```bash
git config --global rerere.enabled 1
```

then Git will record how you resolve conflicts and, if it sees the same conflict
during a future rebase (eg if you `--abort` then retry), it will automatically
resolve the conflict for you.

You can see evidence of `rerere` in action in the `git rebase` output. You'll
see:

```bash
Recorded preimage for '...'
```

when Git detects a conflicted file, then:

```bash
Recorded resolution for '...'
```

when Git records the resolution (to `.git/rr-cache/`), and finally:

```bash
Resolved '...' using previous resolution.
```

when Git re-uses the saved resolution.

You should enable this -- there's no downside.

## Summary

Hopefully the above is useful.

Resolving rebase conflicts is much easier if commits are "atomic", with each
change motivated by a single reason (similar to the
[Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle)).
For instance, never mix file-system changes (ie moving files around) with core
logic changes. Such commits are likely to attract conflicts and are hard to
resolve.

Don't worry if the rebase gets away from you; you can always abort with:

```bash
git rebase --abort
```

if things become too hairy.

## Further reading

Here's some additional resources on the topic:

- [Github: Resolving merge conflicts after a Git rebase](https://help.github.com/en/github/using-git/resolving-merge-conflicts-after-a-git-rebase)

- [`git-rebase` docs](https://git-scm.com/docs/git-rebase)

- [Fix conflicts once with git rerere](https://medium.com/@porteneuve/fix-conflicts-only-once-with-git-rerere-7d116b2cec67)
  by _Christophe Porteneuve_ (2014). Good detailed examination of how to use
  `git rerere`.

<!-- General research on rebase conflicts

Note on rebase options:

[rebase]
    instructionFormat = %s [%an]
	autosquash = true
    stat = true

Quite hard to generate a GH diff view for a single file
https://stackoverflow.com/questions/14500240/how-can-i-generate-a-diff-for-a-single-file-between-two-branches-in-github

Sometimes diff block and hard to see what difference is:

What changes happened to that file on master?

Which commit removed it?
gh aqs/cleanup-p1..origin/master -- octoenergy/domain/accounts/affexit.py
Note two dots

Conflict happens while trying to apply a commit/patch
-->
