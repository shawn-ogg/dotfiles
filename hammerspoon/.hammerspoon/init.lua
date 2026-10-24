-- ~/.hammerspoon/init.lua

--------------------------------------------------
-- Hyper Key
--------------------------------------------------
-- Caps Lock -> cmd+ctrl+alt+shift via Karabiner

local hyper = { "cmd", "ctrl", "alt", "shift" }

--------------------------------------------------
-- Helpers
--------------------------------------------------


local function focusChromeTab(pattern, fallbackUrl)
  fallbackUrl = fallbackUrl or pattern

  if not fallbackUrl:match("^https?://") then
    fallbackUrl = "https://" .. fallbackUrl
  end

  return function()
    local script = string.format([[
      tell application "Google Chrome"
        activate

        set foundTab to false

        repeat with w in every window
          set tabIndex to 1

          repeat with t in every tab of w

            try
              set tabUrl to URL of t

              if tabUrl contains "%s" then
                set active tab index of w to tabIndex
                set index of w to 1
                set foundTab to true
                exit repeat
              end if
            end try

            set tabIndex to tabIndex + 1

          end repeat

          if foundTab then
            exit repeat
          end if
        end repeat

        if not foundTab then
          open location "%s"
        end if

        activate
      end tell
    ]], pattern, fallbackUrl)

    hs.osascript.applescript(script)
  end
end

--------------------------------------------------
-- Dynamic Dock App Launchers
--------------------------------------------------
-- Option + 1..9 = Dock apps 1..9
-- Option + 0    = Dock app 10
-- Option + grave / § = show the current Dock mapping
--
-- The mapping is read from the Dock preferences each time, so reordering
-- pinned apps in the Dock automatically changes the shortcuts.

local dockAppsCache = nil

local function readDockApps()
  local xml = hs.execute(
    '/usr/bin/plutil -convert xml1 -o - "$HOME/Library/Preferences/com.apple.dock.plist"',
    true
  )

  if not xml or xml == "" then
    hs.alert.show("Could not read Dock preferences")
    return {}
  end

  local ok, dock = pcall(hs.plist.readString, xml)
  if not ok or type(dock) ~= "table" then
    hs.alert.show("Could not parse Dock preferences")
    return {}
  end

  -- Finder is always shortcut 1, even if its Dock plist entry is represented
  -- differently by macOS. Remaining shortcuts follow the pinned Dock order.
  local apps = {
    { id = "com.apple.finder", name = "Finder" }
  }
  local seen = { ["com.apple.finder"] = true }

  for _, item in ipairs(dock["persistent-apps"] or {}) do
    local tile = item["tile-data"] or {}
    local bundleID = tile["bundle-identifier"]
    local label = tile["file-label"]

    -- Count pinned application icons only; skip Finder here because it is
    -- explicitly inserted at position 1 above.
    if bundleID and bundleID ~= "" and not seen[bundleID] then
      seen[bundleID] = true
      table.insert(apps, {
        id = bundleID,
        name = (label and label ~= "" and label) or bundleID
      })
    end
  end

  return apps
end

-- Cache the parsed Dock mapping so the plutil shell exec doesn't run on every
-- Alt+number press. The pathwatcher below invalidates the cache whenever the
-- Dock plist changes (e.g. you reorder pinned apps), so reordering still
-- propagates automatically.
local function getDockApps()
  if not dockAppsCache then
    dockAppsCache = readDockApps()
  end
  return dockAppsCache
end

hs.pathwatcher
  .new(os.getenv("HOME") .. "/Library/Preferences/com.apple.dock.plist", function()
    dockAppsCache = nil
  end)
  :start()

local function showDockMapping()
  local apps = getDockApps()
  local lines = { "Dock app shortcuts" }

  for i, app in ipairs(apps) do
    local assignment
    if i <= 9 then
      assignment = "⌥" .. tostring(i)
    elseif i == 10 then
      assignment = "⌥0"
    else
      assignment = "—"
    end
    table.insert(lines, string.format("%-5s %s", assignment, app.name))
  end

  if #apps == 0 then
    table.insert(lines, "No pinned Dock apps found")
  elseif #apps > 10 then
    table.insert(lines, "Only the first 10 apps have shortcuts")
  end

  hs.alert.closeAll()
  hs.alert.show(table.concat(lines, "\n"), 5)
end

local function chooseAppWindow(app, appName)
  local windows = {}
  for _, win in ipairs(app:allWindows()) do
    if win:isStandard() then
      table.insert(windows, win)
    end
  end

  if #windows == 0 then
    app:activate()
    hs.alert.show(appName, 0.8)
    return
  end

  if #windows == 1 then
    app:activate()
    windows[1]:focus()
    hs.alert.show(appName, 0.8)
    return
  end

  local choices = {}
  for _, win in ipairs(windows) do
    local title = win:title()
    if not title or title == "" then
      title = "Untitled window"
    end
    table.insert(choices, {
      text = title,
      subText = appName,
      uuid = tostring(win:id())
    })
  end

  local chooser = hs.chooser.new(function(choice)
    if not choice then return end
    local win = hs.window.get(tonumber(choice.uuid))
    if win then
      local owner = win:application()
      if owner then owner:activate() end
      win:focus()
    end
  end)

  chooser:choices(choices)
  chooser:rows(math.min(10, #choices))
  chooser:show()
end


local function activateDockApp(position, showSelector)
  local apps = getDockApps()
  local target = apps[position]

  if not target then
    hs.alert.show("No app at Dock position " .. position)
    return
  end

  local app = hs.application.get(target.id)

  if not app then
    hs.application.launchOrFocusByBundleID(target.id)

    -- Finder may launch without opening a window.
    if target.name == "Finder" then
      hs.timer.doAfter(0.3, function()
        local finder = hs.application.get(target.id)
        if finder and #finder:allWindows() == 0 then
          hs.osascript.applescript([[
            tell application "Finder"
              make new Finder window
              activate
            end tell
          ]])
        end
      end)
    end

    hs.alert.show(target.name, 0.8)
    return
  end

  app:activate()

  if target.name == "Finder" then
    hs.timer.doAfter(0.15, function()
      local finder = hs.application.get(target.id)
      if finder and #finder:allWindows() == 0 then
        hs.osascript.applescript([[
          tell application "Finder"
            make new Finder window
            activate
          end tell
        ]])
      end

      if showSelector then
        local activeApp = hs.application.get(target.id)
        if activeApp then
          chooseAppWindow(activeApp, target.name)
        end
      end
    end)
  elseif showSelector then
    -- Let macOS activate the app before collecting its windows.
    hs.timer.doAfter(0.15, function()
      local activeApp = hs.application.get(target.id)
      if activeApp then
        chooseAppWindow(activeApp, target.name)
      end
    end)
  else
    hs.alert.show(target.name, 0.8)
  end
end

-- Option + number activates the app assigned to that Dock position.
-- It never hides the app.
for i = 1, 9 do
  hs.hotkey.bind({ "alt" }, tostring(i), function()
    activateDockApp(i, false)
  end)
end

hs.hotkey.bind({ "alt" }, "0", function()
  activateDockApp(10, false)
end)

-- Option + Shift + number opens the window selector for that Dock app.
for i = 1, 9 do
  hs.hotkey.bind({ "alt", "shift" }, tostring(i), function()
    activateDockApp(i, true)
  end)
end

hs.hotkey.bind({ "alt", "shift" }, "0", function()
  activateDockApp(10, true)
end)

--------------------------------------------------
-- Chrome bookmarks chooser
--------------------------------------------------

local json = hs.json

local bookmarks_path =
  os.getenv("HOME")
  .. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

local bookmarksCache = nil

local function readBookmarks()
  local file = io.open(bookmarks_path, "r")

  if not file then
    hs.alert.show("Could not open Chrome bookmarks")
    return {}
  end

  local content = file:read("*a")
  file:close()

  local data = json.decode(content)

  local results = {}

  local function walk(node)
    if not node then return end

    if node.type == "url" then
      table.insert(results, {
        text = node.name,
        subText = node.url,
        url = node.url,
      })
    end

    if node.children then
      for _, child in ipairs(node.children) do
        walk(child)
      end
    end
  end

  walk(data.roots.bookmark_bar)
  walk(data.roots.other)
  walk(data.roots.synced)

  return results
end

-- Cache the parsed bookmarks so the full file read + JSON decode doesn't run on
-- every Hyper+W w. The pathwatcher invalidates the cache when Chrome rewrites
-- the Bookmarks file (e.g. you add/remove a bookmark).
local function loadBookmarks()
  if not bookmarksCache then
    bookmarksCache = readBookmarks()
  end
  return bookmarksCache
end

hs.pathwatcher
  .new(bookmarks_path, function()
    bookmarksCache = nil
  end)
  :start()

local bookmarkChooser = hs.chooser.new(function(choice)
  if not choice then return end
  focusChromeTab(choice.url, choice.url)()
end)

bookmarkChooser:searchSubText(true)
bookmarkChooser:rows(12)

--------------------------------------------------
-- Web modal + chooser
--------------------------------------------------

local webActions = {
  { key = "g", text = "[g] SAP Github",              subText = "github.tools.sap",        fn = focusChromeTab("github.tools.sap", "https://github.tools.sap/Data-Platform-Engineering") },
  { key = "c", text = "[c] ChatGPT",                 subText = "chatgpt.com",             fn = focusChromeTab("chatgpt.com") },
  { key = "a", text = "[a] AWS Console",             subText = "console.aws.amazon.com",  fn = focusChromeTab("console.aws.amazon.com", "https://aghki5i5k.accounts400.ondemand.com/saml2/idp/sso?sp=urn:amazon:webservices") },
  { key = "j", text = "[j] Jira Data Pipeline",      subText = "rapidView=943",           fn = focusChromeTab("https://securityjira.wbs.only.sap/secure/RapidBoard.jspa?rapidView=943&projectKey=DPE") },
  { key = "l", text = "[l] SAP Launchpad",           subText = "GenAIXL-Display",         fn = focusChromeTab("https://sapit-home-prod-004.launchpad.cfapps.eu10.hana.ondemand.com/site#GenAIXL-Display?mobilestart.tile.hidden=true") },
  { key = "b", text = "[b] Bookmarks",               subText = "github.tools.sap/D069147/bookmarks", fn = focusChromeTab("https://github.tools.sap/D069147/bookmarks") },
  { key = "w", text = "[w] Bookmark Chooser",        subText = "Search Chrome bookmarks", fn = function()
    bookmarkChooser:choices(loadBookmarks())
    bookmarkChooser:show()
  end },
}

local webChooser = hs.chooser.new(function(choice)
  if not choice then return end
  for _, item in ipairs(webActions) do
    if item.key == choice.uuid then
      item.fn()
      return
    end
  end
end)

webChooser:searchSubText(true)
webChooser:rows(#webActions)

local web = hs.hotkey.modal.new()

function web:entered()
  local choices = {}
  for _, item in ipairs(webActions) do
    table.insert(choices, { text = item.text, subText = item.subText, uuid = item.key })
  end
  webChooser:choices(choices)
  webChooser:show()
end

function web:exited()
  webChooser:hide()
end

hs.hotkey.bind(hyper, "w", function()
  web:enter()
end)

web:bind({}, "escape", function()
  web:exit()
end)

for _, item in ipairs(webActions) do
  local mods = {}
  local k = item.key
  if k == k:upper() and k ~= k:lower() then
    mods = { "shift" }
    k = k:lower()
  end
  local fn = item.fn
  web:bind(mods, k, function()
    web:exit()
    fn()
  end)
end

--------------------------------------------------
-- Sesh / tmux launcher
--------------------------------------------------

hs.hotkey.bind(hyper, "space", function()
  hs.application.launchOrFocus("WezTerm")

  hs.timer.doAfter(0.1, function()
    hs.execute(
      "/bin/bash -lc \"/opt/homebrew/bin/wezterm cli send-text --no-paste $'\\x01s'\""
    )
  end)
end)

hs.hotkey.bind(hyper, "s", function()
  hs.application.launchOrFocus("WezTerm")

  hs.timer.doAfter(0.1, function()
    hs.execute(
      "/bin/bash -lc \"/opt/homebrew/bin/wezterm cli send-text --no-paste $'\\x01\\x13'\""
    )
  end)
end)

--------------------------------------------------
-- Hyper+t -> Teams status changer
--------------------------------------------------

local function typeKeys(text, delay)
    delay = delay or 0.005

    for i = 1, #text do
        local char = text:sub(i, i)

        hs.timer.doAfter(i * delay, function()
            hs.eventtap.keyStroke({}, char)
        end)
    end
end

local function teamsStatus(status)
    local app = hs.application.find("Microsoft Teams")
    local alreadyFocused = app and app:isFrontmost()

    hs.application.launchOrFocus("Microsoft Teams")

    local focusDelay = alreadyFocused and 0.05 or 0.5

    hs.timer.doAfter(focusDelay, function()
        hs.eventtap.keyStroke({"cmd"}, "e")

        hs.timer.doAfter(0.05, function()
            hs.eventtap.keyStroke({"cmd"}, "a")
            hs.eventtap.keyStroke({}, "delete")
            hs.eventtap.keyStroke({}, "/")

            hs.timer.doAfter(0.05, function()
                typeKeys(status)

                hs.timer.doAfter(#status * 0.005 + 0.01, function()
                    hs.eventtap.keyStroke({}, "return")
                end)
            end)
        end)
    end)
end

local teamsActions = {
  { key = "o", text = "[o] Offline",   status = "offline" },
  { key = "a", text = "[a] Available", status = "available" },
  { key = "d", text = "[d] DND",       status = "dnd" },
  { key = "b", text = "[b] Busy",      status = "busy" },
  { key = "r", text = "[r] BRB",       status = "brb" },
  { key = "w", text = "[w] Away",      status = "away" },
}

local sharingBarHidden = false
local sharingBarFrame = nil

local function toggleSharingBar()
  local app = hs.application.find("Microsoft Teams")
  if not app then
    hs.alert.show("Teams not running")
    return
  end
  for _, win in ipairs(app:allWindows()) do
    local title = win:title()
    if title and title:match("Sharing control bar") then
      if sharingBarHidden then
        if sharingBarFrame then win:setFrame(sharingBarFrame) end
        sharingBarHidden = false
        hs.alert.show("Sharing bar restored")
      else
        sharingBarFrame = win:frame()
        win:setFrame({ x = -2000, y = 100, w = sharingBarFrame.w, h = sharingBarFrame.h })
        sharingBarHidden = true
        hs.alert.show("Sharing bar hidden")
      end
      return
    end
  end
  hs.alert.show("Sharing bar not found")
end

local teamsChooser = hs.chooser.new(function(choice)
  if not choice then return end
  if choice.uuid == "h" then
    toggleSharingBar()
    return
  end
  for _, item in ipairs(teamsActions) do
    if item.key == choice.uuid then
      teamsStatus(item.status)
      return
    end
  end
end)

teamsChooser:rows(#teamsActions + 1)

local teamsModal = hs.hotkey.modal.new(hyper, "t")

function teamsModal:entered()
  local choices = {}
  for _, item in ipairs(teamsActions) do
    table.insert(choices, { text = item.text, uuid = item.key })
  end
  table.insert(choices, { text = "[h] Hide/restore sharing bar", uuid = "h" })
  teamsChooser:choices(choices)
  teamsChooser:show()
end

function teamsModal:exited()
  teamsChooser:hide()
end

teamsModal:bind({}, "escape", function()
  teamsModal:exit()
end)

for _, item in ipairs(teamsActions) do
  local status = item.status
  teamsModal:bind({}, item.key, function()
    teamsModal:exit()
    teamsStatus(status)
  end)
end

teamsModal:bind({}, "h", function()
  teamsModal:exit()
  toggleSharingBar()
end)

--------------------------------------------------
-- Show Hotkeys
--------------------------------------------------
local hotkeys = {
    {"Alt+1..9 / 0", "Activate Dock app by position"},
    {"Alt+Shift+1..9 / 0", "Choose a window for Dock app"},
    {"Alt+grave / §", "Show Dock app assignments"},
    {"Hyper+S", "Sesh / tmux Create New Session"},
    {"Hyper+Space", "Sesh / tmux"},
    {"Hyper+W g", "Google"},
    {"Hyper+W c", "ChatGPT"},
    {"Hyper+W a", "AWS Console"},
    {"Hyper+W j", "Jira Data Pipeline Board"},
    {"Hyper+W J", "Jira Security Analytics Board"},
    {"Hyper+W l", "SAP Launchpad"},
    {"Hyper+W b", "Bookmarks"},
    {"Hyper+W w", "Bookmark Chooser"},
    {"Hyper+T o", "Teams: Offline"},
    {"Hyper+T a", "Teams: Available"},
    {"Hyper+T d", "Teams: DND"},
    {"Hyper+T b", "Teams: Busy"},
    {"Hyper+T r", "Teams: BRB"},
    {"Hyper+T w", "Teams: Away"},
    {"Hyper+T h", "Teams: Hide/restore sharing bar"},
    {"Hyper+r",   "Reload Hammerspoon"},
    {"Hyper+v", "TMUX vertical split"},
    {"Hyper+b", "TMUX horizontal split"},
    {"Hyper+z", "TMUX zoom pane"},
    {"Hyper+x", "TMUX close pane"},
    {"Hyper+n", "TMUX next tmux window"},
    {"Hyper+p", "TMUX previous tmux window"},
    {"Hyper+c", "TMUX create tmux window"},
    {"Cmd+h",   "Show Help"}
}

local cheatSheetStyle = {
    textSize = 14,
    radius = 12,
    fillColor = {
        white = 0,
        alpha = 0.85
    },
    strokeColor = {
        white = 1,
        alpha = 0
    },
    textColor = {
        white = 1,
        alpha = 1
    },
    atScreenEdge = 2,
}

local cheatSheetModal = hs.hotkey.modal.new()

local function showHotkeys()
    local lines = {}

    for _, item in ipairs(hotkeys) do
        table.insert(lines, string.format("%-15s %s", item[1], item[2]))
    end

    hs.alert.closeAll()

    hs.alert.show(table.concat(lines, "\n"), cheatSheetStyle, math.huge)

    cheatSheetModal:enter()
end

cheatSheetModal:bind({}, "escape", function()
    hs.alert.closeAll()
    cheatSheetModal:exit()
end)

hs.hotkey.bind({ "cmd" }, "h", showHotkeys)

-- Option + § / `: bind both layout variants directly. A plain hotkey bind only
-- fires on this exact combo, unlike a global keyDown eventtap which would run a
-- Lua callback on every keystroke typed system-wide.
hs.hotkey.bind({ "alt" }, "§", showDockMapping)
hs.hotkey.bind({ "alt" }, "`", showDockMapping)

--------------------------------------------------
-- Reload Hammerspoon
--------------------------------------------------

hs.hotkey.bind(hyper, "r", function()
  hs.reload()
end)

--------------------------------------------------
-- Auto Reload On Config Save
--------------------------------------------------

local function reloadConfig(files)
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end

hs.pathwatcher
  .new(os.getenv("HOME") .. "/dotfiles/hammerspoon", reloadConfig)
  :start()

--------------------------------------------------
-- Load difm global mute shortcut
--------------------------------------------------
dofile(hs.configdir .. "/difm.lua")

--------------------------------------------------
-- Load display configuration
--------------------------------------------------
require("display")

--------------------------------------------------
-- Startup Notification
--------------------------------------------------

hs.alert.show("Hammerspoon loaded")

