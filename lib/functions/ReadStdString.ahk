ReadStdString(hProc, addr) {
    if (addr < 0x10000)
        return ""
    len := ReadUInt32(hProc, addr + 0x10)
    cap := ReadUInt32(hProc, addr + 0x18)
    if (len < 1 || len > 128)
        return ""
    if (cap < 16)
        dataPtr := addr
    else
        dataPtr := ReadPtr(hProc, addr)
    return ReadPrintable(hProc, dataPtr, len)
}

