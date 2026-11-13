WritePtr(hProc, addr, val) {
    if (addr < 0x10000)
        return false
    VarSetCapacity(buf, 8, 0)
    NumPut(val, buf, 0, "UPtr")
    return DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 8, "UPtr", 0, "Int")
}

