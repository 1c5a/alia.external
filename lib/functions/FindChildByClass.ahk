FindChildByClass(hProc, inst, cls) {
    global off_Inst_ClassDesc
    for _, c in GetChildren(hProc, inst) {
        if (ReadClassName(hProc, ReadPtr(hProc, c + off_Inst_ClassDesc)) = cls)
            return c
    }
    return 0
}

; ---- Deepwoken info -> Discord webhook (reads values from your own client's UI) ----

