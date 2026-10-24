local function toggleDIFM()
    local chrome = hs.application.get("Google Chrome")
    if not chrome then
        hs.alert.show("Google Chrome is not running")
        return
    end

    local oldApp = hs.application.frontmostApplication()

    -- Bring Chrome to the front so its extension shortcut is delivered.
    chrome:activate()

    hs.timer.doAfter(0.15, function()
        -- Chrome extension shortcut: Alt+Shift+M
        hs.eventtap.keyStroke({"alt", "shift"}, "m", 0)

        -- Return to whatever app we were using.
        hs.timer.doAfter(0.1, function()
            if oldApp then
                oldApp:activate()
            end
        end)
    end)
end

hs.hotkey.bind({"ctrl", "shift"}, "space", toggleDIFM)
