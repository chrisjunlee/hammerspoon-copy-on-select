# hammerspoon-copy-on-select

*Linux-style copy-on-select for macOS, scoped per-app, via Hammerspoon.*

## Why

Enables copy-on-select in apps like Claude Desktop: drag to highlight text, and the selection lands in your clipboard automatically. As of April 2026, Claude Desktop has no setting to turn this on, which is why I wrote the script. Linux (X11) does it natively and macOS browsers do it too, but most Mac apps, especially Electron ones like Claude Desktop, offer no way to enable it. This script fills that gap, per-app, so you can enable it where you want it and leave it off where you do not.

## Install

1. Install [Hammerspoon](https://www.hammerspoon.org):

   ```bash
   brew install --cask hammerspoon
   ```

2. Drop the script into your Hammerspoon config:

   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   If you already have a `~/.hammerspoon/init.lua`, append or require this file instead of overwriting it.

3. Reload Hammerspoon: click the menubar icon and choose **Reload Config**. You should see a brief "Copy-on-select armed" notification.

## Configure

Open `~/.hammerspoon/init.lua` and edit the `enabledApps` table:

```lua
local enabledApps = {
  ["Claude"] = true,  -- replace with your own apps
}
```

To find the exact name Hammerspoon uses for an app, bring it to the foreground and run:

```bash
sleep 3 && osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
```

## How it works

Three `hs.eventtap` listeners watch for `leftMouseDown`, `leftMouseDragged`, and `leftMouseUp` events. On `mouseDown`, the cursor position is recorded. On `mouseDragged`, the distance from the origin is checked: if it exceeds 5 pixels (Euclidean), a flag is set. On `mouseUp`, if the flag is set and the frontmost app is in `enabledApps`, Hammerspoon fires Cmd+C after a 50 ms delay (enough time for the OS to finalize the selection). Plain clicks never move the cursor more than 5 pixels, so they do not trigger the copy.

## Limitations

- Double-click word selection and triple-click line selection are not detected. The drag threshold only fires on actual mouse drags, and the Accessibility API approach that would catch those selections is unreliable in Electron apps (see Prior art).
- Any drag operation in an enabled app, not just text selection, will trigger Cmd+C. In most cases this is a harmless no-op (nothing is selected), but it is not impossible for it to overwrite the clipboard at an inopportune moment.
- If Hammerspoon does not have Accessibility permissions, the eventtap listeners will not receive events. Grant them in System Settings under Privacy and Security.

## Prior art

- [Hammerspoon issue #2196](https://github.com/Hammerspoon/hammerspoon/issues/2196) (2019): someone asked exactly this question; the issue was closed with zero replies.
- [Keyboard Maestro forum thread](https://forum.keyboardmaestro.com/t/how-automatically-copy-selected-text-to-the-clipboard/35808): community discussion that concluded the problem was difficult to solve cleanly and fell back to programmable mouse hardware as a workaround.
- [David Balatero: Retrieving input field values with Hammerspoon](https://balatero.com/writings/hammerspoon/retrieving-input-field-values-and-cursor-position-with-hammerspoon/): explains why the Accessibility API approach that would catch double- and triple-click selections breaks in Electron apps specifically.

## License

MIT
