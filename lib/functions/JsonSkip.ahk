JsonSkip(text, ByRef pos) {
    Loop {
        c := SubStr(text, pos, 1)
        if (c = " " || c = "`t" || c = "`n" || c = "`r")
            pos++
        else
            break
    }
}

