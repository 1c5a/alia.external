BuildAliaUi() {
    global ui, uiKey, espKey, hookKey, espAccent, settingsFile
    global espOn, shotOn, webhookUrl, msgText, embedColor, maxPlFallback, MAX_DIST, camlockMaxDist
    global off_TextLabel_Text, off_DCV_Value, off_DCV_Max, FADE_STEP
    global statItems, tagItems, fontNames, fontIdx
    global camlockKey, camlockHoldKey, camlockFovOn, camlockFovFill, camlockFovAlpha

    ui := new AliaUI({TAB_W: 700, TAB_H: 480, Accent: espAccent, ToggleKey: uiKey})
    embedInt := RegExMatch(embedColor, "^[0-9A-Fa-f]{6}$") ? _HexToInt(embedColor) : 0x7885FA
    pd := MAX_DIST
    if (pd < 100)
        pd := 100
    if (pd > 10000)
        pd := 10000

    ui.AddIcon("bug-play", "M 10 19.66 C 7.6 18.81 6 16.54 6 14 L 6 11 C 6 8.79 7.79 7 10 7 L 14 7 C 16.2 7 17.98 8.77 18 10.97 M 14 15 C 14 14.64 14.19 14.31 14.51 14.13 C 14.82 13.95 15.21 13.96 15.52 14.14 L 20.51 17.14 C 20.82 17.32 21 17.65 21 18 C 21 18.35 20.82 18.68 20.51 18.86 L 15.52 21.86 C 15.21 22.04 14.82 22.05 14.51 21.87 C 14.19 21.69 14 21.36 14 21 Z M 14.12 3.88 L 16 2 M 21 5 C 21 7.03 19.47 8.74 17.45 8.97 M 3 21 C 3 18.86 4.68 17.1 6.81 17 M 3 5 C 3 7.03 4.53 8.74 6.55 8.97 M 6 13 L 2 13 M 8 2 L 9.88 3.88 M 9 7.13 L 9 6 C 9 4.34 10.34 3 12 3 C 13.66 3 15 4.34 15 6 L 15 7.13")
    ui.AddIcon("shield-exclamation-point", "M 20 13 C 20 18 16.5 20.5 12.34 21.95 C 12.12 22.02 11.89 22.02 11.67 21.94 C 7.5 20.5 4 18 4 13 L 4 6 C 4 5.45 4.45 5 5 5 C 7 5 9.5 3.8 11.24 2.28 C 11.68 1.91 12.32 1.91 12.76 2.28 C 14.51 3.81 17 5 19 5 C 19.55 5 20 5.45 20 6 Z M 12 8 L 12 12 M 12 16 L 12.01 16")
    ui.AddIcon("eye-dashed", "M 13.05 18.95 C 12.35 19.01 11.65 19.01 10.94 18.95 M 13.05 5.05 C 12.35 4.99 11.65 4.99 10.94 5.05 M 17.07 6.27 C 17.69 6.61 18.28 7 18.82 7.45 M 18.82 16.55 C 18.28 17 17.69 17.39 17.07 17.73 M 2.51 13.3 C 2.35 12.99 2.2 12.67 2.06 12.35 C 1.98 12.12 1.98 11.88 2.06 11.65 C 2.2 11.33 2.35 11.01 2.51 10.7 M 21.48 10.7 C 21.65 11.01 21.8 11.33 21.94 11.65 C 22.02 11.88 22.02 12.12 21.94 12.35 C 21.8 12.67 21.65 12.99 21.48 13.3 M 5.17 7.45 C 5.72 7 6.31 6.61 6.93 6.27 M 6.93 17.73 C 6.31 17.39 5.72 17 5.17 16.55 M 15 12 C 15 13.66 13.66 15 12 15 C 10.34 15 9 13.66 9 12 C 9 10.34 10.34 9 12 9 C 13.66 9 15 10.34 15 12 Z")

    ui.Tab(1, "Visuals", "eye-dashed")

    ui.Add(1, {type: "dropdown", key: "espfont", label: "ESP Font", items: fontNames, value: fontIdx})

    ui.Add(1, {type: "header", label: "Player ESP"})
    ui.Add(1, {type: "toggle", key: "playeresp", label: "Enable Player ESP", value: espOn ? 1 : 0, bind: espKey})
    ui.Add(1, {type: "toggle", key: "playerbars", label: "Bars", value: 0, dep: "playeresp"})
    ui.Add(1, {type: "toggle", key: "playerhealthbar", label: "Health Bar", value: 0, dep: "playerbars"})
    ui.Add(1, {type: "slider", key: "playerhpbarwidth", label: "Health Bar Width", lo: 1, hi: 50, step: 1, value: 10, suffix: "px", dep: "playerhealthbar"})
    ui.Add(1, {type: "multidropdown", key: "playerespbars", label: "Misc. Bars", items: statItems, value: "None", dep: "playerbars"})
    ui.Add(1, {type: "toggle", key: "playertext", label: "Text", value: 0, dep: "playeresp"})
    ui.Add(1, {type: "color", key: "playertextcolor", label: "Text Color", color: 0xFFFFFF, dep: "playertext"})
    ui.Add(1, {type: "slider", key: "playertextsize", label: "Text Size", lo: 8, hi: 24, step: 1, value: 14, dep: "playertext"})
    ui.Add(1, {type: "multidropdown", key: "playeresptags", label: "ESP Tags", items: tagItems, value: 1, dep: "playertext"})
    ui.Add(1, {type: "toggle", key: "playerboxtoggle", label: "ESP Boxes", value: 1, color: 0x000000, dep: "playeresp"})
    ui.Add(1, {type: "slider", key: "playerdist", label: "Max distance", lo: 100, hi: 10000, step: 1, value: pd, suffix: "m", dep: "playeresp"})

    ui.Add(1, {type: "header", label: "Mob ESP"})
    ui.Add(1, {type: "toggle", key: "mobesp", label: "Enable Mob ESP", value: 0, bind: "None"})
    ui.Add(1, {type: "toggle", key: "mobhealthbar", label: "Show Health Bar", value: 0, dep: "mobesp"})
    ui.Add(1, {type: "slider", key: "mobhpbarwidth", label: "Health Bar Width", lo: 1, hi: 50, step: 1, value: 10, suffix: "px", dep: "mobhealthbar"})
    ui.Add(1, {type: "toggle", key: "mobtext", label: "Text", value: 0, dep: "mobesp"})
    ui.Add(1, {type: "color", key: "mobtextcolor", label: "Text Color", color: 0xFFFFFF, dep: "mobtext"})
    ui.Add(1, {type: "slider", key: "mobtextsize", label: "Text Size", lo: 8, hi: 24, step: 1, value: 14, dep: "mobtext"})
    ui.Add(1, {type: "slider", key: "mobdist", label: "Max distance", lo: 100, hi: 10000, step: 1, value: 1000, suffix: "m", dep: "mobesp"})

    ui.Tab(2, "Gank Ping Macro", "shield-exclamation-point")
    ui.Add(2, {type: "header", label: "WEBHOOK"})
    ui.Add(2, {type: "input", key: "webhook", label: "Webhook URL", value: webhookUrl, masked: 1})
    ui.Add(2, {type: "input", key: "message", label: "Message", value: msgText, masked: 0})
    ui.Add(2, {type: "color", key: "embedcolor", label: "Embed color", color: embedInt})
    ui.Add(2, {type: "toggle", key: "shot", label: "Screenshot", value: shotOn ? 1 : 0})
    ui.Add(2, {type: "keybind", key: "sendkey", label: "Ping Key", bind: hookKey})
    ui.Add(2, {type: "button", key: "sendnow", label: "Send Ping"})

    ui.Tab(3, "Info", "info")
    ui.Add(3, {type: "header", label: "not added"})

    ui.Tab(4, "Debug", "bug-play")
    ui.Add(4, {type: "header", label: "STATUS"})
    ui.Add(4, {type: "label", key: "stOffsets", label: ""})
    ui.Add(4, {type: "label", key: "stGame", label: ""})
    ui.Add(4, {type: "buttons", key: "dbgbtns", items: ["Debug info", "Re-fetch offsets", "Dump stats"]})
    ui.Add(4, {type: "input", key: "textoff", label: "Text offset", value: (off_TextLabel_Text > 0) ? Format("0x{:X}", off_TextLabel_Text) : "", masked: 0})
    ui.Add(4, {type: "input", key: "maxpl", label: "Max players", value: (maxPlFallback > 0) ? maxPlFallback : "", masked: 0})
    ui.Add(4, {type: "input", key: "dcvval", label: "Stat value offset", value: Format("0x{:X}", off_DCV_Value), masked: 0})
    ui.Add(4, {type: "input", key: "dcvmax", label: "Stat max offset", value: Format("0x{:X}", off_DCV_Max), masked: 0})
    ui.Add(4, {type: "toggle", key: "dbgmobs", label: "Mob ESP debug readout", value: 0, bind: "None"})
    ui.Add(4, {type: "button", key: "findmax", label: "Find max-players offset"})
    ui.Add(4, {type: "button", key: "dumpattrs", label: "Dump attributes (character, humanoid, nearest mob)"})
    ui.Add(4, {type: "input", key: "camoff", label: "Workspace camera offset", value: (off_WS_Camera > 0) ? Format("0x{:X}", off_WS_Camera) : "", masked: 0})
    ui.Add(4, {type: "input", key: "attrnameoff", label: "Attribute name offset", value: Format("0x{:X}", off_Attr_Name), masked: 0})

    ui.Tab(5, "Quality of Life", "sparkles")
    ui.Add(5, {type: "header", label: "Movement"})
    ui.Add(5, {type: "toggle", key: "walkspeedon", label: "Walkspeed Multiplier", value: 0, bind: "None"})
    ui.Add(5, {type: "slider", key: "walkspeedmin", label: "Min speed", lo: 0, hi: 300, step: 1, value: 20, dep: "walkspeedon"})
    ui.Add(5, {type: "slider", key: "walkspeedmax", label: "Max speed", lo: 0, hi: 300, step: 1, value: 20, dep: "walkspeedon"})

    ui.Add(5, {type: "header", label: "Spectate"})
    ui.Add(5, {type: "label", key: "spectlbl", label: "Spectating: off (RMB or arrows to orbit, PgUp/PgDn zoom)"})
    ui.Add(5, {type: "button", key: "specwin", label: "Open player list (click to spectate)"})
    ui.Add(5, {type: "buttons", key: "spectbtns", items: ["Previous", "Next", "Stop"]})

    ui.Add(5, {type: "header", label: "Camlock"})
    ui.Add(5, {type: "toggle", key: "camlockon", label: "Enable Camlock (cursor lock)", value: 0, bind: camlockKey})
    ui.Add(5, {type: "keybind", key: "camlockhold", label: "Camlock hold key", bind: camlockHoldKey, dep: "camlockon"})
    ui.Add(5, {type: "slider", key: "camlocksmooth", label: "Smoothing (0=fast, 100=slow)", lo: 0, hi: 100, step: 1, value: Round(camlockSmooth * 100), dep: "camlockon"})
    ui.Add(5, {type: "toggle", key: "camlockfovon", label: "Use FOV circle", value: camlockFovOn ? 1 : 0, dep: "camlockon"})
    ui.Add(5, {type: "slider", key: "camlockfov", label: "FOV radius (px)", lo: 10, hi: 600, step: 5, value: camlockFOV, dep: "camlockon,camlockfovon"})
    ui.Add(5, {type: "toggle", key: "camlockfovfill", label: "Fill FOV circle", value: camlockFovFill ? 1 : 0, dep: "camlockon,camlockfovon"})
    ui.Add(5, {type: "slider", key: "camlockfovalpha", label: "FOV fill transparency", lo: 0, hi: 100, step: 5, value: camlockFovAlpha, suffix: "%", dep: "camlockon,camlockfovon,camlockfovfill"})
    ui.Add(5, {type: "slider", key: "camlockdist", label: "Max target distance (studs)", lo: 10, hi: 10000, step: 10, value: camlockMaxDist + 0, suffix: " studs", dep: "camlockon"})
    ui.Add(5, {type: "slider", key: "camlockheady", label: "Aim height above HRP", lo: 0, hi: 50, step: 1, value: Round(camlockHeadY * 10), suffix: "/10 wu", dep: "camlockon"})
    ui.Add(5, {type: "label", key: "camlockstatus", label: "Target: none", dep: "camlockon"})

    ui.OnEvent(Func("OnUI"))
    ui.Start()
    LoadAllUiConfig()

    IniRead, fadeIdx, %settingsFile%, keys, fade, 2
    fadeIdx := (fadeIdx = 1 || fadeIdx = 3) ? fadeIdx + 0 : 2
    ui.Set("fadespeed", fadeIdx)
    FADE_STEP := [0.1, 0.2, 0.35][fadeIdx]

    SyncVisuals()
    UpdateUI()
    ui.Hide()
}

; the menu is open (or fading) - the ESP keeps drawing while it is
