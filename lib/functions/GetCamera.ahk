GetCamera() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, off_WS_Camera
    if (off_WS_Camera < 0x10)
        return 0
    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    if (pRealDM < 0x10000)
        return 0
    ws := FindChildByClass(hProc, pRealDM, "Workspace")
    return ws ? ReadPtr(hProc, ws + off_WS_Camera) : 0
}

