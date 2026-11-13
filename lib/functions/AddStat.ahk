AddStat(gid, name, label, color) {
    global GameDefs
    if !IsObject(GameDefs[gid])
        GameDefs[gid] := []
    GameDefs[gid].Push({name: name, label: label, color: color})
}

; splits the enabled stats as evenly as possible across bottom, right and left
