ReadInt64(hProc, addr) {
    if !addr
        return 0
    VarSetCapacity(buf, 8, 0)
    DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 8, "UPtr", 0, "Int")
    return NumGet(buf, 0, "UInt64")
}

