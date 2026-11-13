BuildClickGui() {
    global hClickGui, espAccent, espKey, hookKey, camlockKey
    accent := Format("{:06X}", espAccent & 0xFFFFFF)
    Gui, ClickGUI:New, +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox +HwndhClickGui
    Gui, ClickGUI:Color, 15151F
    Gui, ClickGUI:Margin, 16, 14
    Gui, ClickGUI:Font, s10 cFFFFFF, Segoe UI
    Gui, ClickGUI:Add, Text, xm ym w330 h28 c%accent%, CLICK GUI
    Gui, ClickGUI:Font, s9 cA8A8B5, Segoe UI
    Gui, ClickGUI:Add, Text, xm y+2 w330 h22, Select a feature to open its configuration
    Gui, ClickGUI:Font, s10 cFFFFFF, Segoe UI
    Gui, ClickGUI:Add, Button, xm y+12 w330 h32 gClickGUI_PlayerESP, % "Player ESP    [" espKey "]"
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_MobESP, Mob ESP
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Gank, % "Gank Ping Macro    [" hookKey "]"
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Walkspeed, Walkspeed Multiplier
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Spectate, Spectate
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Camlock, % "Camlock    [" camlockKey "]    #" accent
    Gui, ClickGUI:Add, Button, xm y+6 w330 h32 gClickGUI_Debug, Debug
    Gui, ClickGUI:Add, Button, xm y+12 w330 h30 gClickGUI_Close, Close
    Gui, ClickGUI:Show, Hide, esp.ahk ClickGUI
}
