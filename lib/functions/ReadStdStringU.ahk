ReadStdStringU(hProc, addr) {
    if (addr < 0x10000)
        return ""
    len := ReadUInt32(hProc, addr + 0x10)
    cap := ReadUInt32(hProc, addr + 0x18)
    if (len < 1 || len > 256 || cap < len)
        return ""
    dataPtr := (cap < 16) ? addr : ReadPtr(hProc, addr)
    if (dataPtr < 0x10000)
        return ""
    VarSetCapacity(buf, len + 1, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", dataPtr, "Ptr", &buf, "UPtr", len, "UPtr", 0, "Int")
        return ""
    return StrGet(&buf, len, "UTF-8")
}

; TextLabel::Text may be stored inline in the instance or behind a pointer; try both
