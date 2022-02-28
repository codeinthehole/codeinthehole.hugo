+++
title = "Using black and isort with Vim"
date = 2019-03-08T09:22:04Z
description = "The simplest way to run both in a project."
tags = ["vim"]
+++

FYI, the easiest way to get Vim to automatically run
[black](https://github.com/ambv/black) and
[isort](https://github.com/timothycrosley/isort) over a Python buffer when
saving is to use [Ale](https://github.com/w0rp/ale)'s
[fixer](https://github.com/w0rp/ale#2ii-fixing) functionality.

```vim
" In ~/.vim/after/ftplugin/python.vim (or somewhere like that)
let b:ale_fixers = ['black', 'isort']
let b:ale_fix_on_save = 1
```

If you're only using black/isort in a subset of your projects, you can enable
the `b:ale_fix_on_save` setting conditionally:

```vim
let b:ale_fix_on_save = 0
let filepath = expand('%:p:h')
if match(filepath, 'some-project-name') != -1
    let b:ale_fix_on_save = 1
endif
```

Further, if you don't want these fixers applied on save, set

```vim
let b:ale_fix_on_save = 0
```

and use `:ALEFix` to run the fixers manually.
