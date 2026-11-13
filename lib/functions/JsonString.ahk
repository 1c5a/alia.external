JsonString(text, ByRef pos) {
    start := pos + 1
    q := start
    Loop {
        e := InStr(text, """", true, q)
        if !e {
            pos := StrLen(text) + 1
            return SubStr(text, start)
        }
        k := e - 1
        bs := 0
        while (k >= start && SubStr(text, k, 1) = "\") {
            bs++
            k--
        }
        if (Mod(bs, 2) = 0)
            break
        q := e + 1
    }
    pos := e + 1
    return SubStr(text, start, e - start)
}

