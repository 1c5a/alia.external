ReadPrintable(hProc, addr, len) {
    if (addr < 0x10000 || len < 1 || len > 256)
        return ""
    VarSetCapacity(buf, len+1, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", len, "UPtr", 0, "Int")
        return ""
    Loop %len% {
        b := NumGet(buf, A_Index-1, "UChar")
        if (b < 0x20 || b > 0x7E)
            return ""
    }
    return StrGet(&buf, len, "UTF-8")
}

