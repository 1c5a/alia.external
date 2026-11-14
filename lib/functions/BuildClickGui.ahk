BuildClickGui() {
    global hClickGui
    hClickGui := 0
}

OnRing(tab) {
    global ui
    ui.Hide()
    ShowFeatureClickGui(tab)
}

ShowFeatureClickGui(tab) {
    global hClickGui, espAccent, espKey, hookKey, camlockKey
    Gui, ClickGUI:Destroy
    accent := Format("{:06X}", espAccent & 0xFFFFFF)
    titles := {1: "Visuals", 2: "Gank Ping Macro", 3: "Info", 4: "Debug", 5: "Quality of Life", 6: "Settings"}
    title := titles.HasKey(tab) ? titles[tab] : "Features"
    Gui, ClickGUI:New, +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox +HwndhClickGui, % "esp.ahk - " title
    Gui, ClickGUI:Color, 15151F
    Gui, ClickGUI:Margin, 16, 14
    Gui, ClickGUI:Font, s11 c%accent%, Segoe UI
    Gui, ClickGUI:Add, Text, xm ym w330 h28, %title%
    Gui, ClickGUI:Font, s9 cA8A8B5, Segoe UI
    Gui, ClickGUI:Add, Text, xm y+2 w330 h22, Click a feature to open its configuration
    Gui, ClickGUI:Font, s10 cFFFFFF, Segoe UI

    if (tab = 1) {
        Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_PlayerESP, % "Player ESP    [" espKey "]"
        Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_MobESP, Mob ESP
    } else if (tab = 2) {
        Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_Gank, % "Gank Ping Macro    [" hookKey "]"
    } else if (tab = 4) {
        Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_Debug, Debug
    } else if (tab = 5) {
        Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_Walkspeed, Walkspeed Multiplier
        Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Spectate, Spectate
        Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Camlock, % "Camlock    [" camlockKey "]    #" accent
    } else if (tab = 6) {
        Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_Settings, UI Settings
    } else {
        Gui, ClickGUI:Add, Text, xm y+14 w330 h32 cA8A8B5, No configurable features in this category.
    }
    Gui, ClickGUI:Add, Button, xm y+16 w330 h30 gClickGUI_Close, Back to radial menu
    Gui, ClickGUI:Show, AutoSize, % "esp.ahk - " title
    WinActivate, ahk_id %hClickGui%
}
