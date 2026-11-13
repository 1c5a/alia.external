ReadVec3(hProc, addr, ByRef x, ByRef y, ByRef z) {
    if (addr < 0x10000)
        return false
    VarSetCapacity(buf, 12, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 12, "UPtr", 0, "Int")
        return false
    x := NumGet(buf, 0, "Float")
    y := NumGet(buf, 4, "Float")
    z := NumGet(buf, 8, "Float")
    return true
}

