+++
title = "OpenAI Git poetry"
date = 2022-11-11T22:07:17Z
description = "Using GPT3 to generate poems from your Git history."
tags = ["OpenAI", "Git"]
+++

OpenAI provides [a REST API][openai_api_docs] where you can generate prompt
completions. Here's a minimal example where a JSON payload is piped into
`httpie`:

[openai_api_docs]: https://beta.openai.com/docs/api-reference/introduction

```sh
$ export OPENAI_API_KEY="..."   # fill in your API key here
$ echo '{"model": "text-davinci-002", "prompt": "Write a poem about cheese"}' \
    | http https://api.openai.com/v1/completions Authorization:"Bearer $OPENAI_API_KEY" \
    | jq -r '.choices[0].text

There's nothing quite like cheese
It's rich, creamy, and delicious.
```

Quite.

We can extend this by dynamically building the prompt string. For example, let's
generate a poem based on the recent commits of a Git repo.

We can use a prompt of form:

```txt
Write a poem about these commit messages:

$MESSAGES
```

where `$MESSAGES` can be computed by collating some recent commits:

```sh
git log -10 --format="%s%b" --no-merges
```

Putting that together with some additional tuning parameters in the JSON
payload, we get:

```sh
$ jq -n \
    --arg prompt "$(
        echo "Write a haiku about these commits";
        git log -20 --format="%s%b" --no-merges
    )" \
    '{model: "text-davinci-002", temperature: 1, max_tokens: 512, prompt: $prompt}' \
    | http https://api.openai.com/v1/completions Authorization:"Bearer $OPENAI_API_KEY" \
    | jq -r '.choices[0].text'
```

The quality of results varies quite a bit but they are good fun: things like:

```txt
There was once a
young man, quite new to coding
who made some commits
that were, in retrospect, quite bad

"Make registration rejected events
for gaining supplier ctx type only"

"Stop raising errors when we cannot
find a GetAG reference ID"

These commit messages
were not very clear
and caused some confusion
for the other developers

But the young man learned
from his mistakes
and his subsequent commit messages
were much improved
```

It can also generate haikus, raps and all kinds of other things. Have a play
around in your codebase.
