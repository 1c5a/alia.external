GetChildren(hProc, inst) {
    global off_Inst_ChildData, CHILD_STRIDE
    arr := []
    container := ReadPtr(hProc, inst + off_Inst_ChildData)
    b := ReadPtr(hProc, container)
    e := ReadPtr(hProc, container + 8)
    if (!b || e <= b)
        return arr
    n := (e - b) // CHILD_STRIDE
    if (n > 4096)
        return arr
    size := n * CHILD_STRIDE
    VarSetCapacity(buf, size, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", b, "Ptr", &buf, "UPtr", size, "UPtr", 0, "Int")
        return arr
    Loop %n% {
        p := NumGet(buf, (A_Index-1)*CHILD_STRIDE, "UPtr")
        if (p > 0x10000)
            arr.Push(p)
    }
    return arr
}

