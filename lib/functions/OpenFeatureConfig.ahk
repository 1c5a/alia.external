OpenFeatureConfig(tab) {
    global clickGuiOn, ui
    Gui, ClickGUI:Hide
    clickGuiOn := false
    ui.Show()
    OpenTab(tab)
    DrawRing()
}
