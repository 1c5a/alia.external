Defer(fnName) {
    fn := Func(fnName)
    SetTimer, % fn, -10
}

; the library flips toggles and fires events for bound keys everywhere; true if this event came
; from the physical key being held rather than from a click on the menu
