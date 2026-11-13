SpecStep(delta) {
    global players, specName
    n := players.Length()
    if (n = 0) {
        Tip("No other players found")
        return
    }
    idx := 0
    for i, pl in players {
        if (pl.name = specName)
            idx := i
    }
    if idx
        idx += delta
    else
        idx := (delta > 0) ? 1 : n
    if (idx > n)
        idx := 1
    if (idx < 1)
        idx := n
    SpecSelectName(players[idx].name)
}

; starts the spectate loop (the 15 ms timer only restarts it if it ever stopped)
