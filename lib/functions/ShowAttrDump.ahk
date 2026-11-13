ShowAttrDump() {
    global hProc, localChr, localHum, localPrim, mobs, appDir, off_Prim_Position
    global off_Inst_AttrContainer, off_Inst_AttrList, off_Attr_Next, off_Attr_Value, off_Attr_Name
    global attrNameTried
    attrNameTried := false
    Gui, UI:+OwnDialogs
    out := "Attribute offsets: container 0x" Format("{:X}", off_Inst_AttrContainer) " | list 0x" Format("{:X}", off_Inst_AttrList) " | name 0x" Format("{:X}", off_Attr_Name) " | next 0x" Format("{:X}", off_Attr_Next) " | value 0x" Format("{:X}", off_Attr_Value) "`n"
    out .= "Format: name = value [first 16 raw bytes of the value slot]`n`n"
    out .= AttrBlock("local character", localChr)
    out .= AttrBlock("local humanoid", localHum)
    lx := 0
    ly := 0
    lz := 0
    hasLocal := localPrim ? ReadVec3(hProc, localPrim + off_Prim_Position, lx, ly, lz) : false
    best := ""
    bestD := 1e18
    for _, mb in mobs {
        x := 0
        y := 0
        z := 0
        if !ReadVec3(hProc, mb.prim + off_Prim_Position, x, y, z)
            continue
        d := hasLocal ? ((x-lx)**2 + (y-ly)**2 + (z-lz)**2) : 0
        if (d < bestD) {
            bestD := d
            best := mb
        }
    }
    if IsObject(best) {
        out .= AttrBlock("nearest mob (" best.name ")", best.chr)
        out .= AttrBlock("nearest mob humanoid", best.hum)
    } else
        out .= "== nearest mob: none (turn Mob ESP on first)`n"
    f := appDir "\attributes_dump.txt"
    FileDelete, %f%
    FileAppend, %out%, %f%, UTF-8
    MsgBox, 0, Attributes, % SubStr(out, 1, 3500) "`n`nFull dump saved to:`n" f
}

; one line of the mob debug readout (max 15 lines, rebuilt every frame)
