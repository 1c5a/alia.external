ReadTextProp(hProc, inst) {
    global off_TextLabel_Text
    addr := inst + off_TextLabel_Text
    s := ReadStdStringU(hProc, addr)
    if (s != "")
        return s
    return ReadStdStringU(hProc, ReadPtr(hProc, addr))
}

; string -> byte array (UTF-8), so non-ASCII text (accents, emoji) is always sent as valid UTF-8
