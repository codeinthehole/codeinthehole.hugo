---
{
  "aliases": ["/writing/using-the-silver-searcher-with-vim"],
  "date": "2014-06-17",
  "description": "Lightning-fast :grep searching in Vim",
  "slug": "using-the-silver-searcher-with-vim",
  "tags": ["vim"],
  "title": "Using the silver searcher with Vim",
}
---

If you're not doing this already, then you should use the
[Silver Searcher](http://geoff.greer.fm/2011/12/27/the-silver-searcher-better-than-ack/)
within Vim for rapid, convenient file searching. In a nutshell, `ag` offers
similar functionality to `ack` but with much better performance.

It's easily installed - on OSX, run:

```bash
brew install the_silver_searcher
```

Urge Vim to use it for `:grep` commands by adding the following to `~/.vimrc`:

```vim
if executable('ag')
    " Note we extract the column as well as the file and line number
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m
endif
```

`:grep` searches are now lightning-fast and respectful of your `~/.gitignore`
patterns. It's genuinely impressive.

Improve your efficiency further by remapping the keys for jumping through search
matches (stored in the "quickfix" list):

```vim
nmap <silent> <RIGHT> :cnext<CR>
nmap <silent> <LEFT> :cprev<CR>
```

I'm using the cursor keys since I normally have them disabled.

See also:

- [Faster Grepping in Vim](http://robots.thoughtbot.com/faster-grepping-in-vim)
  by Dan Croak - this shows how to use the Silver searcher with the
  [CtrlP](https://github.com/kien/ctrlp.vim) plugin.

- The Vim plugin [ag.vim](https://github.com/rking/ag.vim).
