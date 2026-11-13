ReadPtr(hProc, addr) {
    if !addr
        return 0
    VarSetCapacity(buf, 8, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 8, "UPtr", 0, "Int")
        return 0
    return NumGet(buf, 0, "UPtr")
}

