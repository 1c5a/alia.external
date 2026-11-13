SaveIniConfigToJson() {
    global jsonSettingsFile, settingsFile
    if !FileExist(settingsFile)
        return
    IniRead, sections, %settingsFile%
    json := "{"
    firstSection := true
    Loop, Parse, sections, `n, `r
    {
        section := Trim(A_LoopField)
        if (section = "")
            continue
        IniRead, entries, %settingsFile%, %section%
        body := ""
        firstEntry := true
        Loop, Parse, entries, `n, `r
        {
            line := A_LoopField
            eq := InStr(line, "=")
            if (eq < 2)
                continue
            key := Trim(SubStr(line, 1, eq - 1))
            val := SubStr(line, eq + 1)
            if !firstEntry
                body .= ","
            body .= Chr(34) . JsonEsc(key) . Chr(34) . ":" . Chr(34) . JsonEsc(val) . Chr(34)
            firstEntry := false
        }
        if !firstSection
            json .= ","
        json .= Chr(34) . JsonEsc(section) . Chr(34) . ":{" . body . "}"
        firstSection := false
    }
    json .= "}"
    tmp := jsonSettingsFile ".tmp"
    FileDelete, %tmp%
    FileAppend, %json%, %tmp%, UTF-8
    FileMove, %tmp%, %jsonSettingsFile%, 1
}

; pushes the loaded profile (global defaults or this game's) into the menu
