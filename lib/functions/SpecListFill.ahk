SpecListFill() {
    global players, specName, specListShown
    items := ""
    sel := 0
    for i, pl in players {
        it := pl.name . ((pl.disp != "" && pl.disp != pl.name) ? " (" pl.disp ")" : "")
        items .= "|" it
        if (pl.name = specName)
            sel := i
    }
    if (items = specListShown)
        return
    specListShown := items
    GuiControl, SpecWin:, SpecSel, % (items = "") ? "|" : items
    if sel
        GuiControl, SpecWin:Choose, SpecSel, %sel%
}

