DrawStatMeters(hdc, pl, l, t, r, b, leftX) {
    global hProc, sideBottom, sideRight, sideLeft, brushOutline, brushBack
    for k, d in sideBottom {
        ratio := 0
        if !StatRatio(hProc, pl.stats[d.name], ratio)
            continue
        y1 := b + 4 + 5 * (k - 1)
        GdiFill(hdc, l-1, y1-1, r+1, y1+4, brushOutline)
        GdiFill(hdc, l, y1, r, y1+3, brushBack)
        GdiFill(hdc, l, y1, l + Round((r - l) * ratio), y1+3, d.brush)
    }
    for k, d in sideRight {
        ratio := 0
        if !StatRatio(hProc, pl.stats[d.name], ratio)
            continue
        x1 := r + 4 + 5 * (k - 1)
        GdiFill(hdc, x1-1, t-1, x1+4, b+1, brushOutline)
        GdiFill(hdc, x1, t, x1+3, b, brushBack)
        GdiFill(hdc, x1, b - Round((b - t) * ratio), x1+3, b, d.brush)
    }
    for k, d in sideLeft {
        ratio := 0
        if !StatRatio(hProc, pl.stats[d.name], ratio)
            continue
        x2 := leftX - 5 * (k - 1)
        x1 := x2 - 3
        GdiFill(hdc, x1-1, t-1, x2+1, b+1, brushOutline)
        GdiFill(hdc, x1, t, x2, b, brushBack)
        GdiFill(hdc, x1, b - Round((b - t) * ratio), x2, b, d.brush)
    }
}

; calibration helper: prints plausible doubles inside a few stat objects so you can find Value/Max
