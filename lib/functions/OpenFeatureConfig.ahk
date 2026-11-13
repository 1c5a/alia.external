OpenFeatureConfig(tab) {
    global clickGuiOn, ui, mode
    Gui, ClickGUI:Hide
    clickGuiOn := false
    ui.Show()
    mode := "ring"
    OpenTab(tab)
    DrawRing()
}
