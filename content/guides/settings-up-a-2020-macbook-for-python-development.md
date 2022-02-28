+++
title = "Setting up a 2020 MacBook Pro for Python development"
date = 2020-07-19T00:00:00+01:00
description = "A note to self."
tags = ["macos", "python"]
+++

<!-- Introduction -->

This is a note-to-self on setting up a 2020 13-inch MacBook Pro, largely for
Python development. I imagine it will all be out-of-date by the time I set-up my
next laptop but it's possible it might be useful to someone in the meantime.

<!-- Main content -->

## Applications

I don't tend to use Homebrew Cask and suffer the indignity of either installing
them from the App Store or downloading `.dmg` files and dragging them into
`/Applications`.

## From the App Store

There's only a few of these that I use:

- [Bear](https://apps.apple.com/gb/app/bear/id1016366447) --- my Bear notes are
  now my most valuable possession.
- [Trello](https://apps.apple.com/gb/app/trello-organize-anything/id461504587)
  --- by far my favourite workflow management app.
- [Microsoft To Do](https://apps.apple.com/gb/app/microsoft-to-do/id1212616790)
  --- successor to Wunderlist.
- [Slack](https://apps.apple.com/gb/app/slack/id618783545)
- [Outline VPN client](https://apps.apple.com/us/app/outline-app/id1356177741)

## Downloaded and dragged into `/Applications`

In rough order of usefulness:

- [Alfred](https://www.alfredapp.com/) --- install this
  [Bear workflow](https://github.com/drgrib/alfred-bear) and ensure it's
  configured to search Chrome bookmarks.
- [MacVim](https://github.com/macvim-dev/macvim/releases/) --- install from
  Github to get the latest version.
- [iTerm2](https://www.iterm2.com/)
- [Chrome](https://www.google.co.uk/chrome/)
- [1Password](https://1password.com/) (deliberately not from the App Store as
  such versions don't support the QR code reader functionality)
- [Spectacle](https://www.spectacleapp.com/)
- [Spotify](https://www.spotify.com/uk/download/other/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Postgres.app](https://postgresapp.com/downloads.html)
- [Zoom](https://zoom.us/)
- [Dropbox](https://www.dropbox.com/)
- [Basecamp](https://basecamp.com/via)
- [Vagrant](https://www.vagrantup.com/)

## Homebrew formulae

Homebrew is best reserved for core system packages, where running the latest
version is desirable. It's less appropriate for project dependencies which
require pinned versions --- Docker is a better for that.

Start by installing Xcode's command-line tools:

```bash
sudo xcode-select --install
```

then [install Homebrew](https://brew.sh/) and a core set of formulae. The
following is taken from a `setup_new_macbook.sh` script I use:

```bash
function install_homebrew_core_packages() {
    local packages=(
        bash
        bash-completion
        coreutils
        ctags
        fd
        fzf
        git
        graphviz
        htop
        httpie
        hub
        hugo
        imagemagick
        jq
        pgbadger
        pv
        rename
        ripgrep
        terminal_notifier
        the_silver_searcher
    )
    brew install ${packages[@]}
}
```

plus some packages that require a separate `tap`:

```bash
function install_homebrew_tap_packages() {
    brew tap heroku/brew && brew install heroku

    brew tap homebrew/cask-fonts
    local fonts=(
        font-inconsolata
        font-clear-sans
        font-source-code-pro
        font-anonymous-pro
    )
    brew cask install ${fonts[@]}
}
```

Ensure your `~/.bash_profile` has shell completion enabled for Homebrew-installs
packages by following the
[documented instructions](https://docs.brew.sh/Shell-Completion).

## MacOS configuration

It's too dull to go through everything. Here are few notable changes:

### Non-breaking spaces

Unbind <span class="keys">⌥</span> + <span class="keys">SPACE</span> from
inserting a non-breaking space by setting the contents of
`~/Library/KeyBindings/DefaultKeyBinding.dict` to:

```pl
{
    "~ " = ("insertText:", " ");
}
```

This avoids a common annoyance when editing headers in markdown files (eg in
Bear).

### System preferences

Here's a `configurure_system_preferences.sh` script I use:

```bash
#!/usr/bin/env bash
#
# Configure MacOS settings.

set -e

function configure_all() {
    configure_keyboard
    configure_screensaver
    configure_screencapture
    configure_touchpad
}

function configure_keyboard() {
    # Set fast key repeat rate.
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
}

function configure_screensaver() {
    # Require password as soon as screen-saver or sleep mode starts.
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
}

function configure_screencapture() {
    # Disable shadow effect in screen capture.
    defaults write com.apple.screencapture disable-shadow -bool true
}

function configure_touchpad() {
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}

configure_all
```

### Further reading

- [How to set up a new Mac for development](https://twitter.com/searls/status/1264547049032187910) -
  A 90 minute video walking through setting up a MacBook Pro.
- [`osx-for-hackers.sh`](https://gist.github.com/brandonb927/3195465) --- A
  large shell script with a lot of configuration options. This is the
  Yosemite/El Capitan edition -- not everything works in Catalina. It's worth
  browsing though to see if anything takes your fancy.

## Python

General principles:

- Use `pyenv` to manage multiple versions of Python locally, and to stay out of
  the way of the system Python.

- Keep everything in virtualenvs.

- Use `virtualenvwrapper` to provide convenience commands. Mainly as I like to
  switch to a project with `workon`. Indeed, I often create virtualenvs for
  non-Python projects just so I jump to them with `workon` and run some
  initialisation in the `postactivate` script (like changing to the project
  directory and setting the iTerm tab title).

- Use `pipx` to install command-line Python apps like `awscli` that I want
  available globally (i.e. can be run without activating a virtualenv first).

### Python versions

Install `pyenv` and `pyenv-virtualenvwrapper`:

```sh
brew install pyenv pyenv-virtualenvwrapper
```

and ensure these libraries are initialised by adding:

```bash
if which pyenv > /dev/null 2>&1
then
    # Pyenv (will add shims to front of $PATH)
    eval "$(pyenv init -)"

    # Ensure commands from virtualenvwrapper are available, no matter which
    # Python version is active. This is equiv to sourcing virtualenvwrapper.sh
    pyenv virtualenvwrapper
fi
```

to `~/.bash_profile`.

Install a modern Python as the global default:

```sh
pyenv install 3.8.3
pyenv global 3.8.3
```

plus any other Python versions that projects require.

### Python projects

For each Python project, create a virtualenv by selecting the appropriate Python
version using `pyenv` then using `mkvirtualenv`:

```sh
cd $PATH_TO_PROJECT
pyenv local 3.7.7  # for example
mkvirtualenv $PROJECT_NAME
```

To avoid accidentally installing packages outside of a virtualenv, set:

```bash
# Always require a virtualenv to use pip
export PIP_REQUIRE_VIRTUALENV=true
```

in `~/.bash_profile`. If you do want to run `pip` outside of a virtualenv, use
something like:

```sh
PIP_REQUIRE_VIRTUALENV=false pip list
```

### Python command-line apps

Install `pipx` with:

```bash
brew install pipx
```

and ensure `~/.local/bin` is on your `$PATH`.

Install CLI apps:

```bash
pipx install awscli
```

### Further reading

- [My Python Development Environment, 2020 Edition](https://jacobian.org/2019/nov/11/python-environment-2020/)
  by Jacob Kaplan-Moss (2019).
