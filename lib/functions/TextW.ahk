TextW(hdc, s) {
    VarSetCapacity(sz, 8, 0)
    DllCall("GetTextExtentPoint32W", "Ptr", hdc, "WStr", s, "Int", StrLen(s), "Ptr", &sz)
    return NumGet(sz, 0, "Int")
}

; selects the label font for this size into the back buffer (one font per size is created once and kept)
