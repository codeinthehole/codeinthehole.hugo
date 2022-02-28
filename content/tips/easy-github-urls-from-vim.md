+++
title = "Easy Github URLs from Vim"
date = 2020-06-23T15:49:58+01:00
description = "A super-useful Vim mapping for grabbing Github URLs."
tags = ["github", "vim"]
+++

URLs are great aren't they?

You include them in your Slack messages and your co-workers can see _exactly_
what you're talking about in a single click. I wish people would use them more
(and design apps that support them properly).

Anyway, a super-useful Vim mapping I use is:

```vim
vnoremap <leader>gb :GBrowse! master:%<cr>
```

which, after visually selecting a block of code, grabs its Github URL from the
`HEAD` of `master` and copies it to the clipboard. I use this several times
daily.

If you want the URL for the code block from your _current branch_, use:

```vim
:GBrowse!
```

although you have to have pushed your branch for the URL to resolve.

Various other "fugitive-objects" can be passed to `:GBrowse` to open or copy
URLs for other objects -- see the
[help file](https://github.com/tpope/vim-fugitive/blob/27a5c3abd211c2784513dab4db082fa414ad0967/doc/fugitive.txt#L212-L235)
for more details.

The `:Gbrowse` function is provided by the excellent
[`vim-fugitive`](https://github.com/tpope/vim-fugitive) and requires the
[`vim-rhubarb`](https://github.com/tpope/vim-rhubarb) plugin for Github support.
