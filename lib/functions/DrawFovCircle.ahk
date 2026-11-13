DrawFovCircle(hdc, cx, cy, radius, pen, brush) {
    oldPen := DllCall("SelectObject", "Ptr", hdc, "Ptr", pen, "Ptr")
    oldBrush := DllCall("SelectObject", "Ptr", hdc, "Ptr", brush, "Ptr")
    oldMode := DllCall("SetBkMode", "Ptr", hdc, "Int", 1, "Int")
    DllCall("Ellipse", "Ptr", hdc, "Int", cx-radius, "Int", cy-radius, "Int", cx+radius, "Int", cy+radius)
    DllCall("SetBkMode", "Ptr", hdc, "Int", oldMode)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldBrush, "Ptr")
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldPen, "Ptr")
}

