IsBindFire(key) {
    global ui
    el := ui.Find(key)
    if !IsObject(el)
        return false
    b := el.bind
    if (b = "" || b = "None")
        return false
    return GetKeyState(b, "P") ? true : false
}

; called by the library for every element use: (key, value, extra)
