+++
title = "An LLM TDD loop"
date = 2024-10-06T14:48:50+01:00
description = "Using `llm` and `files-to-prompt` to run a TDD loop."
tags = ["OpenAI", "TDD", "testing", "Python", "Bash"]
+++

<!-- INTRODUCTION -->

This post details a Bash script that runs a TDD loop where an LLM is
iteratively used to write Python application code to make a fixed set of tests pass.

Similar things have been done before[^prior_art]; this script merely
demonstrates that such things can be done simply by stitching together
open-source LLM tools.

### Tooling

The script uses two commands from [Simon Willison](https://github.com/simonw):

- [`llm`] — a command line interface for interacting with Large Language Models
  (LLMs).
- [`files-to-prompt`] — a command to prepare files for input to `llm`.

as well as [`bat`] for syntax highlighting and [`pytest`] for running tests.

[`llm`]: https://github/llm
[`files-to-prompt`]: https://github/files-
[`bat`]: https://github/files-
[`pytest`]: https://github/files-
[automated_tdd_with_llms]: https://medium.com/@benjamin22-314/automating-test-driven-development-with-llms-c05e7a3cdfe1
[arxiv_paper]: https://arxiv.org/pdf/2312.04687

<!-- CONTENT -->

## The script

Run the TDD loop by invoking `tdd.sh` with a test file and the filename
where the corresponding application code will be written.

```sh
./tdd.sh tests.py application.py
```

The algorithm is:

1. Feed the contents of `tests.py` to `llm` to create an initial version of `application.py`.
2. Run the tests in `tests.py` with `pytest` and collect the output into a temporary file.
3. ✅ If tests pass, we're done.
4. ❌ If tests fail, pass the test output back to `llm` and request a new version of
   `application.py` that addresses the failing tests.
5. Repeat steps 2-4 until either the tests pass or a maximum number of
   iterations is reached.

The code for `tdd.sh` is[^gist]:

```bash
#!/usr/bin/env bash
#
# A Bash script to run a TDD loop for building a Python module to
# pass tests.

set -euo pipefail

# How many times to loop.
ATTEMPTS=4

# The system prompt to use when creating the initial version.
INITIAL_PROMPT="
Write a Python module that will make these tests pass
and conforms to the passed conventions"

# The system prompt to use when creating subsequent versions.
RETRY_PROMPT="Tests are failing with this output. Try again."

function main {
    tests_file=$1
    code_file=$2

    # Create a temporary file to hold the test output.
    test_output_file=$(mktemp)

    # Print the tests file.
    printf "Making these tests (in %s) pass\n\n" "$tests_file" >&2
    bat "$tests_file"

    # Create initial version of application file.
    printf "\nGenerating initial version of %s\n\n" "$code_file" >&2
    files-to-prompt "$tests_file" conventions.txt | \
        llm prompt --system "$INITIAL_PROMPT" > "$code_file"

    # Loop until tests pass or we reach the maximum number of attempts.
    for i in $(seq 2 $ATTEMPTS)
    do
        # Print generated code file for review.
        bat "$code_file" >&2

        # Pause - otherwise everything flies past too quickly. It's useful
        # to eyeball the LLM-generated code before you execute it.
        echo >&2
        read -n 1 -s -r -p "Press any key to run tests..." >&2

        # Run tests and capture output.
        if pytest "$tests_file" > "$test_output_file"; then
            # Tests passed - we're done.
            echo "✅ " >&2
            exit 0
        else
            # Tests failed - print test output...
            printf "❌\n\n" >&2
            bat "$test_output_file" >&2

            # ...and create a new version of the application file.
            printf "\nGenerating v%s of %s\n\n" "$i" "$code_file" >&2
            files-to-prompt "$tests_file" conventions.txt "$test_output_file" | \
                llm prompt --continue --system "$RETRY_PROMPT" > "$code_file"
        fi
    done

    # If we get here, then no version passed the tests.
    echo "Failed to make the tests pass after $ATTEMPTS attempts" >&2
    exit 1
}

main "$@"
```

Note the use of a `conventions.txt` file to convince the LLM to return valid
Python output (not wrapped in a Markdown explanation). It has contents:

```txt
Only return executable Python code
Do not return Markdown output
Do not wrap code in triple backticks
Do not return YAML
```

## Example usage

In the these examples, `llm` is configured to use the GPT-4o model.

### Easy

Here's the script output for a straightforward set of tests that are satisfied
by a `sum` function:

![Simple adding function](/images/screenshots/test_add.png)

As you might expect, the LLM model is able to generate code that passes the test
at the first attempt.

### "Impossible"

At the other end of the spectrum, here's the output when passing a seemingly
contradictory set of tests:

![Unholy adding function](/images/screenshots/test_impossible_add.png)

As you can see, the LLM makes the tests pass on the third attempt, converging on a
ridiculous solution. There still needs to be a human involved in the
"refactor" phase of the red-green-refactor cycle.

Still, it's quite impressive in its own right.

[^gist]: Also available in [this Gist][gist_link]

[gist_link]: https://gist.github.com/codeinthehole/d12af317a76b43423b111fd6d508c4fc

## Final thoughts

This is just a fun proof-of-concept; I'm not going to start developing
production code like this any time soon. But it is interesting and poses
questions about what software development might look like in the future.
Will we still care about clean, easy-to-change application code if it passes all
the tests?

Hat-tip to [David Seddon][david_seddon] for suggesting the idea.

[david_seddon]: https://twitter.com/seddonym

<!-- markdownlint-disable MD007 -->

[^prior_art]: Related posts:

    - [Automating test driven development with LLMs][automated_tdd_with_llms]
      — A long Medium post that does a more complete version of this.
      Using an LLM to write the tests then write the passing code.

    - [LLM4TDD: Best Practices for Test Driven Development Using Large Language Models][arxiv_paper]
      — A ArXiv paper exploring this technique of a human writing
      the tests and an LLM writing the application code.

<!-- markdownlint-enable MD007 -->
