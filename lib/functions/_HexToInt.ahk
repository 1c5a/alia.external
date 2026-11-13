_HexToInt(h) {
    v := 0
    Loop, Parse, h
        v := v * 16 + (InStr("0123456789ABCDEF", A_LoopField) - 1)
    return v
}

