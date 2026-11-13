RgbToBgr(c, fallback := 0xFFFFFF) {
    if !IsInt(c)
        return fallback
    c := c & 0xFFFFFF
    b := ((c & 0xFF) << 16) | (c & 0xFF00) | ((c >> 16) & 0xFF)
    return (b = 0) ? 0x010101 : b
}

