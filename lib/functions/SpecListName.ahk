SpecListName(item) {
    p := InStr(item, " (")
    return p ? SubStr(item, 1, p - 1) : item
}

