DbgMob(name, msg) {
    global dbgOut, dbgCnt
    if (dbgCnt >= 15)
        return
    dbgCnt++
    dbgOut .= name ": " msg "`n"
}

