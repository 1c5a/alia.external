AttrFindNameOff(hProc, node) {
    global off_Attr_Name, settingsFile
    o := 0
    while (o <= 0x60) {
        nm := ReadNameAt(hProc, node + o)
        if RegExMatch(nm, "^[A-Za-z_][A-Za-z0-9_ ]{1,40}$") {
            off_Attr_Name := o
            IniWrite, %o%, %settingsFile%, keys, attrnameoff
            return true
        }
        o += 8
    }
    return false
}

