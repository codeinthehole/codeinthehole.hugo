+++
title = "Tips for using Github Copilot in Vim"
date = 2023-01-06T12:07:03Z
description = "Two recommendations for using Copilot effectively."
tags = ["Vim", "Github Copilot"]
+++

<!-- INTRODUCTION -->

Based on a few weeks of using [`vim-copilot`][vim_copilot], I recommend the
following:

<!-- CONTENT -->

1. Enable Copilot for the `gitcommit`, `markdown` and `yaml` filetypes:

   ```viml
   let g:copilot_filetypes = {
       \ 'gitcommit': v:true,
       \ 'markdown': v:true,
       \ 'yaml': v:true
       \ }
   ```

   By default, [these and few others are disabled][copilot_disabled_filetypes]
   but I've found them to be useful. It's often amusing to see Copilot's
   attempts to complete your commit messages.

2. Disable Copilot for large files as it can be slow and impair the editing
   experience:

   ```viml
    autocmd BufReadPre *
        \ let f=getfsize(expand("<afile>"))
        \ | if f > 100000 || f == -2
        \ | let b:copilot_enabled = v:false
        \ | endif
   ```

   This [autocommand][autocmd] disables Copilot for files larger than 100KB. See
   my [related TIL post][til_disable] for more details on this.

[vim_copilot]: https://github.com/github/copilot.vim
[til_disable]: https://til.codeinthehole.com/posts/how-to-automatically-disable-github-copilot-in-vim-when-editing-large-files/
[copilot_disabled_filetypes]: https://github.com/github/copilot.vim/blob/324ec9eb69e20971b58340d0096c3caac7bc2089/autoload/copilot.vim#L123-L132
[autocmd]: https://learnvimscriptthehardway.stevelosh.com/chapters/12.html
