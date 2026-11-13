ReadCStr(hProc, addr, maxLen := 64) {
    if (addr < 0x10000)
        return ""
    VarSetCapacity(buf, maxLen+1, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", maxLen, "UPtr", 0, "Int")
        return ""
    return StrGet(&buf, "UTF-8")
}

