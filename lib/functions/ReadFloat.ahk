ReadFloat(hProc, addr) {
    if (addr < 0x10000)
        return 0
    VarSetCapacity(buf, 4, 0)
    DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 4, "UPtr", 0, "Int")
    return NumGet(buf, 0, "Float")
}

