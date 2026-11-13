UpdateFovBrushes() {
    global espAccent, fovPen, fovFillBrush, camlockFovAlpha
    color := RgbToBgr(espAccent, 0xFF69B4)
    if fovPen
        DllCall("DeleteObject", "Ptr", fovPen)
    if fovFillBrush
        DllCall("DeleteObject", "Ptr", fovFillBrush)
    fovPen := DllCall("CreatePen", "Int", 0, "Int", 2, "UInt", color, "Ptr")
    if (camlockFovAlpha >= 90)
        fovFillBrush := DllCall("CreateSolidBrush", "UInt", color, "Ptr")
    else if (camlockFovAlpha >= 60)
        fovFillBrush := DllCall("CreateHatchBrush", "Int", 3, "UInt", color, "Ptr") ; BDIAGONAL
    else if (camlockFovAlpha >= 30)
        fovFillBrush := DllCall("CreateHatchBrush", "Int", 4, "UInt", color, "Ptr") ; CROSS
    else
        fovFillBrush := DllCall("CreateHatchBrush", "Int", 5, "UInt", color, "Ptr") ; DIAGCROSS
}

