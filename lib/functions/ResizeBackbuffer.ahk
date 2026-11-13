ResizeBackbuffer(hGui, w, h) {
    global hdcMem, hbm, hbmOld, fontCache, fontCurSize
    hdc := DllCall("GetDC", "Ptr", hGui, "Ptr")
    if !hdcMem
        hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    if hbm {
        DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbmOld, "Ptr")
        DllCall("DeleteObject", "Ptr", hbm)
    }
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    hbmOld := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm, "Ptr")
    fnt := fontCache.HasKey(fontCurSize) ? fontCache[fontCurSize] : DllCall("GetStockObject", "Int", 17, "Ptr")
    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", fnt, "Ptr")
    DllCall("SetBkMode", "Ptr", hdcMem, "Int", 1)
    DllCall("ReleaseDC", "Ptr", hGui, "Ptr", hdc)
}

