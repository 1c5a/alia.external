GetAttributes(hProc, inst) {
    out := {}
    for _, n in AttrNodes(hProc, inst) {
        if (SubStr(n.name, 1, 1) != "<")
            out[n.name] := AttrValue(hProc, n.node)
    }
    return out
}

; text block for the dump: every attribute with its decoded value and the first 16 raw bytes of the value slot
; (when nothing can be read: the raw container / list / node bytes so the layout can be worked out)
