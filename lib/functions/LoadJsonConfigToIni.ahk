LoadJsonConfigToIni() {
    global jsonSettingsFile, legacySettingsFile, settingsFile
    FileDelete, %settingsFile%
    if FileExist(jsonSettingsFile) {
        FileRead, raw, %jsonSettingsFile%
        flat := JsonFlatten(raw)
        if (IsObject(flat) && flat.Count() > 0) {
            for path, value in flat {
                if RegExMatch(path, "^(.*)::([^:]+)$", m)
                    IniWrite, %value%, %settingsFile%, %m1%, %m2%
            }
            return
        }
    }
    ; One-time migration fallback for the previous INI config.
    if FileExist(legacySettingsFile)
        FileCopy, %legacySettingsFile%, %settingsFile%, 1
}

