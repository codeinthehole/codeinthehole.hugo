---
{
  "aliases": ["/writing/a-useful-template-for-commit-messages"],
  "slug": "a-useful-template-for-commit-messages",
  "tags": ["git"],
  "date": "2015-10-02",
  "title": "A useful template for commit messages",
  "description": "A simple heuristic for preferring the imperative mood",
}
---

Here's a useful heuristic for writing better commit messages. Set your commit
message template to:

```dosini
# If applied, this commit will...

# Why is this change needed?
Prior to this change,

# How does it address the issue?
This change

# Provide links to any relevant tickets, articles or other resources
```

and you'll be guided into writing concise commit subjects in the imperative mood
— a good practice.

See rule 5 of Chris Beam's
["How to write a commit message"](http://chris.beams.io/posts/git-commit/) for
the inspiration of this tip and more reasoning on the use of the imperative
mood.

To do this in Git, save the above content in a file (eg `~/.git_commit_msg.txt`)
and run:

```bash
git config --global commit.template ~/.git_commit_msg.txt
```

Here's what this looks like in practice:

<img src="/images/git-commit-snap.png" width="800px" alt="Screenshot of git message editor" />

Try it! It's genuinely useful.
