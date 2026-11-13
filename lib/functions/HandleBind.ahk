HandleBind(base, newKey) {
    global ui, espKey, hookKey, uiKey, settingsFile
    if (base = "playeresp") {
        old := espKey
    } else if (base = "sendkey") {
        old := hookKey
    } else {
        old := uiKey
    }
    if (newKey != "None") {
        for _, other in [["playeresp", espKey], ["sendkey", hookKey], ["togglekey", uiKey]] {
            if (other[1] != base && other[2] = newKey) {
                el := ui.Find(base)
                if IsObject(el)
                    el.bind := old
                ui.Redraw()
                Tip("That key is already used by another action")
                return
            }
        }
    }
    if (base = "playeresp") {
        espKey := newKey
        IniWrite, %newKey%, %settingsFile%, keys, toggle
    } else if (base = "sendkey") {
        hookKey := newKey
        IniWrite, %newKey%, %settingsFile%, keys, sendinfo
    } else {
        uiKey := newKey
        IniWrite, %newKey%, %settingsFile%, keys, ui
    }
}

; sliders fire on every step while dragging, so the INI is written once things settle
