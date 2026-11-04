#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook true

; Win+1..9 and Win+0 select the corresponding configured application.
; This intentionally replaces Windows' native Win+number taskbar behaviour:
; it activates one application without minimising or cycling its windows.

global AppConfigPath := A_ScriptDir "\\apps.ini"

ActivateConfiguredApp(position) {
    configPath := AppConfigPath
    appName := IniRead(configPath, position, "name", position)
    executable := Trim(IniRead(configPath, position, "windows", "-"))

    if (executable = "" || executable = "-")
        return

    ; If this application already owns the foreground window, leave it alone.
    try {
        activeProcess := WinGetProcessName("A")
        if (StrCompare(activeProcess, executable, false) = 0)
            return
    }

    ; Activate an existing window. WinActivate restores a minimised window.
    windows := WinGetList("ahk_exe " executable)
    if (windows.Length > 0) {
        WinActivate("ahk_id " windows[1])
        return
    }

    ; No existing window: launch the configured executable.
    try {
        Run(executable)
    } catch as err {
        MsgBox("Could not launch " appName " (" executable ").`n`n" err.Message,
            "Application launcher", "Iconx")
    }
}

#1::ActivateConfiguredApp("1")
#2::ActivateConfiguredApp("2")
#3::ActivateConfiguredApp("3")
#4::ActivateConfiguredApp("4")
#5::ActivateConfiguredApp("5")
#6::ActivateConfiguredApp("6")
#7::ActivateConfiguredApp("7")
#8::ActivateConfiguredApp("8")
#9::ActivateConfiguredApp("9")
#0::ActivateConfiguredApp("0")
