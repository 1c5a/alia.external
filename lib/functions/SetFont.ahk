SetFont(v) {
    global fontNames, fontIdx, fontFace, settingsFile
    idx := 0
    if IsInt(v) {
        idx := v + 0
    } else {
        for i, nm in fontNames {
            if (nm = v) {
                idx := i
                break
            }
        }
    }
    if (idx < 1 || idx > fontNames.Length())
        return
    fontIdx := idx
    fontFace := fontNames[idx]
    IniWrite, %fontIdx%, %settingsFile%, keys, font
}

