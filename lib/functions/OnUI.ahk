OnUI(key, value, extra) {
    global ui, hwnd, espOn, shotOn, webhookUrl, msgText, embedColor, maxPlFallback, MAX_DIST
    global off_TextLabel_Text, off_DCV_Value, off_DCV_Max, settingsFile, espAccent
    global wsOn, wsMin, wsMax, off_Hum_MoveDir, dbgMobs, off_Attr_Name, off_WS_Camera
    global camlockOn, camlockSmooth, camlockFOV, camlockHeadY, camlockTarget, camlockHoldKey, camlockMaxDist, camlockFovOn, camlockFovFill, camlockFovAlpha, camlockTargetPart, camlockHoldLatched, camlockHoldPrev, camlockSticky

    ; bound keys pressed in another program (menu closed) must not do anything
    if (!RegExMatch(key, "_(bind|alpha|color)$") && key != "togglekey" && IsBindFire(key) && !UiOpen() && !WinActive("ahk_id " hwnd)) {
        el := ui.Find(key)
        if (IsObject(el) && el.type = "toggle") {
            el.value := value ? 0 : 1
            ui.Redraw()
        }
        return
    }

    if RegExMatch(key, "^(playeresp|sendkey|togglekey)_bind$", bm) {
        HandleBind(bm1, value)
    } else if (key = "camlockhold_bind") {
        camlockHoldKey := (value = "" || value = "None") ? "None" : value
        SaveCamlockConfig()
    } else if (key = "camlockhold_mode") {
        camlockHoldLatched := false
        camlockHoldPrev := false
        SaveAllUiConfig()
        SaveIniConfigToJson()
    } else if (key = "playeresp") {
        espOn := value ? true : false
    } else if (key = "playerdist") {
        MAX_DIST := Round(value)
        QueueProfileSave()
    } else if RegExMatch(key, "^(player|mob)") {
        SyncVisuals()
    } else if (key = "walkspeedon") {
        if (value && off_Hum_MoveDir < 0x10) {
            Tip("Humanoid::MoveDirection offset not found in the offsets dump", 4000)
            wsOn := false
        } else
            wsOn := value ? true : false
    } else if (key = "dbgmobs") {
        dbgMobs := value ? true : false
        if !dbgMobs
            ToolTip
    } else if (key = "walkspeedmin") {
        wsMin := IsNum(value) ? Round(value) : 0
    } else if (key = "walkspeedmax") {
        wsMax := IsNum(value) ? Round(value) : 0
    } else if (key = "camlockon") {
        camlockOn := value ? true : false
        if !camlockOn {
            camlockTarget := ""
            ToolTip
            el2 := ui.Find("camlockstatus")
            if IsObject(el2) {
                el2.label := "Target: none"
                ui.Redraw()
            }
        }
    } else if (key = "camlocksmooth") {
        camlockSmooth := Max(0.0, Min(1.0, value / 100))
        SaveCamlockConfig()
    } else if (key = "camlockfovon") {
        camlockFovOn := value ? true : false
        SaveCamlockConfig()
    } else if (key = "camlockfovfill") {
        camlockFovFill := value ? true : false
        SaveCamlockConfig()
    } else if (key = "camlockfovalpha") {
        camlockFovAlpha := Max(0, Min(100, Round(value)))
        UpdateFovBrushes()
        SaveCamlockConfig()
    } else if (key = "camlockfov") {
        camlockFOV := Round(value)
        SaveCamlockConfig()
    } else if (key = "camlockdist") {
        if !IsNum(value)
            return
        camlockMaxDist := Round(value + 0)
        if (camlockMaxDist < 10)
            camlockMaxDist := 10
        else if (camlockMaxDist > 10000)
            camlockMaxDist := 10000
        SaveCamlockConfig()
    } else if (key = "camlockheady") {
        camlockHeadY := value / 10
        SaveCamlockConfig()
    } else if (key = "camlockpart") {
        camlockTargetPart := (value = 2 || value = "Head") ? "Head" : "HumanoidRootPart"
        camlockTarget := ""
        SaveCamlockConfig()
    } else if (key = "camlocksticky") {
        camlockSticky := value ? true : false
        SaveCamlockConfig()
    } else if (key = "webhook") {
        webhookUrl := Trim(value)
        IniWrite, %webhookUrl%, %settingsFile%, keys, webhook
    } else if (key = "message") {
        msgText := Trim(value)
        IniWrite, %msgText%, %settingsFile%, keys, message
    } else if (key = "embedcolor") {
        embedColor := Format("{:06X}", value)
        IniWrite, %embedColor%, %settingsFile%, keys, embedcolor
    } else if (key = "shot") {
        shotOn := value ? 1 : 0
        IniWrite, %shotOn%, %settingsFile%, keys, screenshot
    } else if (key = "sendkey" || key = "sendnow") {
        Defer("SendInfo")
    } else if (key = "espfont") {
        SetFont(value)
    } else if (key = "dbgbtns") {
        if (value = 1)
            Defer("ShowDebug")
        else if (value = 2)
            Defer("RefetchOffsets")
        else
            Defer("ShowStatDump")
    } else if (key = "textoff") {
        if (IsNum(value) && value + 0 >= 0x10 && value + 0 <= 0x4000) {
            off_TextLabel_Text := value + 0
            IniWrite, %off_TextLabel_Text%, %settingsFile%, keys, textoff
        }
    } else if (key = "maxpl") {
        maxPlFallback := IsNum(value) ? (value + 0) : 0
        IniWrite, %maxPlFallback%, %settingsFile%, keys, maxplayers
    } else if (key = "dcvval" || key = "dcvmax") {
        if (IsNum(value) && value + 0 >= 0x40 && value + 0 <= 0x400) {
            if (key = "dcvval")
                off_DCV_Value := value + 0
            else
                off_DCV_Max := value + 0
            IniWrite, %off_DCV_Value%, %settingsFile%, keys, dcvvalue
            IniWrite, %off_DCV_Max%, %settingsFile%, keys, dcvmax
        }
    } else if (key = "specwin") {
        Defer("ShowSpecWindow")
    } else if (key = "spectbtns") {
        if (value = 1)
            SpecStep(-1)
        else if (value = 2)
            SpecStep(1)
        else
            SpecStop("Spectating: off")
    } else if (key = "camoff") {
        if (IsNum(value) && value + 0 >= 0x10 && value + 0 <= 0x2000) {
            off_WS_Camera := value + 0
            IniWrite, %off_WS_Camera%, %settingsFile%, keys, camoff
        }
    } else if (key = "dumpattrs") {
        Defer("ShowAttrDump")
    } else if (key = "attrnameoff") {
        if (IsNum(value) && value + 0 >= 0 && value + 0 <= 0x100) {
            off_Attr_Name := value + 0
            IniWrite, %off_Attr_Name%, %settingsFile%, keys, attrnameoff
        }
    } else if (key = "findmax") {
        Defer("FindMaxPlayersOffset")
    } else if (key = "uiaccent") {
        espAccent := value
        IniWrite, %value%, %settingsFile%, keys, accent
        UpdateFovBrushes()
    } else if (key = "fadespeed") {
        IniWrite, %value%, %settingsFile%, keys, fade
    } else if (key = "togglekey") {
        SetTimer, ActivateGame, -450
    }
}

; keeps the key variables in sync with the menu, refuses a key another action already uses
