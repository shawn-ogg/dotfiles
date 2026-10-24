# shellcheck shell=bash

# Open a Jira ticket in Google Chrome, focusing an existing matching tab
# when possible. This uses AppleScript and is macOS-specific.
jira() {
  local url
  local ticket="${1:-}"

  if [[ -z "$ticket" ]]; then
    url="https://securityjira.wbs.only.sap/secure/RapidBoard.jspa?rapidView=508&projectKey=DPE"
  else
    [[ "$ticket" =~ ^[0-9]+$ ]] && ticket="DPE-$ticket"
    ticket="${ticket^^}"
    url="https://securityjira.wbs.only.sap/browse/$ticket"
  fi

  osascript <<EOF
tell application "Google Chrome"
    if not running then launch

    set targetURL to "$url"
    set foundTab to false

    repeat with w in windows
        set tabIndex to 1

        repeat with t in tabs of w
            if URL of t starts with targetURL then
                set active tab index of w to tabIndex
                set index of w to 1
                activate
                set foundTab to true
                exit repeat
            end if

            set tabIndex to tabIndex + 1
        end repeat

        if foundTab then exit repeat
    end repeat

    if not foundTab then
        if (count of windows) = 0 then
            make new window
            set URL of active tab of front window to targetURL
        else
            tell front window
                make new tab with properties {URL:targetURL}
                set active tab index to (count tabs)
            end tell
        end if
        activate
    end if
end tell
EOF
}
