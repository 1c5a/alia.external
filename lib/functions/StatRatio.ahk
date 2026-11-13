StatRatio(hProc, ptr, ByRef ratio) {
    global off_DCV_Value, off_DCV_Max
    ratio := 0
    if (ptr < 0x10000)
        return false
    lo := (off_DCV_Value < off_DCV_Max) ? off_DCV_Value : off_DCV_Max
    hi := (off_DCV_Value > off_DCV_Max) ? off_DCV_Value : off_DCV_Max
    span := hi - lo + 8
    if (span > 0x200)
        return false
    VarSetCapacity(buf, span, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", ptr + lo, "Ptr", &buf, "UPtr", span, "UPtr", 0, "Int")
        return false
    v := NumGet(buf, off_DCV_Value - lo, "Double")
    mx := NumGet(buf, off_DCV_Max - lo, "Double")
    if (!IsNum(v) || !IsNum(mx) || mx <= 0 || mx > 100000000 || v < 0)
        return false
    ratio := v / mx
    if (ratio > 1)
        ratio := 1
    return true
}

; bars (no numbers): bottom = horizontal rows under the box, right/left = vertical columns beside it
; leftX = right edge of the first left column (just outside the health bar)
