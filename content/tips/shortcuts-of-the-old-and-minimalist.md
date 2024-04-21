+++
title = "Shortcuts of the old and minimalist"
date = 2017-11-27T12:27:45+01:00
description = "Some quick ways to hide the clutter."
tags = ["productivity"]
+++

As I get older and grumpier, I increasingly value clean, uncluttered working
environments. I'm sure I'm not the only one, so here's a few useful practices
and shortcuts that help me avoid using the mouse and satisfy my need for
productivity micro-optimisation.

They are mainly for macOS users.

## Hide everything

Adjust your system preferences to automatically hide the Dock and menu bar
(there's a checkbox in "General").

With these two changes, a maximised window is effectively full-screen. Hit
<span class="keys">CTRL</span>&nbsp;+&nbsp;<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">F</span>
to _officially_ enter full-screen mode and you'll barely notice the difference.

Beware though: hiding the menu bar has a couple of downsides:

- It's not obvious at a glance which application has focus, nor what the time is
  (I don't wear a watch).

- The
  <span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">\\</span>
  shortcut to open the 1Password desktop widget _sometimes_ fails to work when
  the menu bar is hidden[^1password].

[^1password]:
    As of v6.8.3: I've been unable to determine the exact steps to recreate
    this.

It's still worth it.

Hiding the Dock has no downsides assuming you use
[Alfred](https://www.alfredapp.com/) to open applications.

## A blank desktop

Keep `~/Desktop` clear so that, combined with the above tips, your default view
is something like this:

{{< figure src="/images/shortcuts/desktop.png" title="My default view: no menu-bar, no Dock: just an empty felt-table." >}}

Scratch files live somewhere less visually intrusive (like, say, `~/Scratch`).
Let the macOS screen-capture program know of this decision with:

```bash
defaults write com.apple.screencapture location ~/Scratch
```

Digression: any files in `~/Desktop` can be hidden by enabling the "Quit" menu
item for Finder:

```bash
defaults write com.apple.finder QuitMenuItem -bool true
killall Finder
```

then quitting: <span class="keys">⌘</span>&nbsp;+&nbsp;<span
class="keys">Q</span>. This is worth doing if only to remove Finder from the
list of running applications seen with
<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">TAB</span>.

## Marshalling windows

Using the [Spectacle](https://www.spectacleapp.com/) window manager, you can use
<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">C</span>
to centre a window, then
<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">H</span>
to hide all others[^butnotappwindows].

[^butnotappwindows]:
    Annoyingly, this doesn't shut windows from the same application --- which
    would be better.

This allows a clean context switch: dropping all clutter in favour of rapidly
focussing on one app --- generally Chrome (for email), Trello or Slack ---
_very_ useful.

There's also:

- <span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">→</span>
  and
  <span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">←</span>
  for shunting windows between the left- and right-hand half of a display, and;

- <span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">↑</span>
  and
  <span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">↓</span>
  for bumping windows between displays.

Memorise the equivalents for your favourite window manager.

## Marshalling tabs

A verging-on-OCD minimalist like myself minimises both the number of
applications open[^applications] and, within a browser, the number of open tabs.

[^applications]:
    This is a minimal set from those unenlightened days before I realised you
    could quit Finder: {{< tweet user="codeinthehole" id="914965638321405952" >}}

For the latter, there's a
[useful Chrome extension](https://chrome.google.com/webstore/detail/keyboard-shortcuts-to-clo/dkoadhojigekhckndaehenfbhcgfeepl/reviews?hl=en)
that adds two crucial missing keyboard shortcuts.

First:
<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">⇧</span>&nbsp;+&nbsp;<span class="keys">O</span>
to "Close Other Tabs"[^chrometabs]. Fortunately, this doesn't close _pinned_
tabs so you can protect your core web-apps (eg Gmail, Calendar,
[rain noise](https://rain.today)) with the second shortcut this extension
provides:
<span class="keys">⌥</span>&nbsp;+&nbsp;<span class="keys">⇧</span>&nbsp;+&nbsp;<span class="keys">P</span>,
which pins the current tab.

[^chrometabs]:
    There's no native shortcut for this and using the mouse/trackpad to
    right-click on the tab is too labour-intensive.

Finally it's sometimes useful to full-screen an individual tab for the complete
"zen"-mode experience. Do this with
<span class="keys">CTRL</span>&nbsp;+&nbsp;<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">F</span>
(to full-screen the window) followed by
<span class="keys">⇧</span>&nbsp;+<span class="keys">⌘</span>&nbsp;+&nbsp;<span class="keys">F</span>.
A good use-case for this is reviewing Github pull requests but any site that
uses a fixed-width container would work well.

<br/>

Further reading:
[Area Man Knows All The Shortcut Keys](https://www.theonion.com/area-man-knows-all-the-shortcut-keys-1819566989).
