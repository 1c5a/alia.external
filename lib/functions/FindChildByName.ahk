FindChildByName(hProc, inst, name) {
    global off_Inst_NameCont
    for _, c in GetChildren(hProc, inst) {
        if (ReadNameAt(hProc, c + off_Inst_NameCont) = name)
            return c
    }
    return 0
}

