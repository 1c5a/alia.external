RefreshPlayers() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, players, localPrim, localTeam, localHum, localChr
    global off_Inst_NameCont, off_Players_LocalPlayer, off_Player_ModelInstance, off_Player_Team
    global off_Hum_RootPart, off_Part_Primitive, TARGET_PART, statNames, off_Player_DisplayName

    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    if (pRealDM < 0x10000)
        return
    pPlayersSvc := FindChildByClass(hProc, pRealDM, "Players")
    if !pPlayersSvc
        return

    pLocal := ReadPtr(hProc, pPlayersSvc + off_Players_LocalPlayer)
    newList := []
    newLocalPrim := 0
    newLocalHum := 0
    newLocalChr := 0
    newLocalTeam := 0
    if pLocal
        newLocalTeam := ReadPtr(hProc, pLocal + off_Player_Team)

    for _, pl in GetChildren(hProc, pPlayersSvc) {
        pChar := ReadPtr(hProc, pl + off_Player_ModelInstance)
        if (pChar < 0x10000)
            continue
        hum := 0
        hrp := 0
        headPrim := 0
        stats := {}
        for _, c in GetChildren(hProc, pChar) {
            nm := ReadNameAt(hProc, c + off_Inst_NameCont)
            if (nm = TARGET_PART)
                hrp := c
            else if (nm = "Head")
                headPrim := ReadPtr(hProc, c + off_Part_Primitive)
            else if (nm = "Humanoid")
                hum := c
            else if (statNames.HasKey(nm))
                stats[nm] := c
        }
        if (!hrp && hum)
            hrp := ReadPtr(hProc, hum + off_Hum_RootPart)
        if (hrp < 0x10000)
            continue
        prim := ReadPtr(hProc, hrp + off_Part_Primitive)
        if (prim < 0x10000)
            continue
        if (pl = pLocal) {
            newLocalPrim := prim
            newLocalHum := hum
            newLocalChr := pChar
            continue
        }
        dispName := ""
        if (off_Player_DisplayName >= 0x10) {
            dispName := ReadNameAt(hProc, pl + off_Player_DisplayName)
            if (SubStr(dispName, 1, 1) = "<")
                dispName := ""
        }
        newList.Push({name: ReadNameAt(hProc, pl + off_Inst_NameCont), disp: dispName, chr: pChar, hum: hum, prim: prim, headPrim: headPrim, team: ReadPtr(hProc, pl + off_Player_Team), stats: stats})
    }
    players := newList
    localPrim := newLocalPrim
    localHum := newLocalHum
    localChr := newLocalChr
    localTeam := newLocalTeam
}

