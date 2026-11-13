DrawLabel(hdc, cx, y, s, color := 0xFFFFFF) {
    w := TextW(hdc, s)
    x := Round(cx - w / 2)
    DllCall("SetTextColor", "Ptr", hdc, "UInt", 0x010101)
    DllCall("TextOutW", "Ptr", hdc, "Int", x + 1, "Int", y + 1, "WStr", s, "Int", StrLen(s))
    DllCall("SetTextColor", "Ptr", hdc, "UInt", color)
    DllCall("TextOutW", "Ptr", hdc, "Int", x, "Int", y, "WStr", s, "Int", StrLen(s))
    return w
}

