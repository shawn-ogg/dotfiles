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
-- Shared application launcher
--------------------------------------------------
-- Option + 1..9 selects configured apps 1..9; Option + 0 selects app 10.
-- The shared mapping is maintained in ~/dotfiles/app-launcher/apps.ini.
-- Empty ("-") platform entries are intentionally left unbound.

local appConfigPath = os.getenv("HOME") .. "/dotfiles/app-launcher/apps.ini"
local appConfig = {}

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function readAppConfig()
  local file = io.open(appConfigPath, "r")
  if not file then
    hs.alert.show("Could not open " .. appConfigPath)
    return {}
  end

  local config = {}
  local section = nil

  for line in file:lines() do
    line = trim(line)
    if line ~= "" and not line:match("^[;#]") then
      local newSection = line:match("^%[(.-)%]$")
      if newSection then
        section = newSection
        config[section] = {}
      elseif section then
        local key, value = line:match("^([%w_]+)%s*=%s*(.-)%s*$")
        if key then
          config[section][key] = value
        end
      end
    end
  end

  file:close()
  return config
end

appConfig = readAppConfig()

local function activateConfiguredApp(position)
  local target = appConfig[position]
  local bundleID = target and target.macos

  if not bundleID or bundleID == "" or bundleID == "-" then
    return
  end

  local appName = target.name or bundleID
  local app = hs.application.get(bundleID)

  if app and app:isFrontmost() then
    if bundleID == "com.apple.finder" and #app:allWindows() == 0 then
      hs.osascript.applescript([[
        tell application "Finder"
          make new Finder window
          activate
        end tell
      ]])
    end
    return
  end

  if not app then
    -- Wait for the application to launch and create its first window. This
    -- avoids returning from the shortcut before slower apps are ready.
    app = hs.application.open(bundleID, 5, true)
    if not app then
      hs.alert.show("Could not launch " .. appName .. " (" .. bundleID .. ")")
      return
    end
  end

  app:activate()
  local mainWindow = app:mainWindow()
  if mainWindow then
    mainWindow:focus()
  end

  -- Finder can be running without a window. Selecting it should still produce
  -- a useful foreground Finder window rather than appearing to do nothing.
  if bundleID == "com.apple.finder" then
    hs.timer.doAfter(0.2, function()
      local finder = hs.application.get(bundleID)
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

end

for i = 1, 9 do
  local position = tostring(i)
  hs.hotkey.bind({ "alt" }, position, function()
    activateConfiguredApp(position)
  end)
end

hs.hotkey.bind({ "alt" }, "0", function()
  activateConfiguredApp("0")
end)

local function showAppMapping()
  local lines = { "Application shortcuts" }
  local positions = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

  for _, position in ipairs(positions) do
    local target = appConfig[position] or {}
    local name = target.name or "Unassigned"
    local app = target.macos
    if not app or app == "-" or app == "" then
      name = name .. " (empty)"
    end
    table.insert(lines, string.format("⌥%-2s %s", position, name))
  end

  hs.alert.closeAll()
  hs.alert.show(table.concat(lines, "\n"), 5)
end

hs.pathwatcher
  .new(appConfigPath, function()
    hs.reload()
  end)
  :start()

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
    {"Alt+1..9 / 0", "Activate configured application"},
    {"Alt+grave / §", "Show application assignments"},
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
hs.hotkey.bind({ "alt" }, "§", showAppMapping)
hs.hotkey.bind({ "alt" }, "`", showAppMapping)

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

