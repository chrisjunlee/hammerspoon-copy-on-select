-- Copy-on-select for macOS, scoped per-app.
-- Drag to select text in an enabled app, and the selection is auto-copied to the clipboard.
--
-- Install: place in ~/.hammerspoon/init.lua (or require from your existing config), then
-- reload Hammerspoon. Add apps to `enabledApps` below.
--
-- To find an app's name, bring it to the foreground and run:
--   sleep 3 && osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'

local dragStart = nil
local dragged = false

local mouseDown = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function(e)
  dragStart = hs.mouse.absolutePosition()
  dragged = false
  return false
end)

local mouseDragged = hs.eventtap.new({hs.eventtap.event.types.leftMouseDragged}, function(e)
  if dragStart then
    local pos = hs.mouse.absolutePosition()
    local dx = pos.x - dragStart.x
    local dy = pos.y - dragStart.y
    if (dx * dx + dy * dy) > 25 then
      dragged = true
    end
  end
  return false
end)

-- Add apps here. Find an app's name with:
--   sleep 3 && osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'
local enabledApps = {
  ["Claude"] = true,  -- replace with your own apps
}

local mouseUp = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(e)
  if dragged then
    local app = hs.application.frontmostApplication():name()
    if enabledApps[app] then
      hs.timer.doAfter(0.05, function()
        hs.eventtap.keyStroke({"cmd"}, "c", 0)
      end)
    end
  end
  dragStart = nil
  dragged = false
  return false
end)

mouseDown:start()
mouseDragged:start()
mouseUp:start()

-- macOS disables an eventtap if a callback ever runs long; restart any that go dead.
local taps = { mouseDown, mouseDragged, mouseUp }
local watchdog = hs.timer.doEvery(5, function()
  for _, t in ipairs(taps) do
    if not t:isEnabled() then t:start() end
  end
end)

hs.alert.show("Copy-on-select armed")
