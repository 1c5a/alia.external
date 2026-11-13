RefreshMobs() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, mobs, off_Inst_NameCont, off_Hum_RootPart, off_Part_Primitive, TARGET_PART
    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    if (pRealDM < 0x10000)
        return
    ws := FindChildByClass(hProc, pRealDM, "Workspace")
    live := ws ? FindChildByName(hProc, ws, "Live") : 0
    newList := []
    if live {
        for _, c in GetChildren(hProc, live) {
            nm := ReadNameAt(hProc, c + off_Inst_NameCont)
            if (SubStr(nm, 1, 1) != ".")
                continue
            hum := 0
            hrp := 0
            for _, k in GetChildren(hProc, c) {
                kn := ReadNameAt(hProc, k + off_Inst_NameCont)
                if (kn = "Humanoid")
                    hum := k
                else if (kn = TARGET_PART)
                    hrp := k
            }
            if !hum
                continue
            if !hrp
                hrp := ReadPtr(hProc, hum + off_Hum_RootPart)
            if (hrp < 0x10000)
                continue
            prim := ReadPtr(hProc, hrp + off_Part_Primitive)
            if (prim < 0x10000)
                continue
            newList.Push({name: SubStr(nm, 2), disp: "", chr: c, hum: hum, prim: prim, team: 0, stats: {}})
        }
    }
    mobs := newList
}

; reads every Player ESP control from the menu into plain variables (runs on any change and every 2 s)
