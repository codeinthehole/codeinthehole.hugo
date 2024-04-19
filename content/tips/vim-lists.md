+++
title = "Vim's useful lists"
date = 2021-05-03T09:27:17+01:00
description = "A reference post of Vim's lists and tips on using them effectively."
tags = ["Vim"]
+++

A good understanding of Vim's various lists is a massive productivity boost —
it's taken me many years of Vim use to truly appreciate this.

This post summarises _some_ of Vim's lists, detailing their purpose and how to
make the most of them.

{{< table_of_contents >}}

---

## Quickfix list

<!-- Summary of stdlib quickfix features -->

A _global_ list of locations populated via one of these commands:

- `:vim[grep]` --- search using Vim's native functionality.
- `:gr[ep]` --- search via an external program specified by the `grepprg`
  setting.
- `:helpgr[ep]` --- search help text files.
- `:mak[e]` --- call the program specified by the `makeprg` setting (which
  defaults to `make`).
- `:cex[pr] {expression}` --- use `{expression}` to populate to list. This can
  be used to clear the quickfix list via `:cex []`.

Quickfix list commands start `:c` --- here's some useful ones:

- `:cw[indow]` --- Open the quickfix window if it's non-empty.
- `:cn[ext]`, `:cp[rev]` --- Jump to next/previous error.
- `:cnf[ile]`, `:cpf[ile]` --- Jump to first error in the next/previous file.
- `:cab[ove]` `:cbel[ow]` --- Jump to the error above/below the current line.

Vim remembers the last ten quickfix lists; you can navigate between them with:

- `:col[der]`, `:cnew[er]` --- Go to the older/newer quickfix list.
- `:chi[story]` --- Show the list of quickfix lists.

This is powerful: it allows building a tree of searches, which is a useful
debugging pattern when exploring a codebase.

More at [`:help quickfix`](https://vimhelp.org/quickfix.txt.html).

### Tip: Use mappings for faster browsing

Since you'll use them a lot, define convenient mappings for `:cnext` and
`:cprev`. This can be achieved with
[`tpope/vim-unimpaired`](https://github.com/tpope/vim-unimpaired), which
provides a slew of useful mapping pairs starting with `[` or `]`. E.g.

- `[q`, `]q` — `:cprevious`, `:cnext`
- `[Q`, `]Q` — `:cfirst`, `:clast`
- `[<C-Q>`, `]<C-Q>` — `:cpfile`, `:cnfile`

There's a pair of
[`tpope/vim-unimpaired`](https://github.com/tpope/vim-unimpaired) mappings for
each list described in this post.

### Tip: Define a mapping to `:grep` for the word under the cursor

I also recommend defining a mapping that runs `:grep` on the word under the
cursor. This makes it trivial to answer the question "where else is this
function used?"

I use:

```vim
nnoremap gw :grep <cword> . <cr>
```

although this does clobber a built-in formatting operator.

### Tip: Custom `grepprg` programs

Use [`ripgrep`](https://github.com/BurntSushi/ripgrep) as your default search
program:

```viml
if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif
```

Keep your `ripgrep` configuration in a global `~/.ripgreprc` file so `:grep`
behaves the same as `rg` at the command-line. Recommended settings:

```ini
# ~/.ripgreprc
--smart-case
--hidden
--glob
!.git
```

### Tip: Custom `makeprg` programs

The default `makeprg` is `make` but any command that prints locations to STDOUT
can be used — most static analysis tools are viable candidates.

For instance, I occasionally use it for
[Bandit](https://pypi.org/project/bandit/) security analysis via:

```vim
set makeprg=bandit\ -r\ -f\ custom
```

or to work though all Python linting errors in a new project:

```vim
set makeprg=flake8
```

### Tip: Operating on the error list

A powerful editing technique is to apply an operation or macro to each location
or file in the quickfix list. This is done with `:cdo` or `:cfdo` respectively.
Here are some examples where we populate the quickfix list using `:grep` (using
`ripgrep` options) then perform a batch edit using `:cdo` or `:cfdo`.

Replace "foo" with "bar" in all Python files containing the string "baz":

```vim
:grep baz -t py
:cfdo %s/foo/bar/g | update
```

Delete lines containing "foo" from all files called `urls.py`:

```vim
:grep foo -g urls.py
:cfdo g/foo/d | update
```

Run macro `q` on all lines containing "foo":

```vim
:grep foo
:cdo normal @q
```

I sometimes write a custom function to run on each quickfix location. This is a
useful way of performing complex batch changes that are too complex for a single
Ex command or macro:

```vim
function! FixQuickfixEntry()
    " Example the line of the error to determine what fix is required.
    let line = getline('.')
    if line =~ 'as e:$'
        " Handle scenario of unused exception variable
        s/ as e:/:/
    elseif line =~ '^\s\+\w\+ = factory'
        " Handle scenario of unused test factory variable
        normal _
        normal 2dw
    else
        echom "Unable to fix"
    endif
endfunction
```

then use:

```vim
:cdo call FixQuickfixEntry()
```

This is good technique for quickly performing sophisticated refactoring across a
whole codebase.

### Tip: Populate the quickfix list in a subshell

When running `:grep` or `:make`, Vim executes the program in Vim's parent shell.
This suspends Vim while results are printed then requires you to hit enter to
return.

There's
[a brilliant gist from Romain Lafourcade](https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3)
that shows how to avoid this woes by using `:cgetexpr` (or `:cexpr`) to populate
the quickfix list in a subshell. There's a few variants you can use depending on
whether you regularly search for multi-word queries. I do, so I use this
version:

```vim
function! Grep(...)
    let cmd = join([&grepprg] + [join(a:000, ' ')], ' ')
    return system(cmd)
endfunction

command! -nargs=+ -complete=file_in_path Grep cexpr Grep(<f-args>)
```

To complement this, you can use a command-line abbreviation to automatically
switch `:grep` to `:Grep`:

```vim
cnoreabbrev <expr> grep (getcmdtype() ==# ':' && getcmdline() ==# 'grep') ? 'Grep' : 'grep'
```

and an autocommand to open the quickfix window when there are results:

```vim
augroup quickfix
 autocmd!
 autocmd QuickFixCmdPost cexpr cwindow
augroup END
```

This is life changing.

<!--
Other quickfix tips

https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
Write a custom :Grep command that avoids running the external command in the
parent shell (which clogs up shell and requires hitting enter)

https://noahfrederick.com/log/vim-streamlining-grep
Use a cnoreabbrev to map grep to 'silent grep'

https://stackoverflow.com/questions/1747091/how-do-you-use-vims-quickfix-feature
Highlights vim-impaired
Mentions syntastic uses location list

https://medium.com/usevim/vim-101-quickfix-and-grep-c782cb65e524
Nothing I didn't know already

https://tldp.org/HOWTO/C-editing-with-VIM-HOWTO/quickfix.html
Notes on C work

https://vimways.org/2018/colder-quickfix-lists/
- great intro
- quickfix buffer has file-type qf which we can target

to research:

https://github.com/romainl/vim-qf
- not recommended to syntastic/ale users

Prior art:

https://www.reddit.com/r/vim/comments/ebdp8d/how_do_i_apply_a_macro_to_all_files_under_a_folder/
https://github.com/tpope/vim-unimpaired

-->

---

## Location list

<!-- Summary of stdlib quickfix features -->

A _window-local_ equivalent of the quickfix list — a similar set of commands
exists but now prefixed `:l` (e.g. `:lwindow` to open the location list if it
has entries).

<!-- Personal take -->

Personally, I don't use it much directly but it's good to be aware of. Popular
plugins like [Ale](https://github.com/dense-analysis/ale) and
[Syntastic](https://github.com/vim-syntastic/syntastic) populate the location
list.

More at
[`:help location-list`](https://vimhelp.org/quickfix.txt.html#location-list).

---

## Jump list

<!-- Useful to for quick jumping but sometimes confusing — best to use change
list when jumping back to previous edit locations.

Relevant literature
-------------------

https://medium.com/breathe-publication/understanding-vims-jump-list-7e1bfc72cdf0
https://kadekillary.work/post/vim-jumplist/ (dupe?)
- Refers to useful Romainl Reddit comment about using searches
- Mixs up changelist

https://medium.com/usevim/vim-101-the-jump-and-change-lists-ef15cfb22c30
- A decent summary

https://developpaper.com/use-vims-jump-list-to-see-the-code/
- Another decent summary
-->

<!-- Summary of stdlib quickfix features -->

A _window-local_ list of the last one hundred cursor positions:

- `CTRL-O`, `CTRL-I` — Go to previous/next cursor position in jump list.
- `:jumps` --- View the jump list.
- `:clearjumps` --- Clear the jump list.

The following commands as considered "jumps" and will append an entry to the
jump list:

- `(`, `)` --- Jump backward/forward a sentence;
- `{`, `}` --- Jump backward/forward a paragraph;
- `/`, `?` --- Search forward/backward in current buffer;
- `n`, `N` --- Repeat the last `/` or `?` jump in conventional/opposite
  direction;
- `:s` --- Substitution;
- `G` --- Go to line;
- `%` --- Jump to matching parenthesis/bracket/brace/...
- `'`,`` ` `` --- Jump to a mark in the current buffer;
- `H`, `M`, `L` --- Jump to the top/middle/bottom of the current window
  (adjusting for `scrolloff` offset).
- `:tag`, `^]` --- Jump to tag definition;
- `[[`, `]]` --- Move one "section" backward/forward, or to the previous `{` in
  the first column. Note "sections" in Vim
  [come from Nroff files](https://learnvimscriptthehardway.stevelosh.com/chapters/50.html)
  and are generally not that useful.

Further, commands that start editing files like `:edit` append to the
`jumplist`.

When you split a window, its jump list is duplicated and jump lists are saved
between sessions (in the `viminfo` file) if the `'viminfo'` option includes a
`'` character.

More at:

- [`:help jumplist`](https://vimhelp.org/motion.txt.html#jumplist)

### Tip: Use jump commands to navigate

The motions `j`, `k`, `CTRL-U`, `CTRL-D` are not counted as jumps and so don't
create an entry in the jump list. Hence it's preferable to navigate within a
buffer using the above jump commands as this builds a history that you can walk
back through (see
[this Reddit comment](https://www.reddit.com/r/vim/comments/72481y/learning_vim_what_i_wish_i_knew/dnfyahf/)).

---

## Change list

A _buffer-local_ list of the last one hundred _undo-able_ changes:

- `g;`, `g,` --- Jump to the previous/next change. These can be prefixed with a
  count to determine which change to jump back/forward to.

- `:changes` --- View the change list. The output enumerates each change making
  it easy to determine the `count` value to use with `g;` or `g,`.

Like the `jumplist`, the `changelist` is persisted for each file if your
`viminfo` setting contains a `'`.

More at:

- [`:help changelist`](http://vimdoc.sourceforge.net/htmldoc/motion.html#changelist)
- [Vim tips wiki: List changes to the current file](https://vim.fandom.com/wiki/List_changes_to_the_current_file)

### Tip: Jump to the previous location where insert mode was used

Not strictly to do with the change list but the `gi` command is similar to `g;`.
It will enter insert mode in the current buffer in the last insert mode
location. If you made a change when last in insert mode, this will be equivalent
to `g;` but will also put you into insert mode. The same effect can be achieved
with marks via `'^`.

---

## Buffer list

<!-- Summary of stdlib quickfix features -->

A _global_, append-only list of buffers (including cursor location and state)
for the current editing session. Each opened file will be appended to the list
which can be viewed with any of `:buffers`, `:files` or most succinctly `:ls`.

There are many ways to navigate the buffer list, including:

- `:b[uffer] {number}` --- Jump to buffer by number.
- `:bp[rev]`, `:bn[ext]` --- Jump to previous/next buffer (will wrap at end of
  list).
- `:bf[irst]`, `:br[ewind]` --- Jump to first/last buffer.

or from [`tpope/vim-unimpaired`](https://github.com/tpope/vim-unimpaired):

- `[b`, `]b` --- Jump to previous/next buffer.
- `[B`, `]B` --- Jump to first/last buffer.

Some other useful buffer list commands to know:

- `:ba[ll]` --- Rearrange windows to show a window for each buffer in the buffer
  list.
- `:bufdo {cmd}` --- Execute `{cmd}` in each buffer in the list. For example,
  apply macro `q` to each buffer with `:bufdo normal @q`.

More at:

- [`:help buffers`](https://vimhelp.org/windows.html#buffers)
- [`:help buffer-list`](https://vimhelp.org/windows.html#buffer-list)
- [Vim tips wiki: Vim buffer FAQ](https://vim.fandom.com/wiki/Vim_buffer_FAQ)

### Tip: Select buffers with FZF

I recommend the `:Buffers` command from the excellent
[`junegunn/fzf.vim`](https://github.com/junegunn/fzf.vim) to jump to a buffer
using fuzzy matching. For easy access I map `:Buffers` to `,b` and `:Files` to
`,f`.

<!--
https://vim.fandom.com/wiki/Vim_buffer_FAQ
- Some useful buffer tips, nothing interesting

https://hashrocket.com/blog/posts/understanding-the-buffer-list-in-vim-part-1
- Good solid introduction to understanding the buffer list.

https://www.reddit.com/r/vim/comments/u3nv6/buffer_list_vs_arguments_list/c4s6gml/
- Commend from Drew on difference between buffer-list and arg-list. Key point is
  the buffer-list is less organised but the arg-list is curated.

-->

---

## Argument list

The buffer list tends to become cluttered over time, making it awkward to use
`:bufdo`. This is where the argument list comes in --- it allows you to _curate_
a list of files to act on with the equivalent `:argdo`.

The name is misleading: the argument list is not simply the list of files that
Vim was opened with. It's a global, _mutable_ list that can be edited within
your Vim session to select exactly the files that you want to operate on.

<!-- Ways of populating the argument list -->

There are several ways of populating the argument list, listed here in order of
increasing usefulness:

1. Manually add and remove files from the argument list with `:arga[dd]` and
   `:argd[elete]`.

2. Pass files as arguments when opening Vim:

   ```bash
   vim file1 file2
   ```

   or using a file finder like [`fd`](https://github.com/sharkdp/fd):

   ```bash
   vim $(fd -e py)  # open files with .py extension
   ```

3. Pipe a list of files to `xargs` to provide an initial argument list:

   ```bash
   fd -e py | xargs -o vim
   ```

   The `-o` option for `xargs` re-opens `stdin` for the Vim process — without
   this, Vim can
   [break your terminal](https://superuser.com/questions/336016/invoking-vi-through-find-xargs-breaks-my-terminal-why).

4. Within a Vim session, use the `:args` command:

   ```vim
   :args file1 file2
   ```

   This approach is powerful as not only does wildcard expansion work:

   ```vim
   :args *.c
   ```

   but so does shelling out:

   ```vim
   :args `fd -e py`
   ```

   [`fd`](https://github.com/sharkdp/fd) is a particularly good tool to use to
   populate the argument list.

<!-- Navigating the argument list -->

You can check the contents of the argument list with `:ar[gs]` and traverse
with:

- `:p[revious]`, `:n[ext]` — Edit the previous/next file in the argument list.
- `:fir[st]`, `:la[st]` — Edit the first/last file in the argument list.

Or via [`tpope/vim-unimpaired`](https://github.com/tpope/vim-unimpaired):

- `[a`, `]a` — `:previous`, `:next`
- `[A`, `]A` — `:first`, `:last`

<!-- Operating on the argument list -->

It's now possible to apply batch operations on each file in the argument list
using `:argdo {cmd}`. An example workflow is:

1. Select all HTML files beneath current directory:

   ```vim
   :args `fd -e html`
   ```

2. Run a search-and-replace-then-save operation on each file:

   ```vim
   :argdo %s/foo/bar/g | update
   ```

More at:

- [`:help argument-list`](https://vimhelp.org/editing.txt.html#argument-list)
- [`:help :argdo`](https://vimhelp.org/editing.txt.html#argdo)

---

## Tag match list

<!-- What are tags? -->

A "tag" is an identifier --- like a function, class or variable name --- that
appears in a "tags file" generated by an external program like `ctags`. The tags
file is effectively an index mapping identifiers to locations in your codebase.

<!-- How Vim finds your tag files -->

Use the `tags` setting to tell Vim where to find tag files. A common value is:

```vim
set tags=./tags;,tags
```

which tells Vim to look for tags file in the directory of the current file, in
the working directory and in every parent directory, recursively.

You can check which tag files have been loaded with:

```vim
:echo tagfiles()
```

<!-- Using the tags file to explore code -->

You can jump to a tag definition with:

- `CTRL-]` --- Look-up the keyword under the cursor. Useful for jumping to a
  function's definition.
- `:ta[g] {query}` --- Find the tag(s) matching `{query}`. This command also
  supports command-line completion and regular expression queries like
  `:tag /foobar/`.

If you want to open the tag in a split or the preview window, there are
analogues of the above commands starting `:s` and `:p`.

<!-- When there are multiple matches -->

If there are multiple tag matches, `CTRL-]` and `:tag` will jump to the first
one. The "tag match list" can be opened with `:ts[elect]` and traversed via
`:tf[irst]`, `:tn[ext]`, `:tp[rev]`, `:tl[ast]`.

As ever, there are useful bindings from
[`tpope/vim-unimpaired`](https://github.com/tpope/vim-unimpaired):

- `[t`, `]t` — `:tprevious`, `:tnext`
- `[T`, `]T` — `:tfirst`, `:tlast`

If you want to show the tag match list when there are multiple matches but jump
straight to the tag if a single match, use `:tj[ump]` or `g CTRL-]`.

<!-- Tag stack -->

Vim stores the twenty most recent tag match lists in a stack which you can view
with `:tags`. This allows you to descend into a call graph by repeatedly jumping
to function definitions then popping the stack to return to the previous
location with `CTRL-T` or `:po[p]`. This is analogous to the nested quickfix
lists we saw earlier and is a powerful code exploration technique.

More at:

- [`:help tag-commands`](http://vimdoc.sourceforge.net/htmldoc/tagsrch.txt.html#tag-commands)
- [Vim tips wiki: Browsing programs with tags](https://vim.fandom.com/wiki/Browsing_programs_with_tags)
- [A Github Gist on tags by Romain Lafourcade](https://gist.github.com/romainl/f2d0727bdb9bde063531cd237f47775f)

<!-- Tips -->

### Tip: Use Universal Ctags

[Universal Ctags](https://github.com/universal-ctags/ctags) is the successor to
[Exuberant Ctags](http://ctags.sourceforge.net/); it's actively maintained and
supports a wider array of languages. It's worth installing to build tags files
for your projects.

### Tip: Use `:tjump` as your default "jump to tag" command

If it's common for your codebase to have multiple matches for identifiers (which
is true of Python), consider using `:tjump` (`g CTRL-]`) instead of `CTRL-]` as
your default "jump to tag" command".

I swap the meanings of `CTRL-]` and `g CTRL-]`:

```vim
nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>
nnoremap g<c-]> <c-]>
vnoremap g<c-]> <c-]>
```

### Tip: FZF also has a tag searching functionality

The [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) plugin provides two
commands for quickly finding tags using the
[`fzf`](https://github.com/junegunn/fzf) fuzzy file finder:

- `:Tags` --- List tags in project.
- `:BTags` --- List tags in current buffer.

<!--

Literature around using the tag stack.

https://vim.fandom.com/wiki/Browsing_programs_with_tags
Really good - lots of good tips.

https://gist.github.com/romainl/f2d0727bdb9bde063531cd237f47775f
Good notes on interesting ways of working with tags.

https://robertodealmeida.posthaven.com/using-ctags-in-vim-with-a-python-virtualenv
- Example mapping for generating virtualenv ctags

https://andrew.stwrt.ca/posts/vim-ctags/
- Some basics on using Vim with ctags

https://linuxhint.com/vim_ctags/
-->

---

## Include file list and definition lists

There are a couple of other lesser-known lists from Vim's C-language heritage.

The include file list is populated by commands that look for a keyword in the
current buffer and all "included" files. Which files are searched depends on:

- The `'include'` option, which identifies lines that include another file —
  this defaults to `^\s*#\s*include`.

- The `'path'` option which tells Vim where to find said included files.

Search with:

- `:il[ist] {pattern}` --- search in [range] or file for `pattern`.

There's also the definition list.

- `:dl[ist] {pattern}` --- search in [range] or file for `pattern`.

Since I primarily program in Python, this isn't that useful; I use tag search
(and the tag match list) to jump to symbol definitions. However I've learnt over
time to never write-off Vim's features — I'm sure this could be useful as a more
focussed tag search when working in languages that use filepath includes.

More at
[`:help include-search`](https://vimhelp.org/tagsrch.txt.html#include-search)

<!-- Research on other lists

- `:ol[dfiles]` --- List the files that have marks stored in the `viminfo` file
- `:undolist` --- List the files that have marks stored in the `viminfo` file
- `:marks` --- List the files that have marks stored in the `viminfo` file

https://www.reddit.com/r/vim/comments/d08llo/a_list_of_vims_lists/

Could note on how to jump to an item from the list
https://www.reddit.com/r/vim/comments/d08llo/a_list_of_vims_lists/ez8nr4s/

-->

---

## Summary

The above is intended as a reference for myself, but hopefully it will be useful
to others. The act of compiling this post has been incredibly useful; I've
learnt many new things[^tils] just fleshing out each section.

<!-- markdownlint-disable MD007 -->

[^tils]: Here are _some_ of the things learnt while researching this post:

    - [TIL how to use custom functions with `:cdo`](https://til.codeinthehole.com/posts/how-to-use-custom-functions-with-cdo/)
    - [TIL how to add project-specific Vim settings](https://til.codeinthehole.com/posts/how-to-add-project-specific-vim-settings/)
    - [TIL Universal Ctags can index more things than I realised](https://til.codeinthehole.com/posts/universal-ctags-can-index-more-things-than-i-realised/)
    - [TIL how to configure `ctags` to parse Terraform files](https://til.codeinthehole.com/posts/how-to-configure-ctags-to-parse-terraform-files/)
    - [TIL you can run `:grep` without using the parent shell process](https://til.codeinthehole.com/posts/you-can-run-grep-without-using-parent-shell-process/)
    - [TIL there’s a `QuickFixCmdPost` event in Vim](https://til.codeinthehole.com/posts/theres-a-quickfixcmdpost-event-in-vim/)
    - [TIL you can jump to previous quickfix lists in Vim](https://til.codeinthehole.com/posts/you-can-jump-to-previous-quickfix-lists-in-vim/)

<!-- markdownlint-enable MD007 -->

There's a couple of key usage patterns that are worth calling out:

### I need to jump somewhere

When editing code, you often need to jump to another location.

- To jump to _the definition of a function or class_, use the tag list via
  `:tag`, `:tjump` or `g CTRL-]`.

- To examine _everywhere that a function or class is being called_ or
  _everywhere that matches a regex_ use the quickfix list via `:grep` (or,
  better, `:Grep`).

- To jump to _where you last were_, use the jump list via `CTRL-O`.

- To jump to _where you last made a change_, use the change list via `g;`.

- To jump to _where you were last in insert mode_, use `gi`.

### I need to apply the same transformation in lots of places

A powerful editing pattern comprises building a list of files or locations then
applying the same editing operation to each entry. This is great for applying
refactorings across a large codebase.

The best approach depends on how you want to build your list of files or
locations:

- If you want to select _code locations_, populate the quickfix list with
  `:grep` and apply the batch changes with `:cdo`.

- If you want to select _files by their content_, populate the quickfix list
  with `:grep` and apply the batch changes with `:cfdo`.

- If you want to select _files by their filepath_, populate the argument list
  with ``:args `fd $PATTERN` `` and apply the batch changes with `:argdo`.

- If you want to select _files manually_, use `:argadd` and `:argdelete` to
  populate the argument list then use `:argdo` (this is generally preferable to
  using the buffer list and `:bufdo`, although that might suffice in some
  situations).

The editing operation could be an Ex command (e.g. `%s/foo/bar/g | update`),
applying a macro (e.g. `normal @q`) or calling a bespoke Vimscript function
(e.g. `call MyBespokeFunction`).

<!--

## Literature

Related articles:

- [A list of Vim's lists](https://noahfrederick.com/log/a-list-of-vims-lists).
  Pretty much what this post is but without the notes on how to apply commands
  to the list args.

- [Vim 101: The Jump and Change Lists](https://medium.com/usevim/vim-101-the-jump-and-change-lists-ef15cfb22c30) by Alex R. Young.

- [The quickfix and location lists in Vim](https://freshman.tech/vim-quickfix-and-location-list/) by Ayooluwa Isaiah. There's some great advice
  in the [associated Reddit thread by Romain Lafourcade](https://www.reddit.com/r/vim/comments/hbcx5d/the_quickfix_and_location_lists_in_vim/).

- [Lists, Vim and You](https://thoughtbot.com/blog/lists-vim-and-you) by Teo Ljungberg.
    - Demonstrates how the `arglist` can be
      used to perform a search and replace over a list of files specified when
      starting Vim.
    - Can use `:cdo` and `:cfodo` to operate over the quickfix list rather than
      the arglist.
    - Populate quickfix list using `:grep`

- https://stackoverflow.com/questions/1747091/how-do-you-use-vims-quickfix-feature - useful guide to quickfix commands

-->
