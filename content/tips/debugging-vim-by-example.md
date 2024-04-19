+++
title = "Debugging Vim by example"
date = 2019-03-28
description = "A series of short stories."
tags = ['vim']
+++

<!-- Abstract -->

There's only so far you can get by cargo-culting other people's `~/.vim`
folders. An important next step is understanding how to _debug_ Vim; knowing
what to do when it's slow or misbehaving. Learn how to scratch things that itch.

This post illustrates a range of debugging and profiling approaches for Vim by
walking through real issues I've recently investigated, diagnosed and resolved.
There's very little to copy into your `~/.vimrc` but hopefully some useful
techniques that you can use.

If you take anything from this post, let it be that Vim has excellent support
for debugging and profiling and, with a little knowledge, it's easy to resolve
most annoyances.

Contents:

- ["Why isn't it working?"](#why-isnt-it-working)
- ["Why isn't my option working?"](#why-isnt-my-option-working)
- ["Why isn't syntax highlighting working as I want?"](#why-isnt-syntax-highlighting-working-as-i-want)
- ["Why is Vim slow to start up?"](#why-is-vim-slow-to-start-up)
- ["Why is {ACTION} slow?"](#why-is-action-slow)

## "Why isn't it working?"

I noticed that
[`hashivim/vim-terraform`](https://github.com/hashivim/vim-terraform) supports
running `terraform fmt` as a pre-save autocommand by setting
`g:terraform_fmt_on_save = 1`. I already had the `ftplugin` component of
[`hashivim/vim-terraform`](https://github.com/hashivim/vim-terraform) installed
via [`sheerun/vim-polyglot`](https://github.com/sheerun/vim-polyglot), yet after
adding the above setting to `~/.vimrc`, it wasn't working. Saving a poorly
formatted Terraform file didn't do anything; it seemed that `terraform fmt`
wasn't being run. Why?

### Print statements

I first identified the file responsible for handling this setting with a quick
search:

```bash
$ ag -l terraform_fmt_on_save ~/.vim/bundle/
~/.vim/bundle/vim-polyglot/ftplugin/terraform.vim
```

then sprinkled a few:

```vim
echom "Got here"
```

statements into that file, opened a new Terraform file-type buffer:

```vim
:edit sample.tf
```

and ran:

```vim
:messages
```

to see the results. This showed that the plugin was prematurely `finish`ing on
this guard:

```vim
if exists("g:loaded_terraform") || v:version < 700 || &cp || !executable('terraform')
  finish
endif
```

I then `:echo`ed each predicate at the command prompt to identify the culprit:

```vim
:echo executable('terraform')
0
```

<!-- Resolution -->

Turned out that `executable('terraform')` was returning `0` due to the way I had
configured my shell's `$PATH` environment variable. Specifically, downloaded
Hashicorp binaries were in a `~/hashicorp` folder that was added to `$PATH` in
`~/.bashrc` like so:

```bash
HASHICORP="~/hashicorp"
PATH="$HASHICORP:$PATH"
export $PATH
```

This works fine in shell sessions but Vim doesn't expand the `~` when running
the `executable` check and so doesn't find the `terraform` binary.

The fix was to update `~/.bashrc` to use `$HOME` instead of the `~` shorthand:

```bash
HASHICORP="$HOME/hashicorp"
PATH="$HASHICORP:$PATH"
export $PATH
```

After that, saving a Terraform file ran `terraform fmt` automatically. Phew.

Related help docs

- [`:help echom`](http://vimdoc.sourceforge.net/htmldoc/eval.html#:echomsg)
- [`:help messages`](http://vimdoc.sourceforge.net/htmldoc/message.html#:messages)
  (note, there's a superior `:Messages` command provided by Tim Pope's
  [`tpope/vim-scriptease`](https://github.com/tpope/vim-scriptease) that loads
  the messages into the
  [quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html) list which is
  much more convenient).
- [`:help executable`](<http://vimdoc.sourceforge.net/htmldoc/eval.html#executable()>)

### Debug mode

I could have solved the same mystery using Vim's little-known debug mode by
adding a breakpoint at the start of the suspect `ftplugin` file:

```vim
:breakadd file ~/.vim/bundle/vim-polyglot/ftplugin/terraform.vim
```

then opening a Terraform file-type buffer in debug mode:

```vim
:debug edit sample.tf
```

which drops you at a debugger prompt:

```bash
Entering Debug mode.  Type "cont" to continue.
cmd edit sample.tf
>
```

After hitting `c` to continue to the breakpoint:

```bash
>c
"sample.tf" [New File]
Breakpoint in "~/.vim/bundle/vim-polyglot/ftplugin/terraform.vim" line 1
~/.vim/bundle/vim-polyglot/ftplugin/terraform.vim
line 1: if !exists('g:polyglot_disabled') || index(g:polyglot_disabled, 'terraform') == -1
>
```

you can run each Ex expression individually to pinpoint the problem:

```vim
>echo exists('terraform')
0
```

It's also possible to simply insert:

```vim
breakadd here
```

to set a breakpoint in a file.

Further reading:

- [`:help debug-scripts`](http://vimdoc.sourceforge.net/htmldoc/repeat.html#debug-scripts)

### Verbose mode

Another approach is to use "verbose mode" to find out what Vim is doing. You can
start Vim in verbose mode with:

```bash
vim -V9 some-file
```

which `echo`s out what Vim is doing (the `9` indicates the level of verbosity).

You can inspect with output with `:messages` (or `:Messages`) but it's often
useful to write the output to file using the `verbosefile` option. Here's an
example of doing that for a single action:

```vim
:set verbose=9
:set verbosefile=/tmp/output.txt
:verbose {some action}
```

Further reading:

- [`:help 'verbose'`](http://vimdoc.sourceforge.net/htmldoc/options.html#'verbose')
- [`:help 'verbosefile'`](http://vimdoc.sourceforge.net/htmldoc/options.html#'verbosefile')
- [`:help :verbose`](http://vimdoc.sourceforge.net/htmldoc/various.html#:verbose)
- [Debugging Vim](http://inlehmansterms.net/2014/10/31/debugging-vim/) by
  _Jonathan Lehman_ (2014) --- A more thorough overview of Vim's debug and
  verbose modes.

### Process of elimination

Finally, you can try and locate the source of a problem through stripping away
all custom plugins and configuration, then slowly add them back in until the
symptoms reappear.

Start by verifying the problem is not present when Vim is loaded without custom
configuration (`-N` means `nocompatible` mode):

```bash
vim -u NONE -U NONE -N
```

then comment out everything in your `~/.vimrc` files and slowly uncomment blocks
until the problem appears.

For this and many other situations, its useful to use the `:scriptnames` command
to see all the sourced files for your current buffer. Like `:messages`, this has
a superior counterpart, `:Scriptnames`, in
[`tpope/vim-scriptease`](https://github.com/tpope/vim-scriptease), that loads
each script into the quickfix list.

Alternatively, you can capture the output of `:scriptnames` (or any other Ex
command) in a buffer for further interrogation. Do this by redirecting messages
to a register of your choice:

```vim
:redir @a
:scriptnames
:redir END
```

which you can then paste into a buffer and examine in detail.

Further reading:

- [`:help startup`](http://vimdoc.sourceforge.net/htmldoc/starting.html#startup)
- [`:help :scriptnames`](http://vimdoc.sourceforge.net/htmldoc/repeat.html#:scriptnames)
- [`:help :redir`](http://vimdoc.sourceforge.net/htmldoc/various.html#:redir)

<br/>
Now a few more specific scenarios:

## "Why isn't my option working?"

<!-- Problem description -->

I noticed the other day that the `textwidth` option I had carefully suggested in
`~/.vim/ftplugin/gitcommit.vim` wasn't in effect when editing a git commit
message.

You can check an option's value with:

```vim
set textwidth?
```

<!-- Problem resolution -->

To investigate, I looked up which Vim file had last set the option by prepending
`:verbose`:

```vim
:verbose set textwidth?
```

revealing:

```text
textwidth=72
      Last set from ~/.vim/bundle/vim-polyglot/ftplugin/gitcommit.vim line 17
```

So the `ftplugin` file from
[`sheerun/vim-polyglot`](https://github.com/sheerun/vim-polyglot) was to blame.

When you set options from files in `~/.vim/ftplugin/`, there's always a danger
they will be clobbered by your plugins (which are sourced afterwards).

The solution was to move the option assignment to
`~/.vim/after/ftplugin/gitcommit.vim` to ensure it gets sourced _after_ other
matching filepaths on Vim's `$RUNTIMEPATH`.

Note that you can prepend `:verbose` to `map` (and several other) commands to
see where particular mappings are defined. Eg:

```viml
:verbose imap <leader>
```

Further reading:

- [`:help :verbose`](https://vimhelp.org/various.txt.html#%3Averbose)

- [`:help 'rtp'`](https://vimhelp.org/options.txt.html#%27rtp%27)

- [Enhanced runtime powers](https://vimways.org/2018/runtime-hackery/) by _Tom
  Ryder_ (2018) --- An excellent post on how to work with Vim's `'runtimepath'`.

## "Why isn't syntax highlighting working as I want?"

<!-- Problem description -->

I recently enabled spell-checking for all file-types:

```vim
" ~/.vimrc
set spell
```

but found that this also includes spell-checking strings in Python, which I
can't imagine anyone wanting.

<!-- Problem resolution -->

To resolve, I used the `zS` command from
[`tpope/scriptease`](https://github.com/tpope/vim-scriptease) to identify the
syntax region name for Python strings: `pythonString`. Then used `:verbose` to
determine where this was last set:

```vim
:verbose hi pythonString
pythonString   xxx links to String
    Last set from ~/.vim/bundle/vim-polyglot/syntax/python.vim line 442
```

Line 442 isn't actually where the `syn region` declarations are, but they are in
the same file.

To resolve this issue, I needed to remove `@Spell` from the
`syn region pythonString` declarations. I'm sure this can be elegantly scripted
but I resorted to duplicating the relevant lines into
`~/.vim/after/syntax/python.vim` and removing the `@Spell` clusters. Ugly but
effective.

Further reading:

- [`:help syntax`](https://vimhelp.org/syntax.txt.html)

## "Why is Vim slow to start up?"

<!-- Problem description -->

Recently, after accumulating several plugins, I noticed Vim was taking
noticeably longer to start-up. Why?

### Profile start-up

I started Vim in profiling mode:

```bash
vim --startuptime startup.txt startup.txt
```

where each executed expression is timed and listed in the specified file (which
is also opened):

```viml
times in msec
 clock   self+sourced   self:  sourced script
 clock   elapsed:              other lines

000.010  000.010: --- VIM STARTING ---
000.152  000.142: Allocated generic buffers
001.230  001.078: locale set

...

276.800  002.201: VimEnter autocommands
276.802  000.002: before starting main loop
276.957  000.155: first screen update
276.959  000.002: --- VIM STARTED ---
```

At the bottom of the file, you can see the start-up time was around 280 ms in
total.

For reference, your baseline start-up time can be found by starting Vim with no
custom config:

```bash
vim +q -u NONE -U NONE -N --startuptime startup-no-config.txt
```

which, on my 2015 MacBook Pro, gives:

```viml
000.007  000.007: --- VIM STARTING ---
000.108  000.101: Allocated generic buffers
000.530  000.422: locale set

...

016.709  000.129: VimEnter autocommands
016.717  000.008: before starting main loop
017.167  000.450: first screen update
017.169  000.002: --- VIM STARTED ---
```

17ms -- so I'm spending around 260 ms loading my own configuration and plugins
each time I open Vim.

Anyway, I sorted the `startup.txt` buffer numerically by the second column to
see the slowest operations:

```vim
:%!sort -rnk2 | head -2
```

yielding:

```viml
times in msec
254.008  187.506  187.506: sourcing ~/.vim/bundle/black/plugin/black.vim
053.178  034.800  008.475: sourcing $HOME/.vimrc
```

So the Python formatting plugin [`ambv/black`](https://github.com/ambv/black),
which we've been toying with adopting at work, was the culprit, consuming more
than half of the start-up time.

In this case, the solution was to switch to using
[Ale's "fixer" functionality](https://codeinthehole.com/tips/using-black-and-isort-with-vim/)
to run black but this could be the starting point for an exciting profiling
session (see next section).

Of course, the scripts sourced at start-up depend on the file-types being opened
(the above example doesn't open a file). For instance, if opening Python files
is slow, ensure you profile with the right `filetype` set:

```bash
vim --startuptime python-startup.txt -c ":set ft=python" python-startup.txt
```

Further reading:

- [`:help startup`](http://vimdoc.sourceforge.net/htmldoc/starting.html#startup)
- [`:help slow-start`](http://vimdoc.sourceforge.net/htmldoc/starting.html#slow-start)
- [Vim plugins and startup time](https://junegunn.kr/2014/07/vim-plugins-and-startup-time)
  by _Junegunn Choi_ (2014) --- Interesting article by the author of
  [`junegunn/vim-plug`](https://github.com/junegunn/vim-plug) comparing start-up
  speeds of various Vim plugin managers and highlighting the performance boost
  of using lazy-loading to load plugins on demand.
- [How to speed up your Vim startup time](https://kynan.github.io/blog/2015/07/31/how-to-speed-up-your-vim-startup-time)
  by _Florian Rathgeber_ (2015) --- Another case-study in switching to
  [`junegunn/vim-plug`](https://github.com/junegunn/vim-plug).
- There's a
  [vim-plugins-profile](https://github.com/hyiltiz/vim-plugins-profile) project
  which provides scripts for profiling the start-up time of each plugin.

## "Why is {ACTION} slow?"

<!-- Problem description -->

I found writing the previous sections of this post, which is a markdown file,
slightly laggy when typing in insert mode. That shouldn't be the case -- what is
causing it?

### Profile anything that is slow

The generic pattern to remember for profiling is:

```viml
:profile start profile.log
:profile func *
:profile file *

{SLOW ACTIONS}

:profile pause
:wqall  " Quit Vim (required)
```

which profiles all files and functions[^profile-args] executed during the slow
actions.

[^profile-args]:
    Your can profile selected files or functions by passing specific names
    instead of `*` to the `:profile func` and `:profile file` commands.

It pays to pipe together the three set-up commands so it's easier to recall from
command history[^command-history]:

```viml
:profile start profile.log | :profile func * | :profile file *
```

[^command-history]:
    Just type a few characters, e.g. `:pro`, and hit `<UP>` a few times. Even
    better, add this to your `~/.vimrc`:

    ```viml
    cmap <C-P> <UP>
    ```

    then you can use `CTRL-P` and your fingers don't have to leave the home
    keys.

Back to the problem at hand, my `{SLOW ACTIONS}` were to type a simple sentence
into a markdown-filetype buffer. I did this and collected the output.

The profile output shows summary tables at the bottom with detailed breakdowns
above. of each function When interpreting the profile output, start at the
bottom of the file which shows the most expensive functions.

```viml
FUNCTIONS SORTED ON SELF TIME
count  total (s)   self (s)  function
 5805   0.267815   0.255992  Foldexpr_markdown()
   27              0.011823  <SNR>86_is_mkdCode()
    2              0.011755  <SNR>79_MarkdownHighlightSources()
   53              0.005295  <SNR>44_Highlight_Matching_Pair()
    2   0.000355   0.000284  ale#ShouldDoNothing()
    2   0.000705   0.000247  ale#cursor#EchoCursorWarning()
    2   0.011855   0.000100  <SNR>79_MarkdownRefreshSyntax()
    2   0.000103   0.000080  ale#util#FindItemAtCursor()
    1   0.000087   0.000064  ale#cursor#EchoCursorWarningWithDelay()
    2              0.000030  ale#util#InSandbox()
    2              0.000026  ale#FileTooLarge()
    2              0.000023  ale#util#BinarySearch()
    2              0.000015  ale#util#Mode()
    1              0.000015  ale#Var()
    1              0.000008  <SNR>111_StopCursorTimer()

```

This showed that `Foldexpr_markdown` was a bottleneck.

A quick `:grep` shows that the `Foldexpr_markdown` function lives in
`~/.vim/bundle/vim-markdown/after/ftplugin/markdown.vim` and a glance at the
docs showed that folding can be disabled with a global plugin
setting[^markdown]:

```viml
let g:vim_markdown_folding_disabled = 1
```

[^markdown]: It's a [known issue](https://github.com/plasticboy/vim-markdown/issues/162).

Profiling the same actions including this change gave a great improvement:

```viml
FUNCTIONS SORTED ON SELF TIME
count  total (s)   self (s)  function
    2              0.011698  <SNR>79_MarkdownHighlightSources()
   51              0.005496  <SNR>44_Highlight_Matching_Pair()
    2   0.000323   0.000256  ale#ShouldDoNothing()
    2   0.000627   0.000205  ale#cursor#EchoCursorWarning()
    2   0.011833   0.000135  <SNR>79_MarkdownRefreshSyntax()
    2   0.000099   0.000076  ale#util#FindItemAtCursor()
    1   0.000091   0.000067  ale#cursor#EchoCursorWarningWithDelay()
    2              0.000030  ale#util#InSandbox()
    2              0.000023  ale#util#BinarySearch()
    2              0.000023  ale#FileTooLarge()
    1              0.000016  ale#Var()
    2              0.000014  ale#util#Mode()
    1              0.000008  <SNR>111_StopCursorTimer()
```

Of course, there's no one-size-fits-all solution to addressing performance
bottlenecks. There are a few things to try:

- If the offending code is in a plugin, start by reading the docs and checking
  the issue tracker. Is this a known issue?

- If the code is within Vim's runtime files, read the source of the slow file.
  There's often settings that can be used to tune or disable the behaviour.

Further reading:

- [`:help profiling`](http://vimdoc.sourceforge.net/htmldoc/repeat.html#profiling)

- [Vimcast: Profiling Vimscript performance](http://vimcasts.org/episodes/profiling-vimscript-performance/)
  --- an informative video demonstrating Vim's `--cmd` and `-c` options for
  profiling your `~/.vimrc`:

  ```sh
  vim --cmd "profile start vimrc.profile" --cmd "profile! file ~/.vimrc"
  ```

- [Profiling Vim](http://inlehmansterms.net/2015/01/17/profiling-vim/) by
  _Jonathan Lehman_ (2015) --- A detailed examination of profiling techniques.

- [Profiling Vim](https://medium.com/@MauroMorales/profiling-vim-e142280a91ae)
  by _Mauro Morales_ --- Mentions you can cross-reference the `<SNR>` tag in the
  profile output with the numbers in `:scriptnames` to identify the source file.

## Summary

Other than the advice above, here's a couple of final thoughts:

- Use [`tpope/scriptease`](https://github.com/tpope/vim-scriptease) -- it
  provides a few really useful commands for debugging.

- Keep your `~/.vim` folder in source control, which makes it much easier to try
  out new things in branches or walk back through your history to find the
  commit that introduced a performance problem.

Above all, it's not difficult to debug or profile Vim. Get into the habit of
investigating and resolving annoying niggles when they appear.

Finally, here are some other articles and resources on the same topic as this
post:

- [Debugging Vim setup](https://sanctum.geek.nz/arabesque/debugging-vim-setup/)
  by _Tom Ryder_ (2012) --- A brief overview of some of the techniques exhibited
  in this article.

- [Debugging your Vim config](https://vimways.org/2018/debugging-your-vim-config/)
  by _Samuel Walladge_ (2018) --- Quite a similar but less detailed article to
  this, covering a range of debugging techniques.
