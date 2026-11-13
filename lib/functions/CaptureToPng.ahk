CaptureToPng(x, y, w, h, outFile) {
    hLib := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
    VarSetCapacity(si, (A_PtrSize = 8) ? 24 : 16, 0)
    NumPut(1, si, 0, "UInt")
    token := 0
    DllCall("gdiplus\GdiplusStartup", "Ptr*", token, "Ptr", &si, "Ptr", 0)
    hdcScr := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdc := DllCall("CreateCompatibleDC", "Ptr", hdcScr, "Ptr")
    hbmp := DllCall("CreateCompatibleBitmap", "Ptr", hdcScr, "Int", w, "Int", h, "Ptr")
    old := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbmp, "Ptr")
    blt := DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", hdcScr, "Int", x, "Int", y, "UInt", 0x40CC0020)
    ; GDI+ needs the HBITMAP to be out of any DC before it can wrap it
    DllCall("SelectObject", "Ptr", hdc, "Ptr", old)
    pBmp := 0
    st1 := DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbmp, "Ptr", 0, "Ptr*", pBmp)
    VarSetCapacity(clsid, 16, 0)
    DllCall("ole32\CLSIDFromString", "WStr", "{557CF401-1A04-11D3-9A73-0000F81EF32E}", "Ptr", &clsid)
    rc := 1
    st2 := "n/a"
    if pBmp {
        rc := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBmp, "WStr", outFile, "Ptr", &clsid, "Ptr", 0)
        st2 := rc
    }
    if pBmp
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBmp)
    global appDir
    FileAppend, % A_Now " rect " x "," y "," w "x" h " blt=" blt " bmp=" st1 " save=" st2 "`n", %appDir%\shot_debug.txt
    DllCall("DeleteObject", "Ptr", hbmp)
    DllCall("DeleteDC", "Ptr", hdc)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdcScr)
    DllCall("gdiplus\GdiplusShutdown", "Ptr", token)
    DllCall("FreeLibrary", "Ptr", hLib)
    return (rc = 0)
}

; background upload with curl.exe (ships with Windows 10+): the script keeps running while it uploads.
; Files are cleaned up by FinishUpload() once curl has exited.
