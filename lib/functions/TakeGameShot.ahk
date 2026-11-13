TakeGameShot() {
    global ui, hwnd, hGui, streamProof, appDir
    cacheDir := appDir "\cache"
    FileCreateDir, %cacheDir%
    FileDelete, %cacheDir%\*.*
    f := cacheDir "\shot_" A_TickCount ".jpg"
    nx := 0
    ny := 0
    nw := 0
    nh := 0
    GetClientArea(hwnd, nx, ny, nw, nh)
    if (nw < 1 || nh < 1)
        return ""
    wasOn := streamProof
    if !wasOn
        SetStreamProof(hGui, true)
    wasUI := UiOpen()
    if wasUI
        ui.Hide()
    ToolTip
    Sleep, 250
    ok := CaptureToPng(nx, ny, nw, nh, f)
    if !wasOn
        SetStreamProof(hGui, false)
    if wasUI
        ui.Show()
    return (ok && FileExist(f)) ? f : ""
}

