SendInfo() {
    global hProc, dllBase, static_FakeDM, off_FDM_RealDM, off_Players_LocalPlayer
    global off_TextLabel_Text, off_Players_MaxPlayers, webhookUrl, maxPlFallback, gameId, settingsFile, appDir
    global msgText, embedColor, shotOn, uploadBusy
    if uploadBusy {
        Tip("Still sending the previous one...")
        return
    }

    if !RegExMatch(webhookUrl, "i)^https://(discord|discordapp)\.com/api/webhooks/\d+/[\w-]+$") {
        Tip("Set a valid Discord webhook URL in the settings window first")
        return
    }
    if (off_TextLabel_Text < 0x10) {
        Tip("GuiObject::Text offset missing - set it in the settings window", 4000)
        return
    }
    pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
    pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
    if (pRealDM < 0x10000) {
        Tip("DataModel not found")
        return
    }
    pPlayersSvc := FindChildByClass(hProc, pRealDM, "Players")
    pLocal := pPlayersSvc ? ReadPtr(hProc, pPlayersSvc + off_Players_LocalPlayer) : 0
    pGui := pLocal ? FindChildByName(hProc, pLocal, "PlayerGui") : 0
    if !pGui {
        Tip("PlayerGui not found (are you in a server?)")
        return
    }

    ; label, path under PlayerGui (each ends at a TextLabel)
    items := []
    items.Push(["Server Name", "TopbarGui.Container.InfoFrame.ServerInfo.ServerTitle"])
    items.Push(["Region", "TopbarGui.Container.InfoFrame.ServerInfo.ServerRegion"])
    items.Push(["Age", "TopbarGui.Container.InfoFrame.ServerInfo.ServerAge"])
    items.Push(["Luminant", "TopbarGui.Container.InfoFrame.GameInfo.Realm"])
    items.Push(["Area", "AreaGui.AreaScroll.Clipper.AreaHeader"])

    fields := ""
    for _, it in items {
        node := WalkPath(hProc, pGui, it[2])
        if !node
            val := "(not found)"
        else {
            val := ReadTextProp(hProc, node)
            if (val = "")
                val := "(empty/unreadable)"
        }
        fields .= (fields != "" ? "," : "") . EmbedField(it[1], val, true)
    }

    ; player count = children of Players service / max players
    cur := pPlayersSvc ? GetChildren(hProc, pPlayersSvc).Length() : 0
    mx := 0
    if (off_Players_MaxPlayers > 0) {
        mx := ReadUInt32(hProc, pPlayersSvc + off_Players_MaxPlayers)
        if (mx < 1 || mx > 500 || mx < cur)
            mx := 0
    }
    if (mx = 0 && pPlayersSvc) {
        ; stored/dump offset missing or gives an implausible value: find it automatically
        found := AutoFindMaxPlayers(hProc, pPlayersSvc, cur)
        if (found > 0) {
            off_Players_MaxPlayers := found
            IniWrite, %found%, %settingsFile%, keys, maxpoff
            mx := ReadUInt32(hProc, pPlayersSvc + found)
        }
    }
    if (mx = 0 && maxPlFallback > 0)
        mx := maxPlFallback
    pc := cur " / " (mx > 0 ? mx : "?") " players"
    fields .= "," . EmbedField("Player Count", pc, true)

    ts := SubStr(A_NowUTC, 1, 4) "-" SubStr(A_NowUTC, 5, 2) "-" SubStr(A_NowUTC, 7, 2)
    ts .= "T" SubStr(A_NowUTC, 9, 2) ":" SubStr(A_NowUTC, 11, 2) ":" SubStr(A_NowUTC, 13, 2) "Z"
    colorDec := 5793266
    if RegExMatch(embedColor, "^[0-9A-Fa-f]{6}$") {
        cv := 0
        Loop, Parse, embedColor
            cv := cv * 16 + (InStr("0123456789ABCDEF", A_LoopField) - 1)
        colorDec := cv
    }
    if colorDec is not integer
        colorDec := 5793266

    shotFile := ""
    if shotOn
        shotFile := TakeGameShot()
    img := (shotFile != "") ? ",""image"":{""url"":""attachment://shot.jpg""}" : ""
    content := (msgText != "") ? """content"":""" JsonEsc(msgText) """," : ""
    body := "{" content """embeds"":[{""title"":""Deepwoken server info"",""color"":" colorDec ",""fields"":[" fields "],""timestamp"":""" ts """" img "}]}"

    err := ""
    if (shotFile != "") {
        ; preferred: upload in a background curl process so this script doesn't freeze
        if StartAsyncUpload(webhookUrl, body, shotFile) {
            Tip("Sending...", 1500)
            return
        }
        ok := PostWebhookFile(webhookUrl, body, shotFile, err)
    } else
        ok := PostWebhook(webhookUrl, body, err)
    CleanShotCache()
    if ok
        Tip("Info sent to webhook" ((shotOn && shotFile = "") ? " (screenshot failed)" : ""))
    else {
        Tip("Webhook failed: " err, 8000)
        errLog := appDir "\webhook_error.txt"
        FileDelete, %errLog%
        FileAppend, % err "`n`nPayload:`n" body, %errLog%, UTF-8
    }
}

; scans the Players service for a 32-bit int equal to the real max player count you typed in
; ("Max players" box), saves the offset, and writes every small int it saw to players_dump.txt
