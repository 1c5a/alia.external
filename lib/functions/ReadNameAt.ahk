ReadNameAt(hProc, addr) {
    if !addr
        return "<null>"
    s := ReadStdString(hProc, ReadPtr(hProc, addr))
    if (s != "")
        return s
    s := ReadStdString(hProc, addr)
    if (s != "")
        return s
    return "<no name>"
}

