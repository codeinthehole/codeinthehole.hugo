+++
title = "A Vim mapping for opening virtualenv files"
date = 2020-11-16T15:45:30Z
description = "A useful `cnoremap` for Python development."
tags = ["Vim"]
+++

Here's a useful command-mode mapping for Python development:

```vim
" ~/.vim/ftplugin/python.vim

function! VirtualEnvSitePackagesFolder()
    " Try a few candidate Pythons to see which this virtualenv uses.
    for python in ["python3.7", "python3.8", "python3.9"]
        let candidate = $VIRTUAL_ENV . "/lib/" . python
        if isdirectory(candidate)
            return candidate . "/site-packages/"
        endif
    endfor

    return ""
endfunction

cnoremap %v <C-R>=VirtualEnvSitePackagesFolder()<cr>
```

In command-mode, `%v` will expand to the path of your virtualenv's
`site-packages` folder in, which makes it easy to quickly open a third-party
module.

For example, you type:

```txt
:e %v
```

and it expands to:

```txt
:e /Users/jimmy/.virtualenvs/myproject/lib/python3.8/site-packages/
```

from which it's easy to open the third-party module you're interested in.
