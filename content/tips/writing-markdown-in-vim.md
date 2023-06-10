+++
title = "Writing Markdown in Vim"
date = 2023-06-06
description = "A reference of how I have things configured."
tags = ["Vim", "Markdown"]
+++

<!-- INTRODUCTION -->

I write a lot of Markdown in Vim and have spent considerable energy configuring
it to my liking. This post details how I configure Vim[^1] for writing markdown.

It is merely a reference that I can refer others to.

[^1]: Accurate as of Neovim 0.9 and MacVim 9.0 (patch 1-1276).

<!-- CONTENT -->

## File-type settings

In `~/.vim/after/ftplugin/markdown.vim` (or equivalent), set some buffer-local
settings:

```vim
" Use Vim's spell checker
setlocal spell

" No line numbers
setlocal nonumber
```

Configure `K` to look up the word under the cursor in a dictionary:

```vim
" Use custom wrapper around MacOS dictionary as keyword look-up
setlocal keywordprg=open-dict
```

where `open-dict` is a Bash script of form:

```sh
#!/usr/bin/env bash

set -e

function main() {
    open "dict://$1"
}

main "$1"
```

A wrapper script is required as `open "dict://"` can't be set directly as
`keywordprg` since Vim adds a space after the command.

Side-step a gotcha with Hugo Markdown files:

```vim
" Hugo Markdown files can have 'Vim: ' in their file metadata, which Vim
" treats as a modeline and spits out an error. Hence, we disable
" `modelines` for Markdown files.
setlocal nomodeline
```

## Plugins

### Vim-Markdown

Install the [`sheerun/vim-polyglot`][vim-polyglot] language pack but disable its
Markdown support in `~/.vimrc`:

[vim-polyglot]: https://github.com/sheerun/vim-polyglot
[vim-markdown]: https://github.com/preservim/vim-markdown

```vim
let g:polyglot_disabled = ['markdown']
Plug 'sheerun/vim-polyglot'
```

Polyglot bundles the excellent [`preservim/vim-markdown`][vim-markdown] plugin,
but install it directly so the latest version is used:

```vim
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
```

As well as indent and syntax support, this provides:

- Folding
- Highlighting of fenced code blocks
- Highlighting of front matter

and some useful commands like:

- `:Toc` — Create a table of contents in the quickfix list
- `:InsertToc` — insert a table of contents into the buffer
- `:SetexToAtx`, `:HeaderDecrease`, `:HeaderIncrease` — Manipulate headings (see
  the [README][vim-markdown-commands] for more details).

[vim-markdown-commands]: https://github.com/preservim/vim-markdown#commands

Configure the plugin with these global settings:

```vim
" Enable folding.
let g:vim_markdown_folding_disabled = 0

" Fold heading in with the contents.
let g:vim_markdown_folding_style_pythonic = 1

" Don't use the shipped key bindings.
let g:vim_markdown_no_default_key_mappings = 1

" Autoshrink TOCs.
let g:vim_markdown_toc_autofit = 1

" Indentation for new lists. We don't insert bullets as it doesn't play
" nicely with `gq` formatting. It relies on a hack of treating bullets
" as comment characters.
" See https://github.com/plasticboy/vim-markdown/issues/232
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0

" Filetype names and aliases for fenced code blocks.
let g:vim_markdown_fenced_languages = ['php', 'py=python', 'js=javascript', 'bash=sh', 'viml=vim']

" Highlight front matter (useful for Hugo posts).
let g:vim_markdown_toml_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_frontmatter = 1

" Format strike-through text (wrapped in `~~`).
let g:vim_markdown_strikethrough = 1
```

### Github Copilot

Install [`github/copilot.vim`][copilot.vim] and enable it for Markdown buffers:

[copilot.vim]: https://github.com/github/copilot.vim

```vim
Plug 'github/copilot.vim'
let g:copilot_filetypes = {'markdown': v:true}
```

Having Copilot trying to second guess your sentences is generally more amusing
than useful but it can be helpful for mundane tasks like adding link URLs and
similar.

### Ale

Install [`dense-analysis/ale`][ale] in `~/.vimrc`:

[ale]: https://github.com/dense-analysis/ale

```vim
Plug 'dense-analysis/ale'
```

and configure the default linters and fixers for Markdown in
`~/.vim/after/ftplugin/markdown.vim`:

```vim
let b:ale_linters = ['markdownlint', 'vale']
let b:ale_fixers = ['prettier']
```

More detail on these tools below.

Note that `:ALEInfo` is useful for listing the available linters for the current
file type and for debugging if these tools are working correctly.

## Tools

### Markdownlint

[Markdownlint][markdownlint] will lint Markdown for simple style issues.

[markdownlint]: https://github.com/DavidAnson/markdownlint

Install globally with:

```sh
npm install -g markdownlint-cli
```

[markdownlint-cli]: https://github.com/igorshubovych/markdownlint-cli

The [`markdownlint-cli`][markdownlint-cli] NPM package installs a `markdownlint`
command.

Markdownlint will look for a `.markdownlint.yaml` configuration file in the
current folder and all parents. For any project that uses Markdown, it's best to
keep a `.markdownlint.yaml` committed to the repo root so it's shared between
committers. But it's also useful to keep a fallback file in your home directory
for ad-hoc Markdown editing:

```yaml
# ~/.markdownlint.yaml

# Enable all rules by default
# https://github.com/markdownlint/markdownlint/blob/main/docs/RULES.md
default: true

# Allow inline HTML which is useful in Github-flavour markdown for:
# - crafting headings with friendly hash fragments.
# - adding collapsible sections with <details> and <summary>.
MD033: false

# Ignore line length rules (as Prettier handles this).
MD013: false
```

### Vale

[Vale][vale] is a highly customisable linter for Markdown and other mark-up
languages. It's fast and can find a plethora of style and composition issues in
your Markdown writing.

[vale]: https://github.com/errata-ai/vale

Install via Homebrew:

```sh
brew install vale
```

As with Markdownlint, it's useful to have some fallback configuration, which can
be kept in `~/.vale.ini`:

```dosini
# Where the styles are kept.
StylesPath = .vale

MinAlertLevel = suggestion

# Where to look for local vocabulary files.
Vocab = Local

# Define which styles to use for Markdown.
[*.{md,markdown,txt}]
BasedOnStyles = Vale, write-good, proselint

[*]
BasedOnStyles = Vale

# Disable any rules that are more annoying than useful
write-good.E-Prime = NO
```

The style definitions live in a `~/.vale/` folder.

### Prettier

[Prettier][prettier] is a code formatter that can be used for Markdown files. It
should be run as a pre-save fixer by Ale.

[prettier]: https://prettier.io/

As with Markdownlint and Vale, it will look for a config file in the current
folder and all parents. Again, it's worthwhile having a fallback config file in
your home directory if nothing is provided by the project:

```yaml
#  ~/.prettierrc.yaml
overrides:
  - files:
      - "*.md"
      - "*.markdown"
    options:
      proseWrap: "always"
```

Beware the `proseWrap` option. If a project doesn't use it already, every edit
you do will reformat the file leading to large diffs. It often makes sense to
set it to `preserve` in such projects until the project can be switched
wholesale to hard wrapping Markdown.

<!-- LITERATURE REVIEW

Posts:

https://vim.works/2019/03/16/using-markdown-in-vim/
- talks about the appearance of Markdown in Vim - e.g. conceallevel
- highlights some other plugins

Videos:

https://www.youtube.com/watch?v=cWiTg-ItdwA

Plugins I don't use:

- https://github.com/SidOfc/mkdx

-->
