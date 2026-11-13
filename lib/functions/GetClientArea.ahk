GetClientArea(hwnd, ByRef x, ByRef y, ByRef w, ByRef h) {
    VarSetCapacity(rc, 16, 0)
    DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rc)
    w := NumGet(rc, 8, "Int")
    h := NumGet(rc, 12, "Int")
    VarSetCapacity(pt, 8, 0)
    DllCall("ClientToScreen", "Ptr", hwnd, "Ptr", &pt)
    x := NumGet(pt, 0, "Int")
    y := NumGet(pt, 4, "Int")
}

