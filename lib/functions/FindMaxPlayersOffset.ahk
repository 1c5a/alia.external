FindMaxPlayersOffset() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, maxPlFallback, off_Players_MaxPlayers, settingsFile, appDir
    Gui, UI:+OwnDialogs
    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    pSvc := (pRealDM > 0x10000) ? FindChildByClass(hProc, pRealDM, "Players") : 0
    if !pSvc {
        MsgBox, 0x30, alia, Players service not found (are you in a server?).
        return
    }
    if (maxPlFallback < 1 || maxPlFallback > 500) {
        ; nothing typed: use the automatic detection instead
        cur := GetChildren(hProc, pSvc).Length()
        f := AutoFindMaxPlayers(hProc, pSvc, cur)
        if (f > 0) {
            off_Players_MaxPlayers := f
            IniWrite, %f%, %settingsFile%, keys, maxpoff
        MsgBox, 0x40, alia, % "Auto-detected max players offset 0x" Format("{:X}", f) " (value " ReadUInt32(hProc, pSvc + f) "). Saved."
        } else
        MsgBox, 0x30, alia, Couldn't detect it automatically. Type the real max player count into the "Max players" box and press this button again.
        return
    }
    size := 0x800
    VarSetCapacity(buf, size, 0)
    nChunks := size // 0x100
    Loop %nChunks% {
        c := (A_Index - 1) * 0x100
        DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pSvc + c, "Ptr", &buf + c, "UPtr", 0x100, "UPtr", 0, "Int")
    }
    dump := "Players service @ 0x" Format("{:X}", pSvc) "`nsmall ints (1-500) found; looking for " maxPlFallback "`n`n"
    hits := []
    o := 0x80
    while (o <= size - 4) {
        v := NumGet(buf, o, "UInt")
        if (v >= 1 && v <= 500) {
            dump .= "+0x" Format("{:X}", o) " = " v "`n"
            if (v = maxPlFallback)
                hits.Push(o)
        }
        o += 4
    }
    dumpFile := appDir "\players_dump.txt"
    FileDelete, %dumpFile%
    FileAppend, %dump%, %dumpFile%, UTF-8
    if (hits.Length() = 0) {
        MsgBox, 0x30, alia, % "No int equal to " maxPlFallback " found in the Players service.`nCheck the value, or look at:`n" dumpFile
        return
    }
    list := ""
    for _, h in hits
        list .= "0x" Format("{:X}", h) " "
    off_Players_MaxPlayers := hits[1]
    IniWrite, %off_Players_MaxPlayers%, %settingsFile%, keys, maxpoff
    msg := "Matches for " maxPlFallback ": " list "`nUsing 0x" Format("{:X}", off_Players_MaxPlayers) " and saved it."
    if (hits.Length() > 1)
        msg .= "`n`nMore than one match (MaxPlayers and PreferredPlayers can be equal). Use Send info, and if the count looks wrong tell me which offsets showed up - the full list is in:`n" dumpFile
    MsgBox, 0x40, alia, %msg%
}

; no-input detection: MaxPlayers and PreferredPlayers sit next to each other and hold the same value,
; so look for two adjacent equal ints (2..300) that are >= the current player count
