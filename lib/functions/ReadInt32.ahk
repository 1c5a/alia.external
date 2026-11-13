ReadInt32(hProc, addr) {
    VarSetCapacity(b, 4, 0)
    DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &b, "UPtr", 4, "UPtr", 0, "Int")
    return NumGet(b, 0, "Int")
}

