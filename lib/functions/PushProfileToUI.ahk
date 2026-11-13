PushProfileToUI() {
    global ui, MAX_DIST, off_DCV_Value, off_DCV_Max
    if !IsObject(ui)
        return
    d := MAX_DIST
    if (d < 100)
        d := 100
    if (d > 10000)
        d := 10000
    ui.Set("playerdist", d)
    ui.Set("dcvval", Format("0x{:X}", off_DCV_Value))
    ui.Set("dcvmax", Format("0x{:X}", off_DCV_Max))
    SyncVisuals()
    ui.Redraw()
}

