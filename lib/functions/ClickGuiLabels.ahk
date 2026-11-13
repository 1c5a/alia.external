ClickGUI_PlayerESP:
    OpenFeatureConfig(1)
return

ClickGUI_MobESP:
    OpenFeatureConfig(1)
return

ClickGUI_Gank:
    OpenFeatureConfig(2)
return

ClickGUI_Walkspeed:
    OpenFeatureConfig(5)
return

ClickGUI_Spectate:
    OpenFeatureConfig(5)
return

ClickGUI_Camlock:
    OpenFeatureConfig(5)
return

ClickGUI_Debug:
    OpenFeatureConfig(4)
return

ClickGUI_Close:
ClickGUIGuiClose:
    Gui, ClickGUI:Hide
    clickGuiOn := false
return
