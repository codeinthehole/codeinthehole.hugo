+++
title = "Easy to change"
date = 2018-12-24T11:51:36Z
description = "The overarching principle for writing maintainable code."
tags = ["software"]
+++

I care about writing _maintainable_ software[^octopus]: code that is a pleasure
to work with in the long-term; where new requirements can be accommodated
smoothly and swiftly -- above all, software that is _easy to change_.

Memorise that phrase.

I feel we lose sight of this overarching guiding principle and harm our
codebases by dogmatically pursuing well-intentioned but proximate goals.

The main thing the future maintainer of your code (i.e. you) cares about is
whether the code is easy to change[^easy-to-delete].

### What?

Software has two core values[^clean-architecture]:

- **Behaviour** - What the software does. Working software must behave in a way
  that meets its requirements.

- **Design** - The _structure_ of software; how it is implemented. This will
  dictate how easy or expensive it is to adapt to changing requirements.

Maintainable software not only meets its requirements but is structured to
ensure it is easy to change in the future.

This should be your aim. For each unit of code that you write, ask yourself:

> Will this be easy to change in the future?

From this simple question, every principle, practice and pattern of "good"
software design can be shaken out. Things like:

- Loose coupling.
- Simplicity ([KISS](https://en.wikipedia.org/wiki/KISS_principle),
  [YAGNI](https://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it)).
- Don't Repeat Yourself
  ([DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself))
- Single Responsibility Principle (SRP), polymorphism and the rest of
  [the SOLID principles](https://en.wikipedia.org/wiki/SOLID).
- Accurate naming; readable code.

These are not goals in themselves - they exist to guide you towards your
ultimate destination: writing easy-to-change software.

### A warning

Beware of dogmatically pursuing these intermediate principles and patterns.
Whilst they generally guide you in the right direction, they can be harmful if
applied without thought.

For instance, relentlessly removing all duplication from a component can make it
_harder_ to change for future maintainers, through increased coupling and poor
readability[^test-suites].

### Recap

In short, _maintainable_ code is _easy to change_. This is the overarching
principle that should inform your design decisions.

<!-- Footnotes -->

[^octopus]:
    I work at [Octopus Energy](https://octopus.energy)[^referral], a UK energy
    supplier committed to driving more households to use renewable energy (all
    our tariffs are 100% renewable) and to have a more considered relationship
    with their energy consumption[^agile].

    Climate change is something I care deeply about and I have every intention
    of working for Octopus Energy for a long time. That means working with the
    same codebase for a long time and consequently, "maintainability", ensuring
    the codebase is a pleasure to work with in the long term, is a primary focus
    of mine and the wider software engineering team.

[^clean-architecture]:
    See, for example, _The Clean Architecture_ by Robert C. Martin (page 14
    especially).

[^easy-to-delete]:
    Don't forget: deleting is a form of change. Code that is easy to delete is a
    gift to future maintainers.

[^test-suites]:
    This is commonly seen in test suites, where some duplication of set-up code
    is often preferable to extracting everything.

[^referral]:
    If you're in the position to switch suppliers, check-out our
    [Trust Pilot reviews](https://uk.trustpilot.com/review/octopus.energy) and,
    if convinced, consider using this
    [referral link](https://share.octopus.energy/tulip-fish-149) to switch to us
    which will give you £50 free credit when your supply has switched.

[^agile]:
    See, for example, our [Agile](https://octopus.energy/agile/) tariff which
    uses half-hourly pricing to steer consumption away from the peak hours (of
    4pm to 7pm) which put the most strain on the national grid.
