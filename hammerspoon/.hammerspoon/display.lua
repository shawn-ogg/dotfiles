-- Automatic external display positioning
--
-- Known monitors:
--   Leave exactly as macOS has configured them.
--
-- Unknown monitors:
--   Put above the MacBook.
--
-- Requires:
--   brew install displayplacer

local DISPLAYPLACER = "/opt/homebrew/bin/displayplacer"


local function setBlackWallpaper()
    local wallpaper = hs.configdir .. "/black.png"

    if not hs.fs.attributes(wallpaper) then
        local png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGNgYGAAAAAEAAH2FzhVAAAAAElFTkSuQmCC"
        local file = assert(io.open(wallpaper, "wb"))
        file:write(hs.base64.decode(png))
        file:close()
    end

    local path = wallpaper:gsub("\\", "\\\\"):gsub('"', '\\"')
    local script = string.format([[
        tell application "System Events"
            repeat with d in every desktop
                set picture of d to POSIX file "%s"
            end repeat
        end tell
    ]], path)

    local _, err = hs.osascript.applescript(script)
    if err then
        hs.logger.new("display"):e("Wallpaper error: " .. tostring(err))
    end
end


-- Physical monitors that should retain their normal macOS arrangement.
local knownMonitors = {
    ["s40474031"] = true,       -- known monitor #1
    ["s4815"] = true,           -- current external monitor
    ["DUMMY_SERIAL_2"] = true,  -- known monitor #2
}

local watcher
local timer
local applying = false


local function getDisplays()
    local output = hs.execute(DISPLAYPLACER .. " list")

    local displays = {}
    local current = nil

    for line in output:gmatch("[^\r\n]+") do

        local id = line:match("^Persistent screen id: (.+)$")

        if id then
            current = {
                id = id,
                serial = nil,
                type = nil,
                resolution = nil,
                hz = nil,
                colorDepth = nil,
                scaling = nil,
                originX = nil,
                originY = nil,
                degree = 0,
            }

            table.insert(displays, current)

        elseif current then

            local serial = line:match("^Serial screen id: (.+)$")
            if serial then
                current.serial = serial
            end

            local displayType = line:match("^Type: (.+)$")
            if displayType then
                current.type = displayType
            end

            local resolution = line:match("^Resolution: (.+)$")
            if resolution then
                current.resolution = resolution
            end

            local hz = line:match("^Hertz: (.+)$")
            if hz then
                current.hz = hz
            end

            local depth = line:match("^Color Depth: (.+)$")
            if depth then
                current.colorDepth = depth
            end

            local scaling = line:match("^Scaling: (.+)$")
            if scaling then
                current.scaling = scaling
            end

            local x, y = line:match(
                "^Origin: %((%-?%d+),(%-?%d+)%)"
            )

            if x then
                current.originX = tonumber(x)
                current.originY = tonumber(y)
            end

            local degree = line:match("^Rotation: (%d+)")
            if degree then
                current.degree = tonumber(degree)
            end
        end
    end

    return displays
end


local function isBuiltIn(display)
    return display.type == "MacBook built in screen"
end


local function arrangeUnknownMonitor()
    if applying then
        return
    end

    local displays = getDisplays()

    local builtin = nil
    local external = nil

    for _, display in ipairs(displays) do
        if isBuiltIn(display) then
            builtin = display
        elseif display.type
            and display.type:match("external screen") then
            external = display
        end
    end

    -- Only handle MacBook + exactly one external display.
    if not builtin or not external then
        return
    end

    -- ============================================================
    -- IMPORTANT:
    -- Known monitor = absolutely nothing happens.
    -- We do not call displayplacer.
    -- We do not change its position.
    -- We do not change its resolution.
    -- ============================================================

    if external.serial
        and knownMonitors[external.serial] then

        hs.printf(
            "Known monitor %s - leaving arrangement unchanged",
            external.serial
        )

        return
    end

    hs.printf(
        "Unknown monitor detected: serial=%s id=%s",
        external.serial or "?",
        external.id or "?"
    )

    local externalWidth =
        tonumber(external.resolution:match("^(%d+)x"))

    local externalHeight =
        tonumber(external.resolution:match("x(%d+)$"))

    local builtinWidth =
        tonumber(builtin.resolution:match("^(%d+)x"))

    if not externalWidth
        or not externalHeight
        or not builtinWidth then

        hs.printf("Unable to determine display dimensions")
        return
    end

    -- Centre the MacBook underneath the external monitor.
    local builtinX =
        math.floor((externalWidth - builtinWidth) / 2)

    -- Use persistent IDs for the actual displayplacer command.
    local command = string.format(
        '%s "id:%s origin:(0,0)" "id:%s origin:(%d,%d)"',
        DISPLAYPLACER,
        external.id,
        builtin.id,
        builtinX,
        externalHeight
    )

    hs.printf("Moving unknown monitor above MacBook")
    hs.printf("%s", command)

    applying = true

    hs.execute(command)

    -- Ignore the display-change events generated by displayplacer.
    hs.timer.doAfter(5, function()
        applying = false
    end)
end


-- Snapshot connected displays so startup/reload doesn't trigger window moves.
local function screenSnapshot()
    local ids = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        ids[screen:getUUID()] = true
    end
    return ids
end

local connectedScreenIds = screenSnapshot()


local function moveExistingWindowsToExternal()
    local screens = hs.screen.allScreens()
    local external = nil
    local largestArea = 0

    for _, screen in ipairs(screens) do
        local frame = screen:fullFrame()
        local area = frame.w * frame.h

        if area > largestArea then
            largestArea = area
            external = screen
        end
    end

    if not external or #screens < 2 then
        return
    end

    for _, appName in ipairs({"Google Chrome", "WezTerm"}) do
        local app = hs.application.find(appName)

        if app then
            for _, win in ipairs(app:allWindows()) do
                if win:isStandard() then
                    win:moveToScreen(external)
                end
            end
        end
    end
end


-- local function displayChanged()
--     if applying then
--         return
--     end
--
--     if timer then
--         timer:stop()
--     end
--
--     -- macOS needs a moment to finish enumerating the display.
--     timer = hs.timer.doAfter(3, function()
--         arrangeUnknownMonitor()
--         setBlackWallpaper()
--         timer = nil
--     end)
-- end

local function displayChanged()
    if applying then
        return
    end

    if timer then
        timer:stop()
    end

    timer = hs.timer.doAfter(3, function()
        timer = nil

        local currentIds = screenSnapshot()
        local newScreenConnected = false

        for id, _ in pairs(currentIds) do
            if not connectedScreenIds[id] then
                newScreenConnected = true
                break
            end
        end

        connectedScreenIds = currentIds

        arrangeUnknownMonitor()

        -- Only touch wallpaper when a screen actually connected. The
        -- System-Events AppleScript loops over every desktop and is wasteful to
        -- run on every spurious display-change event.
        if newScreenConnected then
            setBlackWallpaper()
            hs.timer.doAfter(2, moveExistingWindowsToExternal)
        end
    end)
end



watcher = hs.screen.watcher.new(displayChanged)
watcher:start()

-- Check once after Hammerspoon starts.
hs.timer.doAfter(3, function()
  arrangeUnknownMonitor()
  setBlackWallpaper()
end)
