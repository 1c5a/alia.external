WriteInt32(hProc, addr, v) {
    VarSetCapacity(b, 4, 0)
    NumPut(v, b, 0, "Int")
    return DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &b, "UPtr", 4, "UPtr", 0, "Int")
}

