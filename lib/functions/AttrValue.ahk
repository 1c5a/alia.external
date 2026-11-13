AttrValue(hProc, node) {
    global off_Attr_Value
    addr := node + off_Attr_Value
    d := ReadDouble(hProc, addr)
    if (d = d && Abs(d) < 1000000000000000.0 && (d = 0 || Abs(d) >= 0.000000001))
        return d
    sv := ReadStdStringU(hProc, addr)
    if (sv != "")
        return sv
    return ReadStdStringU(hProc, ReadPtr(hProc, addr))
}

; GetAttribute(hProc, inst, "Name") -> the attribute's value, or `default` if the instance has none by that name
