SpecLabel(txt) {
    global ui
    el := ui.Find("spectlbl")
    if IsObject(el) {
        el.label := txt
        ui.Redraw()
    }
}

; spectate the player with this name right now (also used by the list window)
; the camera is put in Scriptable mode (the game's own camera script stops moving it) and placed behind the player
