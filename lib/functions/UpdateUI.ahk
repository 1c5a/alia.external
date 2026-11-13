UpdateUI() {
    global ui, offsetNote, players, streamProof, gameId, profIsCustom
    if !IsObject(ui)
        return
    el := ui.Find("stOffsets")
    if IsObject(el)
        el.label := "Offsets: " offsetNote
    el := ui.Find("stGame")
    if IsObject(el)
        el.label := "Players: " players.Length() " | Stream-proof: " (streamProof ? "ON" : "OFF") " | Game: " (gameId > 0 ? gameId : "?") (profIsCustom ? " (custom)" : "")
    ui.Redraw()
}

