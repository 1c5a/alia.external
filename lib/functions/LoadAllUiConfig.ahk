LoadAllUiConfig() {
    global settingsFile, tabUI
    if !IsObject(tabUI)
        return
    for _, list in tabUI {
        for _, el in list {
            if !IsObject(el)
                continue
            t := el.type
            if (t = "header" || t = "label" || t = "button" || t = "buttons")
                continue
            cfgKey := "el_" el.key
            IniRead, val, %settingsFile%, ui, %cfgKey%, __MISSING__
            if (val = "__MISSING__")
                continue
            ui.Set(el.key, val)
            if (t != "keybind" && el.key != "togglekey")
                OnUI(el.key, ui.Get(el.key), "")
        }
    }
}

; JSON is the user-facing config format. Existing code uses a temporary INI
; representation internally so older profile and UI code remains compatible.
