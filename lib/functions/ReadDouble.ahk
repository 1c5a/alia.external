ReadDouble(hProc, addr) {
    if (addr < 0x10000)
        return 0
    VarSetCapacity(buf, 8, 0)
    DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 8, "UPtr", 0, "Int")
    return NumGet(buf, 0, "Double")
}

; value of one attribute node: a number (double) or a string; "" if it is neither (bool, vector, ...)
