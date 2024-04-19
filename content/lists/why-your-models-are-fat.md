+++
date = "2017-10-04T10:30:02Z"
title = "Why your Django models are fat"
tags = ["django"]
description = "A tongue-in-cheek list."

+++

Because:

- You moved everything out of the `views.py` modules when you heard fat
  controllers were bad.

- And you've read that fat models are a good idea[^fatmodels].

- You need some extra functionality in a template and this is the easiest way to
  shoehorn it in. Eg:

  ```html
  <p>
    The current balance is {{ account.get_balance_via_three_network_calls_lol }}
  </p>
  ```

- You can quickly solve your current problem by adding _n_ more lines to that
  method (repeat _ad infinitum_)[^srp].

- You're scared people will ignore your crucial wrapper function if it's not
  directly on the model[^scared].

- Are you even allowed to put application logic anywhere but a
  `models.py`?[^permission]

<!-- markdownlint-disable MD007 -->

[^fatmodels]: For example:

    - [Fat Models - A Django Code Organization Strategy](https://hackerfall.com/story/fat-models--a-django-code-organization-strategy)
    - [Django Best Practices: Make 'em Fat](http://django-best-practices.readthedocs.io/en/latest/applications.html#make-em-fat)
    - [Ultimate Django: Adding Business Logic to Models](https://ultimatedjango.com/learn-django/lessons/adding-business-logic-to-models/)
      However, in practice, they're a bad idea (although this sometimes takes a
      few months to become apparent).

<!-- markdownlint-enable MD007 -->

[^scared]:
    A legitimate problem with a liberal language like Python where it's hard to
    enforce calling conventions as nothing is truly private.

[^srp]:
    Requires a poor-quality test suite and diligent ignorance of the
    [Single Responsibility Principle](https://en.wikipedia.org/wiki/Single_responsibility_principle).

[^permission]:
    You are: your web framework is not your boss. As a rule-of-thumb, your
    application logic should live in modules that aren't Django-specific modules
    (eg not in `views.py`, `models.py` or `forms.py`). If I had my way, Django
    would create an empty `business_logic.py` in each new app to encourage this.
