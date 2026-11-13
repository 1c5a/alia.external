ToggleClickGui() {
    global clickGuiOn, ui, hClickGui
    if clickGuiOn {
        Gui, ClickGUI:Hide
        clickGuiOn := false
        return
    }
    ui.Hide()
    Gui, ClickGUI:Show
    clickGuiOn := true
    WinActivate, ahk_id %hClickGui%
}
