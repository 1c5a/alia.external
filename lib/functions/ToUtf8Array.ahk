ToUtf8Array(s) {
    n := StrPut(s, "UTF-8") - 1
    VarSetCapacity(b, n + 1, 0)
    StrPut(s, &b, "UTF-8")
    arr := ComObjArray(0x11, n)
    pv := NumGet(ComObjValue(arr) + 8 + A_PtrSize, 0, "Ptr")
    DllCall("RtlMoveMemory", "Ptr", pv, "Ptr", &b, "UPtr", n)
    return arr
}

