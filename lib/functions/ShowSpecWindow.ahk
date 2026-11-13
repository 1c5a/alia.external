ShowSpecWindow() {
    global specListShown
    Gui, SpecWin:Destroy
    Gui, SpecWin:+AlwaysOnTop +ToolWindow
    Gui, SpecWin:Margin, 10, 10
    Gui, SpecWin:Color, 1B1B1F, 26262C
    Gui, SpecWin:Font, s10 cE6E6E6, Segoe UI
    Gui, SpecWin:Add, Text, w240, Click a player to spectate
    Gui, SpecWin:Add, ListBox, vSpecSel gSpecListSel w240 r14
    Gui, SpecWin:Add, Button, gSpecListStop w240 y+8, Stop spectating
    specListShown := "~"
    SpecListFill()
    Gui, SpecWin:Show, AutoSize, Spectate
    SetTimer, SpecListRefresh, 400
}

; back to your own Humanoid (or the one the camera had when spectating started)
