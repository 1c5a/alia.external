SyncVisuals() {
    global mobOn, mobHp, mobHpW, mobText, mobTextBGR, mobTextSize, mobDistMax
    global ui, espOn, vBars, vHpBar, vHpW, vText, vTextBGR, vTextSize, vBoxBGR, vBoxAlpha, brushBox
    global tagUser, tagDisp, tagHpPct, tagHpCur, tagDist, statItems, tagItems, statOn, GameDefs, gameId
    if !IsObject(ui)
        return
    espOn := ui.Get("playeresp") ? true : false
    vBars := ui.Get("playerbars") ? true : false
    vHpBar := ui.Get("playerhealthbar") ? true : false
    w := ui.Get("playerhpbarwidth") + 0
    vHpW := (w >= 1 && w <= 50) ? Round(w) : 10
    vText := ui.Get("playertext") ? true : false
    sz := ui.Get("playertextsize") + 0
    vTextSize := (sz >= 8 && sz <= 24) ? Round(sz) : 14
    el := ui.Find("playertextcolor")
    vTextBGR := IsObject(el) ? RgbToBgr(el.color, 0xFFFFFF) : 0xFFFFFF

    ; boxes: colour row (alpha 0 = hidden). If the row is made a toggle with a colour chip it works too
    vBoxAlpha := 100
    boxBGR := 0x010101
    el := ui.Find("playerboxtoggle")
    if IsObject(el) {
        boxBGR := RgbToBgr(el.color, 0x010101)
        if IsNum(el.alpha)
            vBoxAlpha := el.alpha + 0
        if (el.type = "toggle" && !el.value)
            vBoxAlpha := 0
    }
    if (boxBGR != vBoxBGR) {
        nbrush := DllCall("CreateSolidBrush", "UInt", boxBGR, "Ptr")
        if nbrush {
            oldBrush := brushBox
            brushBox := nbrush
            vBoxBGR := boxBGR
            if oldBrush
                DllCall("DeleteObject", "Ptr", oldBrush)
        }
    }

    mobOn := ui.Get("mobesp") ? true : false
    mobHp := ui.Get("mobhealthbar") ? true : false
    w := ui.Get("mobhpbarwidth") + 0
    mobHpW := (w >= 1 && w <= 50) ? Round(w) : 10
    mobText := ui.Get("mobtext") ? true : false
    sz := ui.Get("mobtextsize") + 0
    mobTextSize := (sz >= 8 && sz <= 24) ? Round(sz) : 14
    el := ui.Find("mobtextcolor")
    mobTextBGR := IsObject(el) ? RgbToBgr(el.color, 0xFFFFFF) : 0xFFFFFF
    md := ui.Get("mobdist") + 0
    mobDistMax := (md >= 100) ? md : 1000

    sel := MultiNames(ui.Get("playeresptags"), tagItems)
    tagUser := sel.HasKey("Username") ? true : false
    tagDisp := sel.HasKey("Display Name") ? true : false
    tagHpPct := sel.HasKey("Health Percentage") ? true : false
    tagHpCur := sel.HasKey("Cur. HP / Max HP") ? true : false
    tagDist := sel.HasKey("Distance") ? true : false

    selB := MultiNames(ui.Get("playerespbars"), statItems)
    statOn := {}
    defs := GameDefs[gameId]
    if IsObject(defs) {
        for _, d in defs
            statOn[d.name] := selB.HasKey(d.label) ? true : false
    }
    BuildGameStats()
}

; a multi-select value can come back as a list/object, a "A, B" or "1,3" string, "None", or a bitmask number.
; this turns any of those into {itemName: true}
