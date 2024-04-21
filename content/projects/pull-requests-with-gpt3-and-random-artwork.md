+++
title = "Creating pull requests with GPT3 and random artwork"
date = 2022-12-22T21:42:35Z
description = "Using OpenAI and some simple scripting to generate artful pull requests"
tags = ["Github", "OpenAI"]
+++

<!-- INTRODUCTION -->

A friend of mine has been retweeting great paintings from Twitter accounts like
[`@HenryRothwell`][twitter_rothwell], which I've greatly enjoyed. E.g.

{{< tweet user="HenryRothwell" id="1604358648800616448" >}}

[twitter_rothwell]: https://twitter.com/HenryRothwell

In a similar vein, I've started embedding painting images in the description of
every pull request I open. E.g.

![image](/images/screenshots/pull-request-with-painting.png)

<!-- CONTENT -->

I create pull requests with:

```sh
git createpr
```

where `createpr` is an alias to [`hub pull-request`][hub] with pre-populated
options:

```dosini
# ~/.gitconfig

createpr = !hub pull-request --draft --browse --edit
    --message=\"$(pull-request-title)\"
    --message=\"$(pull-request-summary)\"
    --message=\"$(random-picture)\"
```

The pull request body is built by joining the `--message` options separated by a
blank line. Each message component has its own script:

- `pull-request-title` is a [Bash script][gist_pr_title] that uses the OpenAI
  API to summarise the commit messages into a pull request title. I haven't
  quite found the right prompt text to work here — that's a work-in-progress.

- `pull-request-summary` is a simple [Python script][gist_pr_body] that combines
  all the commit messages and removes the hard line wrapping[^1]. The output
  will generally need some editing before it's suitable (hence the `--edit`
  option in the alias) but it's a good starting point.

- `random-picture` is a [Python script][repo_random_picture] that plucks a
  randomly selected image from a set of Twitter accounts and prints the
  appropriate markdown.

This works nicely — the painting images even unfurl elegantly in Slack.

![image](/images/screenshots/slack-unfurl.png)

<!-- Footnotes -->

[^1]:
    Commit messages are hard-wrapped at 72 characters but pull request
    descriptions shouldn't be hard wrapped.

<!-- Links -->

[hub]: https://hub.github.com/
[gist_pr_title]: https://gist.github.com/codeinthehole/d6a496b5a11e7500b7dd0c20f3e5b48c
[gist_pr_body]: https://gist.github.com/codeinthehole/3fc29fc6f1d9e0d9224e97762ff3537a
[repo_random_picture]: https://github.com/codeinthehole/random-picture
