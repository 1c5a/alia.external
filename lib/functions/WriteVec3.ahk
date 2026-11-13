WriteVec3(hProc, addr, x, y, z) {
    if (addr < 0x10000)
        return false
    VarSetCapacity(buf, 12, 0)
    NumPut(x, buf, 0, "Float")
    NumPut(y, buf, 4, "Float")
    NumPut(z, buf, 8, "Float")
    return DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", addr, "Ptr", &buf, "UPtr", 12, "UPtr", 0, "Int")
}

