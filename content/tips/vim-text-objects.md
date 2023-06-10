+++
date = "2019-06-13"
title = "Vim text-objects for Python development"
tags = ["vim", "django", "python"]
description = "The nouns of your Vim thought stream."

+++

[Text objects](http://vimdoc.sourceforge.net/htmldoc/motion.html#text-objects),
as in the <span class="keys">iw</span> from <span class="keys">ciw</span>
("change inner word"), form an important part of your Vim mentalese[^verbs].
This post details those that I find most useful for Python and Django
development.

[^verbs]:
    In the sense that you combine them with
    [operators](http://vimdoc.sourceforge.net/htmldoc/motion.html#operator) (eg
    <span class="keys">c</span>, <span class="keys">d</span>,
    <span class="keys">gU</span>) to build describe what you want to do.

For brevity, the leading <span class="keys">a</span> (mnemonic: "a"n) or
<span class="keys">i</span> (mnemonic: "inner"), that you combine with the
following commands to form the full text-object, are omitted.

From core Vim:

- <span class="keys">w</span> → a
  [word](http://vimdoc.sourceforge.net/htmldoc/motion.html#word)
- <span class="keys">W</span> → a
  [WORD](http://vimdoc.sourceforge.net/htmldoc/motion.html#WORD)
- <span class="keys">t</span> → a HTML/XML tag
- <span class="keys">s</span> → a
  [sentence](http://vimdoc.sourceforge.net/htmldoc/motion.html#sentence)
- <span class="keys">p</span> → a
  [paragraph](http://vimdoc.sourceforge.net/htmldoc/motion.html#paragraph)

From the (highly recommended)
[`wellle/targets.vim`](https://github.com/wellle/targets.vim) plugin:

- <span class="keys">,</span> <span class="keys">.</span>
  <span class="keys">;</span> <span class="keys">:</span>
  <span class="keys">+</span> <span class="keys">-</span>
  <span class="keys">=</span> <span class="keys">~</span>
  <span class="keys">\_</span> <span class="keys">\*</span>
  <span class="keys">#</span> <span class="keys">/</span>
  <span class="keys">|</span> <span class="keys">\\</span>
  <span class="keys">&</span> <span class="keys">$</span> → an area of text
  delimited by the given character (super useful).
- <span class="keys">a</span> → a function argument.

Furthermore [`wellle/targets.vim`](https://github.com/wellle/targets.vim)
overrides the built-in text objects to _seek to the next occurrence_ of the
text-object if the cursor isn't already within one. This is useful.

From other language-agnostic, third-party text objects:

- <span class="keys">l</span> → a line (via
  [`kana/vim-textobj-line`](https://github.com/kana/vim-textobj-line))
- <span class="keys">e</span> → the entire buffer (via
  [`kana/vim-textobj-entire`](https://github.com/kana/vim-textobj-entire)) so
  you can, say, indent the entire buffer with <span class="keys">=ae</span>.
- <span class="keys">i</span> → an indented block (via
  [`kana/vim-textobj-indent`](https://github.com/kana/vim-textobj-indent)). This
  isn't quite as useful as it sounds for Python work as it stops at a blank line
  within an indented block -- still worth having to hand.
- <span class="keys">c</span> → a comment block (via
  [`glts/vim-textobj-comment`](https://github.com/glts/vim-textobj-comment)).

[`jeetsukumaran/vim-pythonsense`](https://github.com/jeetsukumaran/vim-pythonsense)
provides some Python text objects:

- <span class="keys">f</span> → a Python function
- <span class="keys">c</span> → a Python class[^clash]
- <span class="keys">d</span> → a Python docstring

For editing Django templates (via
[`mjbrownie/django-template-textobjects`](https://github.com/mjbrownie/django-template-textobjects)):

- <span class="keys">db</span> → a `{% block ... %}...{% endblock %}` block
- <span class="keys">di</span> → a `{% if ... %}...{% endif %}` conditional
  block
- <span class="keys">df</span> → a `{% for ... %}...{% endfor %}` for loop block
- <span class="keys">dv</span> → a `{{ ... }}` variable
- <span class="keys">dt</span> → a `{% tagname ... %}` tag

Several of the above plugins are built using
[`kana/vim-textobj-user`](https://github.com/kana/vim-textobj-user), which
provides a simple framework for building your own text-objects.

Useful references:

- [Cheatsheet for `wellle/targets.vim`](https://github.com/wellle/targets.vim/blob/master/cheatsheet.md)
- [A list of all text-object plugins built with `kana/vim-textobj-user`](https://github.com/kana/vim-textobj-user/wiki)

Related articles:

- [Vim Text Objects: The Definitive Guide](https://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/)
  by _Jared Carroll_ (2011).
- [Vim Killer Features Part 1: Text Objects](http://codyveal.com/posts/vim-killer-features-part-1-text-objects/)
  by _Cody Veal_ (2013).
- [Vim text objects, extend Vim's natural language!](http://owen.cymru/vim-text-objects-extend-vims-natural-language-2/)
  by _Owen Garland_ (2017).

[^clash]:
    To avoid clashing with the comment text-object binding from
    [`glts/vim-textobj-comment`](https://github.com/glts/vim-textobj-comment),
    you can rebind the class text object to, say, <span class="keys">C</span>
    with:

    ```python
    map <buffer> aC <Plug>(PythonsenseOuterClassTextObject)
    map <buffer> iC <Plug>(PythonsenseInnerClassTextObject)
    ```

<!-- Write own one for Python import or arg assign (, and _ delimited)

-->
