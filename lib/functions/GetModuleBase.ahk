GetModuleBase(hProc, targetName) {
    VarSetCapacity(hMods, 1024*8, 0)
    VarSetCapacity(cbNeeded, 4, 0)
    DllCall("Psapi.dll\EnumProcessModulesEx", "Ptr", hProc, "Ptr", &hMods, "UInt", 1024*8, "UPtr", &cbNeeded, "UInt", 0x03, "Int")
    count := NumGet(cbNeeded, 0, "UInt") // 8
    Loop %count% {
        hMod := NumGet(hMods, (A_Index-1)*8, "Ptr")
        VarSetCapacity(nb, 520, 0)
        DllCall("Psapi.dll\GetModuleFileNameExW", "Ptr", hProc, "Ptr", hMod, "Ptr", &nb, "UInt", 260)
        SplitPath, % StrGet(&nb, 260, "UTF-16"), fn
        if (fn = targetName)
            return hMod
    }
    return 0
}

; keep this at the very bottom: the library defines hotkeys and labels
#Include *i %A_ScriptDir%\lib\aliaUI.ahk
