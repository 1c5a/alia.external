GetAttribute(hProc, inst, name, default := "") {
    for _, n in AttrNodes(hProc, inst) {
        if (n.name == name) {
            v := AttrValue(hProc, n.node)
            return (v = "") ? default : v
        }
    }
    return default
}

; every attribute of an instance as {name: value}
