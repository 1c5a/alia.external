AttrNodes(hProc, inst) {
    global off_Inst_AttrContainer, off_Inst_AttrList, off_Attr_Next, off_Attr_Name, attrNameTried
    list := []
    if (inst < 0x10000)
        return list
    cont := ReadPtr(hProc, inst + off_Inst_AttrContainer)
    if (cont < 0x10000)
        return list
    node := ReadPtr(hProc, cont + off_Inst_AttrList)
    guard := 0
    while (node > 0x10000 && node < 0x7FFFFFFFFFFF && guard < 300) {
        list.Push({name: "", node: node})
        node := ReadPtr(hProc, node + off_Attr_Next)
        guard++
    }
    if (list.Length() = 0)
        return list
    if (SubStr(ReadNameAt(hProc, list[1].node + off_Attr_Name), 1, 1) = "<" && !attrNameTried) {
        attrNameTried := true
        AttrFindNameOff(hProc, list[1].node)
    }
    for _, n in list
        n.name := ReadNameAt(hProc, n.node + off_Attr_Name)
    return list
}

; looks for a readable name (std::string or pointer to one) at 8-byte steps inside an attribute node
