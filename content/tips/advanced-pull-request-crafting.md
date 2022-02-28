+++
date = "2018-06-03T12:30:05+01:00"
title = "Advanced pull-request crafting"
tags = ["github", "git"]
description = "Working notes based on reviewing several thousand pull requests."
aliases = ["/tips/the-perfect-pull-request/"]
+++

<!-- Abstract -->

I spend most of my day reviewing pull requests in Github. These are my working
notes on what makes a good PR.

### Purpose?

<!-- Title/description -->

It should be clear to the reviewer what change is being made and, crucially,
why. So ensure your title and description convey the purpose of the PR. Consider
including:

- Screenshots --- such as snaps or gifs of a new UI, or graphs of the
  devastating performance improvement your PR delivers.

- Deployment notes --- flag up database schema changes or when new configuration
  is needed. No surprises.

This is basic stuff so we won't dwell: consult
[How to write the perfect pull request](https://blog.github.com/2015-01-21-how-to-write-the-perfect-pull-request/)
from the Github blog for more on good descriptions and titles.

<!-- Commits -->

### Tell a cogent story

Commits should be "atomic" as described by the (excellent)
[QT Commit Policy](https://wiki.qt.io/Commit_Policy):

> Make atomic commits.
>
> That means that each commit should contain exactly one self-contained change -
> do not mix unrelated changes, and do not create inconsistent states.

A failing test suite is an example of an "inconsistent state". Keep it green
after every commit.

> Never "hide" unrelated fixes in bigger commits.

Also, don't push small "fix" commits with messages like:

- "Fix tests"
- "Linting"
- "Address PR comments"

Squash these into your history as if they never happened. Future maintainers
aren't interested in the back-and-forth iterations of a PR.

Obviously, write descriptive commit messages - adopt
[Tim Pope's advice](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
if you haven't already. Remember, future maintainers (probably you) will always
want to know _why_ a change was made. Don't leave them in the dark.

It's rare to compose such a clean git history in your first go, so before
submitting a PR, get into the habit of reviewing your commits and using git
rebase to massage it into a cogent story.

Atomic, descriptive commits mean the PR can be reviewed chronologically,
_commit-by-commit_. This is the ideal and a key sign of a developer on top of
their game.

### Follow the boy-scout rule

> "Leave things BETTER than you found them." -- Robert Baden Powell

Codebases degrade over time; entropy increases. Thoughtful developers will look
for opportunities to refactor or restructure components as they work on other
things, keeping the codebase clean.

A useful practice for this is to _begin_ your PR by cleaning up the codebase to
make it _easy_ to address the core purpose of your PR.

For example, start by reviewing the tests for a component you're about to
extend, reworking them to be as readable as possible.

### Make the reviewer's life easy

Don't waste the reviewer's time: before marking a PR for review:

- Ensure the CI test suite is green.
- Review the PR diff carefully; ensure you haven't committed all of
  `node_modules` again.

Consider adding "reviewing notes". These might highlight:

- New functionality that the rest of the team should be aware of.
- Critical business logic that needs vigilant review by several pairs of
  eyeballs.

Just beware of adding notes that should be code comments or within commit
messages.

### Summary

Be diligent about what you submit.
