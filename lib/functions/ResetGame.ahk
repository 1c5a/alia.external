ResetGame() {
    global settingsFile, profSection
    if (profSection = "keys") {
        ToolTip, No game detected yet - nothing to reset
        SetTimer, HideTip, -2000
        return
    }
    IniDelete, %settingsFile%, %profSection%
    LoadProfile()
    PushProfileToUI()
    UpdateUI()
    ToolTip, Game profile reset to defaults
    SetTimer, HideTip, -2000
}

; switches profile when you join a different game (GameId changes)
