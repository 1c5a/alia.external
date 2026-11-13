JsonFlatten(text) {
    out := {}
    if (Ord(SubStr(text, 1, 1)) = 0xFEFF)
        text := SubStr(text, 2)
    pos := 1
    JsonValue(text, pos, "", out)
    return out
}

