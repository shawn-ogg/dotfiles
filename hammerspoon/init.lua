-- ~/.hammerspoon/init.lua

--------------------------------------------------
-- Hyper Key
--------------------------------------------------
-- Caps Lock -> cmd+ctrl+alt+shift via Karabiner

local hyper = { "cmd", "ctrl", "alt", "shift" }

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function launch(app)
  return function()
    hs.application.launchOrFocus(app)
  end
end

-- function focusApp(name)
--   return function()
--     local app = hs.application.find(name)
--
--     if app then
--       app:unhide()
--       app:activate(true)
--
--       for _, win in ipairs(app:allWindows()) do
--         win:unminimize()
--       end
--     else
--       hs.application.launchOrFocus(name)
--     end
--   end
-- end
--
-- local function key(k)
--   return function()
--     hs.eventtap.keyStroke({}, k)
--   end
-- end

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
-- App Launchers
--------------------------------------------------

hs.hotkey.bind("alt", "1", launch("Google Chrome"))
hs.hotkey.bind("alt", "2", launch("WezTerm"))
hs.hotkey.bind("alt", "3", launch("Visual Studio Code"))
hs.hotkey.bind("alt", "4", launch("Finder"))
hs.hotkey.bind("alt", "5", launch("Preview"))
hs.hotkey.bind("alt", "7", launch("Microsoft PowerPoint"))
hs.hotkey.bind("alt", "8", launch("Microsoft Excel"))
hs.hotkey.bind("alt", "9", launch("Microsoft Teams"))
hs.hotkey.bind("alt", "0", launch("Microsoft Outlook"))

-- hs.hotkey.bind({ "alt", "shift" }, "1", focusApp("Google Chrome"))
-- hs.hotkey.bind({ "alt", "shift" }, "2", focusApp("WezTerm"))
-- hs.hotkey.bind({ "alt", "shift" }, "3", focusApp("Visual Studio Code"))
-- hs.hotkey.bind({ "alt", "shift" }, "4", focusApp("Finder"))
-- hs.hotkey.bind({ "alt", "shift" }, "5", focusApp("Preview"))
-- hs.hotkey.bind({ "alt", "shift" }, "7", focusApp("Microsoft PowerPoint"))
-- hs.hotkey.bind({ "alt", "shift" }, "8", focusApp("Microsoft Excel"))
-- hs.hotkey.bind({ "alt", "shift" }, "9", focusApp("Microsoft Teams"))
-- hs.hotkey.bind({ "alt", "shift" }, "0", focusApp("Microsoft Outlook"))
--------------------------------------------------
-- Chrome bookmarks chooser
--------------------------------------------------

local json = hs.json

local bookmarks_path =
  os.getenv("HOME")
  .. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

local function loadBookmarks()
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

local bookmarkChooser = hs.chooser.new(function(choice)
  if not choice then
    return
  end

  --hs.execute("open '" .. choice.url .. "'")
  focusChromeTab(choice.url, choice.url)()

end)

bookmarkChooser:searchSubText(true)
bookmarkChooser:rows(12)


--------------------------------------------------
-- Web modal
--------------------------------------------------

local web = hs.hotkey.modal.new()

hs.hotkey.bind(hyper, "w", function()
  web:enter()
  hs.alert.show("Web")
end)

web:bind({}, "escape", function()
  web:exit()
end)

web:bind({}, "g", function()
  focusChromeTab(
    "google.com"
  )()

  web:exit()
end)

web:bind({}, "l", function()
  focusChromeTab(
    "https://sapit-home-prod-004.launchpad.cfapps.eu10.hana.ondemand.com/site#GenAIXL-Display?mobilestart.tile.hidden=true"
  )()

  web:exit()
end)

-- w c -> ChatGPT
web:bind({}, "c", function()
  focusChromeTab(
    "chatgpt.com"
  )()

  web:exit()
end)

web:bind({}, "j", function()
  focusChromeTab(
    --"Data Pipeline Board",
    "https://securityjira.wdf.sap.corp/secure/RapidBoard.jspa?rapidView=508&projectKey=DPE#"
  )()

  web:exit()
end)

web:bind({"shift"}, "j", function()
  focusChromeTab(
    "https://securityjira.wdf.sap.corp/secure/RapidBoard.jspa?rapidView=527&projectKey=DPE"
  )()

  web:exit()
end)

web:bind({}, "a", function()
  focusChromeTab(
    "console.aws.amazon.com",
    "https://aghki5i5k.accounts400.ondemand.com/saml2/idp/sso?sp=urn:amazon:webservices"
  )()

  web:exit()
end)

web:bind({}, "b", function()
  focusChromeTab(
    "https://github.tools.sap/D069147/bookmarks"
  )()

  web:exit()
end)

web:bind({}, "w", function()
  bookmarkChooser:choices(loadBookmarks())
  bookmarkChooser:show()

  web:exit()
end)

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
-- Hyper+b -> bookmark chooser
--------------------------------------------------
--
-- hs.hotkey.bind(hyper, "b", function()
--   bookmarkChooser:choices(loadBookmarks())
--   bookmarkChooser:show()
-- end)
--

--------------------------------------------------
-- Hyper+t -> Teams status changer
--------------------------------------------------
local teamsModal = hs.hotkey.modal.new(hyper, "t")

local function typeKeys(text, delay)
    delay = delay or 0.03

    for i = 1, #text do
        local char = text:sub(i, i)

        hs.timer.doAfter(i * delay, function()
            hs.eventtap.keyStroke({}, char)
        end)
    end
end

local function teamsStatus(status)
    hs.application.launchOrFocus("Microsoft Teams")

    hs.timer.doAfter(0.5, function()

        -- focus Teams command/search bar
        hs.eventtap.keyStroke({"cmd"}, "e")

        hs.timer.doAfter(0.1, function()

            -- clear existing text
            hs.eventtap.keyStroke({"cmd"}, "a")

            hs.timer.doAfter(0.02, function()
                hs.eventtap.keyStroke({}, "delete")

                hs.timer.doAfter(0.02, function()

                    -- open command mode
                    hs.eventtap.keyStroke({}, "/")

                    hs.timer.doAfter(0.02, function()

                        typeKeys(status)

                        hs.timer.doAfter(#status * 0.02 + 0.02, function()
                            hs.eventtap.keyStroke({}, "return")
                        end)
                    end)
                end)
            end)
        end)
    end)
end

local function bindStatus(key, status)
    teamsModal:bind({}, key, function()
        teamsModal:exit()
        teamsStatus(status)
    end)
end

bindStatus("o", "offline")
bindStatus("a", "available")
bindStatus("d", "dnd")
bindStatus("b", "busy")
bindStatus("r", "brb")
bindStatus("w", "away")

teamsModal:bind({}, "escape", function()
    teamsModal:exit()
end)

function teamsModal:entered()
    hs.alert.show("Teams")
end

function teamsModal:exited()
    hs.alert.closeAll()
end

local sharingBarHidden = false
local sharingBarFrame = nil

local sharingBarHidden = false
local sharingBarFrame = nil

teamsModal:bind({}, "h", function()

    local app = hs.application.find("Microsoft Teams")
    if not app then return end

    for _, win in ipairs(app:allWindows()) do
        local title = win:title()

        if title and title:match("Sharing control bar") then

            if sharingBarHidden then
                -- restore original position
                if sharingBarFrame then
                    win:setFrame(sharingBarFrame)
                end

                sharingBarHidden = false
                hs.alert.show("Sharing bar restored")

            else
                -- remember original position
                sharingBarFrame = win:frame()

                -- absolute hidden position
                win:setFrame({
                    x = -2000,
                    y = 100,
                    w = sharingBarFrame.w,
                    h = sharingBarFrame.h
                })

                sharingBarHidden = true
                hs.alert.show("Sharing bar hidden")
            end

            teamsModal:exit()
            return
        end
    end

    hs.alert.show("Sharing bar not found")
    teamsModal:exit()
end)

--------------------------------------------------
-- Show Hotkeys
--------------------------------------------------
local hotkeys = {
    {"Alt+1", "Google Chrome"},
    {"Alt+2", "WezTerm"},
    {"Alt+3", "Visual Studio Code"},
    {"Alt+4", "Finder"},
    {"Alt+5", "Preview"},
    {"Alt+7", "Microsoft PowerPoint"},
    {"Alt+8", "Microsoft Excel"},
    {"Alt+9", "Microsoft Teams"},
    {"Alt+0", "Microsoft Outlook"},
    {"Hyper+S", "Sesh / tmux Create New Session"},
    {"Hyper+Space", "Sesh / tmux"},
    {"Hyper+W a", "AWS SSO"},
    {"Hyper+W b", "Chrome Bookmarks"},
    {"Hyper+W g", "ChatGPT"},
    {"Hyper+W j", "Jira Data Pipeline Board"},
    {"Hyper+W Shift+j", "Jira Security Analytics Board"},
    {"Hyper+W a", "AWS Console"},
    {"Hyper+T o", "Teams: Offline"},
    {"Hyper+T a", "Teams: Available"},
    {"Hyper+T d", "Teams: DND"},
    {"Hyper+T b", "Teams: Busy"},
    {"Hyper+T r", "Teams: BRB"},
    {"Hyper+T w", "Teams: Away"},
    {"Hyper+R",   "Reload Hammerspoon"},
    {"Hyper+v", "TMUX vertical split"},
    {"Hyper+b", "TMUX horizontal split"},
    {"Hyper+z", "TMUX zoom pane"},
    {"Hyper+x", "TMUX close pane"},
    {"Hyper+n", "TMUX next tmux window"},
    {"Hyper+p", "TMUX previous tmux window"},
    {"Hyper+c", "TMUX create tmux window"},
    {"alt+h",   "Show Help"}
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

-- close cheatsheet only while modal is active
cheatSheetModal:bind({}, "escape", function()
    hs.alert.closeAll()
    cheatSheetModal:exit()
end)

-- Hyper + ?
hs.hotkey.bind(
    { "alt" },
    "h",
    showHotkeys
)



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
-- Startup Notification
--------------------------------------------------

hs.alert.show("Hammerspoon loaded")
