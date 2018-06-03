+++
date = "2018-06-03T12:30:05+01:00"
title = "The perfect pull request"
tags = ["github", "git"]
description = "Working notes based on reviewing several thousand pull requests."
+++

<!-- Abstract -->

I spend most of my day reviewing pull requests in Github. These are my working
notes on what makes a good PR.

### Explain why you did what you did

<!-- Title/description -->

It should be clear to the reviewer what change is being made and, crucially,
why. So choose a good PR title and use the description to detail the motivation for a change.
Consider including:

- Screenshots, such as snaps of a new UI or graphs of the devastating performance improvement your PR delivers.

- Deployment notes. For example, flagging up database schema changes or new
  configuration that need careful handling when rolling out to production.

- Links to relevant resources like a ticket in an issue tracker or influential blog post.

<!-- Commits -->

### Tell a cogent story

Commits should be "atomic" as described by the (excellent) [QT Commit Policy](https://wiki.qt.io/Commit_Policy):

> Make atomic commits.
>
> That means that each commit should contain exactly one
> self-contained change - do not mix unrelated changes, and do not create
> inconsistent states.

A failing test suite is an example of an "inconsistent state". Keep it green
after every commit.

> Never "hide" unrelated fixes in bigger commits.

Also, don't push small "fix" commits with messages like:

- "Fix tests"
- "Linting"
- "Address PR comments"

It's sloppy. Use interactive rebasing to squash these into your history and to
generally massage your commits into shape before submitting for review.
It's fine to force-push if you're the only one working on a branch.

Obviously, write descriptive commit messages - adopt [Tim Pope's advice](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) if you
haven't already. Remember, future maintainers (probably you)  will always want to know _why_ a
change was made. Don't leave them in the dark.

Atomic, descriptive commits mean the PR can be reviewed chronologically, _commit-by-commit_.
This is the ideal.

### Follow the boy-scout rule

> "Leave things BETTER than you found them." -- Robert Baden Powell

Codebases degrade over time; entropy increases. Thoughtful developers will look
for opportunities to refactor or restructure components as they work, keeping
the codebase clean.

A useful practice for this is to _begin_ your PR by refactoring or restructuring
the codebase to make it _easy_ to add the core functionality of your PR. For
example, start by reviewing the tests for a component you're about to extend,
adjusting them to be as readable as possible.

### Make the reviewer's life easy

Don't waste the reviewer's time: before marking a PR for review:

- Ensure the CI test suite is green.
- Review the PR diff carefully; ensure you haven't committed all of `node_modules` again.

Consider adding "reviewing notes". These might highlight:

- New functionality that the rest of the team should be aware of.
- Critical business logic that needs vigilant review by several pairs
  of eyeballs.

Beware of adding reviewing notes that should be code comments or in commit
messages.

### Summary

I hope the above advice is useful, the "cogent story" part is the most
pertinent. Notes on what makes a good PR _reviewer_ to come later.
