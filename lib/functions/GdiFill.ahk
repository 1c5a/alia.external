GdiFill(hdc, l, t, r, b, brush) {
    VarSetCapacity(rc, 16, 0)
    NumPut(l, rc, 0, "Int")
    NumPut(t, rc, 4, "Int")
    NumPut(r, rc, 8, "Int")
    NumPut(b, rc, 12, "Int")
    DllCall("FillRect", "Ptr", hdc, "Ptr", &rc, "Ptr", brush)
}

