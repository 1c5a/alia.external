SaveAllUiConfig() {
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
            if (t = "keybind")
                val := el.bind
            else if (t = "color")
                val := el.color
            else if (t = "multidropdown") {
                val := ""
                for _, idx in el.value
                    val .= (val = "" ? "" : ",") idx
            } else
                val := el.value
            IniWrite, %val%, %settingsFile%, ui, %cfgKey%
        }
    }
}

