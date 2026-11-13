AttrBlock(title, inst) {
    global hProc, off_Attr_Value, off_Inst_AttrContainer, off_Inst_AttrList, off_Attr_Next
    out := "== " title " @ 0x" Format("{:X}", inst) "`n"
    if (inst < 0x10000)
        return out " (not available)`n`n"
    nodes := AttrNodes(hProc, inst)
    if (nodes.Length() = 0) {
        cont := ReadPtr(hProc, inst + off_Inst_AttrContainer)
        head := (cont > 0x10000) ? ReadPtr(hProc, cont + off_Inst_AttrList) : 0
        out .= " (no attribute nodes: container 0x" Format("{:X}", cont) ", list head 0x" Format("{:X}", head) ")`n"
        out .= " container bytes:`n " HexAt(hProc, cont, 0x80) "`n"
        out .= " first node bytes:`n " HexAt(hProc, head, 0x80) "`n`n"
        return out
    }
    out .= " " nodes.Length() " nodes in the list`n"
    for i, n in nodes {
        v := AttrValue(hProc, n.node)
        nm := (SubStr(n.name, 1, 1) = "<") ? "(name unreadable)" : n.name
        out .= " " nm " = " ((v = "") ? "?" : v) " [" HexAt(hProc, n.node + off_Attr_Value, 16) "]`n"
    }
    if (SubStr(nodes[1].name, 1, 1) = "<")
        out .= " first node bytes:`n " HexAt(hProc, nodes[1].node, 0x80) "`n"
    return out "`n"
}

