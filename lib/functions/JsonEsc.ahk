JsonEsc(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, """", "\""")
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", "\t")
    s := RegExReplace(s, "[\x00-\x08\x0B\x0C\x0E-\x1F]", "")
    return s
}

