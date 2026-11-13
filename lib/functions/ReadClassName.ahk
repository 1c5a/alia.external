ReadClassName(hProc, pClassDesc) {
    if (pClassDesc < 0x10000)
        return ""
    for _, off in [0x8, 0x10] {
        p := ReadPtr(hProc, pClassDesc + off)
        if (p < 0x10000)
            continue
        s := ReadStdString(hProc, p)
        if IsClassName(s)
            return s
        s := ReadCStr(hProc, p)
        if IsClassName(s)
            return s
        s := ReadCStr(hProc, ReadPtr(hProc, p))
        if IsClassName(s)
            return s
    }
    return ""
}

