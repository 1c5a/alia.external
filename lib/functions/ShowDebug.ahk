ShowDebug() {
    global hProc, dllBase, static_VisualEngine, off_VE_Dimensions, off_Prim_Position, off_Hum_Health
    global offsetNote, players, ovW, ovH, streamProof, uiKey, gameId, profSection, TARGET_PART, ui, MAX_DIST
    Gui, UI:+OwnDialogs
    dbg := "Offsets: " offsetNote "`n"
    dbg .= "Players cached: " players.Length() "`n"
    dbg .= "Stream-proof: " (streamProof ? "ON" : "OFF") "`n"
    dbg .= "UI key: " uiKey "`n"
    dbg .= "GameId: " gameId " (profile: " profSection ") | target part: " TARGET_PART "`n"
    dbg .= "Max distance: " MAX_DIST " | Misc bars value: [" DbgRaw(ui.Get("playerespbars")) "] | ESP tags value: [" DbgRaw(ui.Get("playeresptags")) "]`n"
    pVE := ReadPtr(hProc, dllBase + static_VisualEngine)
    dbg .= "VisualEngine: 0x" Format("{:X}", pVE) "`n"
    dbg .= "VE dims (float): " ReadFloat(hProc, pVE + off_VE_Dimensions) " x " ReadFloat(hProc, pVE + off_VE_Dimensions + 4) "`n"
    dbg .= "Overlay: " ovW " x " ovH "`n`n"
    for _, pl in players {
        if ReadVec3(hProc, pl.prim + off_Prim_Position, dx, dy, dz)
            dbg .= pl.name " | hp " Round(ReadFloat(hProc, pl.hum + off_Hum_Health)) " | " Round(dx) ", " Round(dy) ", " Round(dz) "`n"
        else
            dbg .= pl.name " | position read failed`n"
    }
    MsgBox % dbg
}

