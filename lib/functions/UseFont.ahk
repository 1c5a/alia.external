UseFont(size) {
    global hdcMem, fontCache, fontCurSize, fontFace
    key := size "|" fontFace
    if !fontCache.HasKey(key) {
        nf := DllCall("CreateFontW", "Int", -size, "Int", 0, "Int", 0, "Int", 0, "Int", 600, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1, "UInt", 0, "UInt", 0, "UInt", 4, "UInt", 0, "WStr", fontFace, "Ptr")
        if !nf
            return
        fontCache[key] := nf
    }
    if (fontCurSize = key)
        return
    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", fontCache[key], "Ptr")
    fontCurSize := key
}

; adds s to a newline separated list unless it is empty or already in it
