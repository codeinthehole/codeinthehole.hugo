+++
title = "Explaining"
date = 2021-10-14T16:29:42+01:00
description = "Record your explanations somewhere permanent."
tags = ["writing"]
+++

<!-- INTRODUCTION -->

Someone has asked a question (in Slack or Github) and you're about to write an
explanation. But before you start typing, ask yourself this:

> Is this the best place to answer this question?

Because the place where the question is asked is generally not the best place to
write a detailed answer.

## "Why did you do it that way?"

Imagine you've requested a review on a Github pull request and one of the
reviewers has questioned why something is done the way it is.

Your first inclination might be to reply to the review comment, explaining your
reasoning. But is that the best way to explain?

Wouldn't it be better to rework the code being queried so the answer to the
question is obvious? So that future maintainers won't find themselves asking the
same question.

So open your editor and rework the code to make the question redundant. This
could be through renaming functions and variables, refactoring the
implementation, or by adding improved commentary.

Then your Github reply could be along the lines of:

> I've reworked the code to answer this question — see this fix-up commit.

## This applies everywhere

This introspection is useful wherever you explain. Ask yourself:

- Could an explanation in a comment be captured in code instead?

- Could an explanation in a commit message be captured in comments or in the
  code itself?

- Could an explanation in a pull request description be captured in commit
  messages or code changes?

- Could an explanation in a pull request comment be captured in commit messages
  or code changes?

- Could an explanation in a Slack thread be captured in your documentation?

Always look for a deeper, more permanent place to record explanations, ideally
in the codebase or related documentation. Avoid explaining in ephemeral Slack-
or Github conversation threads which won't be easily discoverable by future
maintainers.

Through doing this, fewer people will feel the need to ask a particular question
and, when they do, you will have ready-made reference for them.

The accumulated compound interest of this practice is huge.
