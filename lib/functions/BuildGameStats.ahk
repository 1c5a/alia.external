BuildGameStats() {
    global gameId, GameDefs, statNames, statOn, sideBottom, sideRight, sideLeft
    statNames := {}
    sideBottom := []
    sideRight := []
    sideLeft := []
    defs := GameDefs[gameId]
    if !IsObject(defs)
        return
    active := []
    for _, d in defs {
        statNames[d.name] := true
        if statOn[d.name]
            active.Push(d)
    }
    n := active.Length()
    base := n // 3
    rem := Mod(n, 3)
    nb := base + ((rem >= 1) ? 1 : 0)
    nr := base + ((rem >= 2) ? 1 : 0)
    idx := 1
    Loop %nb% {
        sideBottom.Push(active[idx])
        idx++
    }
    Loop %nr% {
        sideRight.Push(active[idx])
        idx++
    }
    while (idx <= n) {
        sideLeft.Push(active[idx])
        idx++
    }
}

; ratio (0..1) of a DoubleConstrainedValue; false if the read looks invalid
