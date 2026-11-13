HexAt(hProc, addr, len) {
    if (addr < 0x10000)
        return "(null)"
    VarSetCapacity(buf, len, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", len, "UPtr", 0, "Int")
        return "(unreadable)"
    out := ""
    Loop %len% {
        out .= Format("{:02X}", NumGet(buf, A_Index - 1, "UChar")) ((Mod(A_Index, 8) = 0) ? "`n " : " ")
    }
    return RTrim(out)
}

