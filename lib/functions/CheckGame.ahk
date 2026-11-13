CheckGame() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, off_DM_GameId, gameId
    Critical
    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    if (pRealDM < 0x10000)
        return
    gid := ReadInt64(hProc, pRealDM + off_DM_GameId)
    if (gid < 1 || gid > 9999999999999 || gid = gameId)
        return
    gameId := gid
    LoadProfile()
    PushProfileToUI()
    UpdateUI()
}

