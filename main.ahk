#NoEnv
#SingleInstance Force
SetBatchLines -1
DllCall("SetProcessDPIAware")

; ============================================================
; Alia UI library: fetched into .\lib on first run, then the script restarts
; ============================================================
AUI_URL := "https://raw.githubusercontent.com/1c5a/alia.external/refs/heads/main/aliaUI.ahk"
AUI_MARKER := "ALIA.UI.LIB"
AUI_FILE := A_ScriptDir "\lib\aliaUI.ahk"
if (!FileExist(AUI_FILE)) {
    FileCreateDir, %A_ScriptDir%\lib
    AUI_TMP := AUI_FILE ".tmp"
    UrlDownloadToFile, %AUI_URL%, %AUI_TMP%
    if (ErrorLevel) {
        MsgBox, 16, AliaUI, Could not download the library from:`n%AUI_URL%
        ExitApp
    }
    FileRead, AUI_HEAD, *m2048 %AUI_TMP%
    if (!InStr(AUI_HEAD, AUI_MARKER)) {
        FileDelete, %AUI_TMP%
        MsgBox, 16, AliaUI, The downloaded file is not the library. Check the URL:`n%AUI_URL%
        ExitApp
    }
    FileMove, %AUI_TMP%, %AUI_FILE%, 1
    if (ErrorLevel || !FileExist(AUI_FILE)) {
        MsgBox, 16, AliaUI, Could not save the library to:`n%AUI_FILE%
        ExitApp
    }
    Reload
    Sleep, 5000
    MsgBox, 16, AliaUI, The script could not restart itself. Start it again by hand.
    ExitApp
}
if (!IsObject(AliaUI)) {
    MsgBox, 16, AliaUI, %AUI_FILE% does not define the class AliaUI.`nDelete the lib folder and start again.
    ExitApp
}

static_FakeDM := 0x8F59810
static_VisualEngine := 0x89DC1A0
off_FDM_RealDM := 0x1F8
off_DM_PlaceId := 0x180
off_DM_GameId := 0x178
off_VE_ViewMatrix := 0x1B0
off_VE_Dimensions := 0xB10
off_Inst_NameCont := 0x68
off_Inst_ChildData := 0x70
off_Inst_ClassDesc := 0x18
off_Players_LocalPlayer := 0x118
off_Player_ModelInstance := 0x290
off_Player_Team := 0x2D0
off_Hum_Health := 0x184
off_Hum_MaxHealth := 0x19C
off_Hum_RootPart := 0x460
off_Part_Primitive := 0x178
off_Prim_Position := 0xD4
CHILD_STRIDE := 16
PROCESS_ALL_ACCESS := 0x1F0FFF

EnvGet, _localAppData, LocalAppData
appDir := _localAppData "\espahk"
if !FileExist(appDir)
    FileCreateDir, %appDir%

mapTable := []
mapTable.Push(["static_FakeDM", "FakeDataModel::Pointer"])
mapTable.Push(["static_VisualEngine", "VisualEngine::Pointer"])
mapTable.Push(["off_FDM_RealDM", "FakeDataModel::RealDataModel"])
mapTable.Push(["off_DM_PlaceId", "DataModel::PlaceId"])
mapTable.Push(["off_DM_GameId", "DataModel::GameId"])
mapTable.Push(["off_VE_ViewMatrix", "VisualEngine::ViewMatrix"])
mapTable.Push(["off_VE_Dimensions", "VisualEngine::Dimensions"])
mapTable.Push(["off_Inst_NameCont", "Instance::NameContainer"])
mapTable.Push(["off_Inst_ChildData", "Instance::ChildrenStart"])
mapTable.Push(["off_Inst_ClassDesc", "Instance::ClassDescriptor"])
mapTable.Push(["off_Players_LocalPlayer", "Player::LocalPlayer"])
mapTable.Push(["off_Player_ModelInstance", "Player::ModelInstance"])
mapTable.Push(["off_Player_Team", "Player::Team"])
mapTable.Push(["off_Hum_Health", "Humanoid::Health"])
mapTable.Push(["off_Hum_MaxHealth", "Humanoid::MaxHealth"])
mapTable.Push(["off_Hum_RootPart", "Humanoid::HumanoidRootPart"])
mapTable.Push(["off_Hum_WalkSpeed", "Humanoid::Walkspeed"])
mapTable.Push(["off_Inst_AttrContainer", "Instance::AttributeContainer"])
mapTable.Push(["off_Inst_AttrList", "Instance::AttributeList"])
mapTable.Push(["off_Attr_Next", "Instance::AttributeToNext"])
mapTable.Push(["off_Attr_Value", "Instance::AttributeToValue"])
mapTable.Push(["off_Hum_MoveDir", "Humanoid::MoveDirection"])
mapTable.Push(["off_WS_Camera", "Workspace::CurrentCamera"])
mapTable.Push(["off_Cam_Subject", "Camera::CameraSubject"])
mapTable.Push(["off_Cam_Type", "Camera::CameraType"])
mapTable.Push(["off_Cam_Rot", "Camera::Rotation"])
mapTable.Push(["off_Cam_Pos", "Camera::Position"])
mapTable.Push(["off_Part_Primitive", "BasePart::Primitive"])
mapTable.Push(["off_Prim_Position", "Primitive::Position"])
mapTable.Push(["off_TextLabel_Text", "GuiObject::Text"])
mapTable.Push(["off_Players_MaxPlayers", "Players::MaxPlayers"])
mapTable.Push(["off_Player_DisplayName", "Player::DisplayName"])

MATRIX_TRANSPOSED := false
TEAM_CHECK := false
MAX_DIST := 1000
HEAD_OFFSET := 2.8
FEET_OFFSET := 3.2
BOX_RATIO := 0.55
espOn := false
camlockOn := false
camlockKey := "XButton2"
camlockHoldKey := "LButton"
camlockSmooth := 0.20
camlockFOV := 150
camlockFovOn := true
camlockFovFill := false
camlockFovAlpha := 25
camlockMaxDist := 1000
camlockTarget := ""
camlockHeadY := 1.5
streamProof := false
TARGET_PART := "HumanoidRootPart"
gameId := 0
profSection := "keys"
profIsCustom := false
off_DCV_Value := 0xB0
off_DCV_Max := 0xA0
; webhook info send: 0 = not found in the offsets dump yet
off_TextLabel_Text := 0
off_Hum_WalkSpeed := 0
off_Hum_MoveDir := 0
off_WS_Camera := 0
off_Cam_Subject := 0xB0
off_Cam_Type := 0x120
off_Cam_Rot := 0xC0
off_Cam_Pos := 0xE4
specOrigType := 5
specYaw := 0
specPitch := 0.3
specDist := 12
specOn := false
specName := ""
specOrig := 0
specCam := 0
specLoopOn := false
specListShown := ""
specMouseSens := 0.003
specLastMouseX := 0
specLastMouseY := 0
specMouseInit := false
wsOn := false
dbgMobs := false
dbgOut := ""
dbgShown := ""
dbgCnt := 0
wsMin := 20
wsMax := 20
wsPrev := 0
wsFreq := 0
wsSpd := 0
wsSpdAt := 0
localHum := 0
localChr := 0
attrNameTried := false
off_Inst_AttrContainer := 0
off_Inst_AttrList := 0
off_Attr_Next := 0
off_Attr_Value := 0
off_Attr_Name := 0
off_Players_MaxPlayers := 0
webhookUrl := ""
maxPlFallback := 0
uploadBusy := false
uploadPid := 0
uploadStart := 0
uploadBody := ""
GameDefs := {}
statNames := {}
statOn := {}
sideBottom := []
sideRight := []
sideLeft := []
; Player ESP settings read from the menu (SyncVisuals keeps these up to date)
vBars := false
vHpBar := false
vHpW := 10
vText := false
vTextBGR := 0xFFFFFF
vTextSize := 14
vBoxBGR := 0x3C3CFF
vBoxAlpha := 100
BOXBAR_DIST := 500
tagUser := false
tagDisp := false
tagHpPct := false
tagHpCur := false
tagDist := false
fontCache := {}
fontNames := ["Segoe UI", "Tahoma", "Verdana", "Consolas", "Arial", "Trebuchet MS"]
fontIdx := 1
fontFace := "Segoe UI"
fontCurSize := 0
mobs := []
mobOn := false
mobHp := false
mobHpW := 10
mobText := false
mobTextBGR := 0xFFFFFF
mobTextSize := 14
mobDistMax := 1000
off_Player_DisplayName := 0
statItems := ["Armor", "Blood", "Sanity", "Stomach", "Tempo", "Water", "Posture"]
tagItems := ["Username", "Display Name", "Health Percentage", "Cur. HP / Max HP", "Distance"]
; per-game stat meters: name = child of the Character, label = UI text, color = BGR
AddStat(1359573625, "Armor", "Armor", 0xA0A0A0)
AddStat(1359573625, "Blood", "Blood", 0x2828DC)
AddStat(1359573625, "Sanity", "Sanity", 0xDC50B4)
AddStat(1359573625, "Stomach", "Stomach", 0x28A0FF)
AddStat(1359573625, "Tempo", "Tempo", 0x50E6FF)
AddStat(1359573625, "Water", "Water", 0xFF963C)
AddStat(1359573625, "BreakMeter", "Posture", 0xFFFFFF)
jsonSettingsFile := appDir "\esp_settings.json"
legacySettingsFile := appDir "\esp_settings.ini"
settingsFile := appDir "\esp_settings_runtime.ini"
LoadJsonConfigToIni()

hwnd := WinExist("ahk_exe RobloxPlayerBeta.exe")
if !hwnd {
    MsgBox Roblox not found.
    ExitApp
}
WinGet, pid, PID, ahk_id %hwnd%
hProc := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "Int", 0, "UInt", pid, "Ptr")
if !hProc {
    MsgBox OpenProcess failed
    ExitApp
}

WinGet, exePath, ProcessPath, ahk_id %hwnd%
SplitPath, exePath, , robloxDir
localHash := ""
if RegExMatch(exePath, "i)(version-[0-9a-f]+)", lm)
    localHash := lm1
offsetsFile := robloxDir "\offsets.json"
OFFSETS_URL := (localHash != "") ? "https://offsets.imtheo.lol/" localHash "/offsets.json" : "https://offsets.imtheo.lol/offsets.json"
fileVer := ""
FileGetVersion, fileVer, %exePath%

flat := ""
remoteVer := ""
offsetNote := "built-in offsets"
if FileExist(offsetsFile) {
    FileRead, cachedRaw, %offsetsFile%
    flat := JsonFlatten(cachedRaw)
    remoteVer := GetDumpVersion(flat)
}
if !(IsObject(flat) && VersionMatches(remoteVer, localHash, fileVer)) {
    fetchErr := ""
    raw := FetchText(OFFSETS_URL, fetchErr)
    if (raw != "") {
        newFlat := JsonFlatten(raw)
        if (CountInts(newFlat) >= 20) {
            flat := newFlat
            remoteVer := GetDumpVersion(flat)
            f := FileOpen(offsetsFile, "w", "UTF-8-RAW")
            f.Write(raw)
            f.Close()
        } else {
            offsetNote := "unexpected response from site, using built-in offsets"
        }
    } else if !IsObject(flat) {
        offsetNote := "fetch failed (" fetchErr "), using built-in offsets"
    }
}
if (IsObject(flat) && !VersionMatches(remoteVer, localHash, fileVer)) {
    askMsg := "The offsets dump is for:`n " (remoteVer != "" ? remoteVer : "(unknown)")
    askMsg .= "`n`nYour Roblox is:`n " (localHash != "" ? localHash : "(not detected)")
    askMsg .= "`n`nThe site may not have caught up with the latest update. Use them anyway?`n(No = built-in offsets)"
    MsgBox, 0x24, esp.ahk, %askMsg%
    IfMsgBox No
        flat := ""
}
if IsObject(flat) {
    updated := 0
    for _, pair in mapTable {
        val := FindOffset(flat, pair[2])
        if (val = "")
            continue
        vn := pair[1]
        %vn% := val
        updated++
    }
    offsetNote := updated "/" mapTable.Length() " offsets from " (remoteVer != "" ? remoteVer : "dump")
    if (off_TextLabel_Text < 0x10) {
        for _, cand in ["GuiObject::Text", "TextButton::Text", "TextBox::Text", "UIText::Text", "TextLabel::ContentText", "GuiLabel::Text"] {
            v2 := FindOffset(flat, cand)
            if (v2 != "") {
                off_TextLabel_Text := v2
                break
            }
        }
    }
}

dllBase := GetModuleBase(hProc, "RobloxPlayerBeta.exe")
pFakeDM := ReadPtr(hProc, dllBase + static_FakeDM)
pRealDM := ReadPtr(hProc, pFakeDM + off_FDM_RealDM)
placeId := ReadInt64(hProc, pRealDM + off_DM_PlaceId)
gameId := ReadInt64(hProc, pRealDM + off_DM_GameId)
if (gameId < 1 || gameId > 9999999999999)
    gameId := 0
if (!dllBase || !pRealDM) {
    MsgBox % "Attach failed (offsets stale?)`nBase: 0x" Format("{:X}", dllBase) "`nDataModel: 0x" Format("{:X}", pRealDM) "`nOffsets: " offsetNote
    DllCall("CloseHandle", "Ptr", hProc)
    ExitApp
}

IniRead, wantUI, %settingsFile%, keys, ui, ]
IniRead, wantT, %settingsFile%, keys, toggle, Insert
IniRead, wantSPon,%settingsFile%, keys, streamon, 0
IniRead, wantWH, %settingsFile%, keys, sendinfo, F8
IniRead, wantCHold, %settingsFile%, keys, camlockhold, LButton
IniRead, wantCamDist, %settingsFile%, keys, camlockdist, 1000
IniRead, wantCamFov, %settingsFile%, keys, camlockfov, 150
IniRead, wantCamFovOn, %settingsFile%, keys, camlockfovon, 1
IniRead, wantCamFovFill, %settingsFile%, keys, camlockfovfill, 0
IniRead, wantCamFovAlpha, %settingsFile%, keys, camlockfovalpha, 25
IniRead, wantCamSmooth, %settingsFile%, keys, camlocksmooth, 20
IniRead, wantCamHeadY, %settingsFile%, keys, camlockheady, 1.5
IniRead, webhookUrl, %settingsFile%, keys, webhook, %A_Space%
IniRead, maxPlFallback, %settingsFile%, keys, maxplayers, 0
webhookUrl := Trim(webhookUrl)
IniRead, msgText, %settingsFile%, keys, message, %A_Space%
IniRead, embedColor, %settingsFile%, keys, embedcolor, 7885FA
IniRead, shotOn, %settingsFile%, keys, screenshot, 0
msgText := Trim(msgText)
embedColor := RegExReplace(Trim(embedColor), "^#")
shotOn := (shotOn = "1") ? 1 : 0
IniRead, manualTextOff, %settingsFile%, keys, textoff, 0
if (off_TextLabel_Text < 0x10 && IsNum(manualTextOff) && manualTextOff + 0 >= 0x10)
    off_TextLabel_Text := manualTextOff + 0
if (off_TextLabel_Text < 0x10)
    off_TextLabel_Text := 0xE38 ; built-in default (GuiObject::Text, dump version-9ac8595712b447a7)
if (off_Inst_AttrContainer < 0x10)
    off_Inst_AttrContainer := 0x48
if (off_Inst_AttrList < 0x10)
    off_Inst_AttrList := 0x18
if (off_Attr_Next < 0x8)
    off_Attr_Next := 0x58
if (off_Attr_Value < 0x8)
    off_Attr_Value := 0x18
IniRead, manualNameOff, %settingsFile%, keys, attrnameoff, 0
off_Attr_Name := (IsNum(manualNameOff) && manualNameOff + 0 >= 0 && manualNameOff + 0 <= 0x100) ? manualNameOff + 0 : 0
IniRead, manualCamOff, %settingsFile%, keys, camoff, 0
if (off_WS_Camera < 0x10 && IsNum(manualCamOff) && manualCamOff + 0 >= 0x10)
    off_WS_Camera := manualCamOff + 0
IniRead, manualMaxOff, %settingsFile%, keys, maxpoff, 0
if (off_Players_MaxPlayers < 0x10 && IsNum(manualMaxOff) && manualMaxOff + 0 >= 0x10)
    off_Players_MaxPlayers := manualMaxOff + 0

streamProof := (wantSPon = "1") ? true : false
IniRead, fontIdx, %settingsFile%, keys, font, 1
fontIdx := (IsInt(fontIdx) && fontIdx >= 1 && fontIdx <= fontNames.Length()) ? fontIdx + 0 : 1
fontFace := fontNames[fontIdx]
LoadProfile()

uiKey := (wantUI = "" || wantUI = "ERROR" || wantUI = "PROMPT") ? "]" : wantUI
wantT := (wantT = "" || wantT = "ERROR") ? "Insert" : wantT
wantWH := (wantWH = "" || wantWH = "ERROR") ? "F8" : wantWH
camlockHoldKey := (wantCHold = "" || wantCHold = "ERROR") ? "LButton" : wantCHold
camlockMaxDist := IsNum(wantCamDist) ? Round(wantCamDist + 0) : 1000
if (camlockMaxDist < 10 || camlockMaxDist > 10000)
    camlockMaxDist := 1000
camlockFOV := IsNum(wantCamFov) ? Round(wantCamFov + 0) : 150
if (camlockFOV < 10 || camlockFOV > 600)
    camlockFOV := 150
camlockFovOn := (wantCamFovOn = "1")
camlockFovFill := (wantCamFovFill = "1")
camlockFovAlpha := IsNum(wantCamFovAlpha) ? Round(wantCamFovAlpha + 0) : 25
if (camlockFovAlpha < 0 || camlockFovAlpha > 100)
    camlockFovAlpha := 25
camlockSmooth := IsNum(wantCamSmooth) ? (wantCamSmooth + 0) / 100 : 0.20
if (camlockSmooth < 0 || camlockSmooth > 1)
    camlockSmooth := 0.20
camlockHeadY := IsNum(wantCamHeadY) ? wantCamHeadY + 0 : 1.5
if (camlockHeadY < 0 || camlockHeadY > 5)
    camlockHeadY := 1.5
; no two actions on the same key (the later one becomes unbound)
usedKeys := {}
usedKeys[uiKey] := true
for _, nm in ["wantT", "wantWH"] {
    k := %nm%
    if (k != "None" && usedKeys.HasKey(k))
        %nm% := "None"
    else
        usedKeys[k] := true
}

players := []
localPrim := 0
localTeam := 0
hdcMem := 0
hbm := 0
hbmOld := 0
brushKey := DllCall("CreateSolidBrush", "UInt", 0x000000, "Ptr")
brushOutline := DllCall("CreateSolidBrush", "UInt", 0x010101, "Ptr")
brushBox := DllCall("CreateSolidBrush", "UInt", 0x3C3CFF, "Ptr")
brushBack := DllCall("CreateSolidBrush", "UInt", 0x303030, "Ptr")
brushGreen := DllCall("CreateSolidBrush", "UInt", 0x00DC50, "Ptr")
brushYellow := DllCall("CreateSolidBrush", "UInt", 0x00D7FF, "Ptr")
brushRed := DllCall("CreateSolidBrush", "UInt", 0x0000CC, "Ptr")
for gid, defs in GameDefs {
    for _, d in defs
        d.brush := DllCall("CreateSolidBrush", "UInt", d.color, "Ptr")
}

ovX := 0
ovY := 0
ovW := 0
ovH := 0
GetClientArea(hwnd, ovX, ovY, ovW, ovH)
if (ovW < 1 || ovH < 1) {
    MsgBox Roblox window has no client area (minimized?).
    ExitApp
}
Gui, ESP:+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound +HwndhGui
Gui, ESP:Color, 000000
Gui, ESP:Show, NA x%ovX% y%ovY% w%ovW% h%ovH%
WinSet, TransColor, 000000, ahk_id %hGui%
ResizeBackbuffer(hGui, ovW, ovH)
dirtyOn := true
dL := 0
dT := 0
dR := ovW
dB := ovH

if streamProof
    SetStreamProof(hGui, true)

espKey := wantT
hookKey := wantWH

; ============================================================
;  Settings menu (Alia ring UI) - library is downloaded to .\lib on first run
; ============================================================
IniRead, _accRaw, %settingsFile%, keys, accent, 16738740
espAccent := IsNum(_accRaw) ? (_accRaw + 0) : 0xFF69B4
if (espAccent < 0 || espAccent > 0xFFFFFF)
    espAccent := 0xFF69B4
fovPen := 0
fovFillBrush := 0
UpdateFovBrushes()

BuildAliaUi()
OnExit, Cleanup
RefreshPlayers()
UpdateUI()
MsgBox, 0, esp.ahk - attached, % "PlaceId: " placeId "`nOffsets: " offsetNote "`nPlayers: " players.Length() "`n`nPress " uiKey " to open the settings menu.", 6
SetTimer, RenderTick, 16
SetTimer, RefreshTick, 2000
DllCall("winmm\timeBeginPeriod", "UInt", 1)
SetTimer, WalkTimer, 8
SetTimer, SpecTimer, 50
SetTimer, CamlockTimer, 8
SetTimer, ConfigSync, 1000
return

PromptOK:
    Gui, Prompt:Submit, NoHide
    chosenUI := hkUI
    Gui, Prompt:Destroy
return

PromptDefault:
    chosenUI := "]"
    Gui, Prompt:Destroy
return

PromptGuiClose:
PromptGuiEscape:
    chosenUI := "]"
    Gui, Prompt:Destroy
return

RenderTick:
    Render()
return

WalkTimer:
    WalkTick()
return

SpecTimer:
    SpecTick()
return

SpecKick:
    SpecTick()
return

CamlockTimer:
    CamlockTick()
return

ConfigSync:
    SaveAllUiConfig()
    SaveIniConfigToJson()
return

SpecListSel:
    Gui, SpecWin:Submit, NoHide
    SpecSelectName(SpecListName(SpecSel))
return

SpecListStop:
    SpecStop("Spectating: off")
    GuiControl, SpecWin:Choose, SpecSel, 0
return

SpecListRefresh:
    SpecListFill()
return

SpecWinGuiClose:
SpecWinGuiEscape:
    SetTimer, SpecListRefresh, Off
    Gui, SpecWin:Destroy
return

RefreshTick:
    CheckGame()
    RefreshPlayers()
    SyncVisuals()
    if mobOn
        RefreshMobs()
    if UiOpen()
        UpdateUI()
return

UploadWatch:
    Process, Exist, %uploadPid%
    if (ErrorLevel && (A_TickCount - uploadStart) < 70000)
        return
    if ErrorLevel
        Process, Close, %uploadPid%
    SetTimer, UploadWatch, Off
    FinishUpload()
return

FlushProfile:
    FlushProfileSave()
return

ActivateGame:
    if !UiOpen()
        WinActivate, ahk_id %hwnd%
return

HideTip:
    ToolTip
return

Cleanup:
    SaveAllUiConfig()
    SaveCamlockConfig()
    SaveIniConfigToJson()
    FileDelete, %settingsFile%
    SetTimer, RenderTick, Off
    SetTimer, RefreshTick, Off
    SetTimer, WalkTimer, Off
    SetTimer, SpecTimer, Off
    SetTimer, CamlockTimer, Off
    SetTimer, ConfigSync, Off
    SpecStop("")
    Gui, SpecWin:Destroy
    DllCall("winmm\timeEndPeriod", "UInt", 1)
    DllCall("DeleteObject", "Ptr", brushKey)
    DllCall("DeleteObject", "Ptr", brushOutline)
    DllCall("DeleteObject", "Ptr", brushBox)
    DllCall("DeleteObject", "Ptr", brushBack)
    DllCall("DeleteObject", "Ptr", brushGreen)
    DllCall("DeleteObject", "Ptr", brushYellow)
    DllCall("DeleteObject", "Ptr", brushRed)
    if fovPen
        DllCall("DeleteObject", "Ptr", fovPen)
    if fovFillBrush
        DllCall("DeleteObject", "Ptr", fovFillBrush)
    for gid, defs in GameDefs {
        for _, d in defs
            DllCall("DeleteObject", "Ptr", d.brush)
    }
    if hdcMem {
        DllCall("SelectObject", "Ptr", hdcMem, "Ptr", DllCall("GetStockObject", "Int", 17, "Ptr"), "Ptr")
        DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbmOld, "Ptr")
        DllCall("DeleteObject", "Ptr", hbm)
        DllCall("DeleteDC", "Ptr", hdcMem)
    }
    for k, f in fontCache
        DllCall("DeleteObject", "Ptr", f)
    DllCall("CloseHandle", "Ptr", hProc)
ExitApp

; mobs: children of Workspace.Live whose name starts with "." and that have a Humanoid

#Include *i %A_ScriptDir%\lib\config.ahk
#Include *i %A_ScriptDir%\lib\functions\RefreshMobs.ahk
#Include *i %A_ScriptDir%\lib\functions\SyncVisuals.ahk
#Include *i %A_ScriptDir%\lib\functions\MultiNames.ahk
#Include *i %A_ScriptDir%\lib\functions\DbgRaw.ahk
#Include *i %A_ScriptDir%\lib\functions\BuildAliaUi.ahk
#Include *i %A_ScriptDir%\lib\functions\UiOpen.ahk
#Include *i %A_ScriptDir%\lib\functions\Defer.ahk
#Include *i %A_ScriptDir%\lib\functions\IsBindFire.ahk
#Include *i %A_ScriptDir%\lib\functions\OnUI.ahk
#Include *i %A_ScriptDir%\lib\functions\HandleBind.ahk
#Include *i %A_ScriptDir%\lib\functions\QueueProfileSave.ahk
#Include *i %A_ScriptDir%\lib\functions\FlushProfileSave.ahk
#Include *i %A_ScriptDir%\lib\functions\SetFont.ahk
#Include *i %A_ScriptDir%\lib\functions\RefetchOffsets.ahk
#Include *i %A_ScriptDir%\lib\functions\UpdateUI.ahk
#Include *i %A_ScriptDir%\lib\functions\PushProfileToUI.ahk
#Include *i %A_ScriptDir%\lib\functions\_HexToInt.ahk
#Include *i %A_ScriptDir%\lib\functions\SetStatus.ahk
#Include *i %A_ScriptDir%\lib\functions\SetStreamProof.ahk
#Include *i %A_ScriptDir%\lib\functions\WalkTick.ahk
#Include *i %A_ScriptDir%\lib\functions\CamlockTick.ahk
#Include *i %A_ScriptDir%\lib\functions\GetCamera.ahk
#Include *i %A_ScriptDir%\lib\functions\WritePtr.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecLabel.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecSelectName.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecStep.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecTick.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecLoop.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadInt32.ahk
#Include *i %A_ScriptDir%\lib\functions\WriteInt32.ahk
#Include *i %A_ScriptDir%\lib\functions\Atan2.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecListName.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecListFill.ahk
#Include *i %A_ScriptDir%\lib\functions\ShowSpecWindow.ahk
#Include *i %A_ScriptDir%\lib\functions\SpecStop.ahk
#Include *i %A_ScriptDir%\lib\functions\AttrNodes.ahk
#Include *i %A_ScriptDir%\lib\functions\AttrFindNameOff.ahk
#Include *i %A_ScriptDir%\lib\functions\HexAt.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadDouble.ahk
#Include *i %A_ScriptDir%\lib\functions\AttrValue.ahk
#Include *i %A_ScriptDir%\lib\functions\GetAttribute.ahk
#Include *i %A_ScriptDir%\lib\functions\GetAttributes.ahk
#Include *i %A_ScriptDir%\lib\functions\AttrBlock.ahk
#Include *i %A_ScriptDir%\lib\functions\ShowAttrDump.ahk
#Include *i %A_ScriptDir%\lib\functions\DbgMob.ahk
#Include *i %A_ScriptDir%\lib\functions\WriteVec3.ahk
#Include *i %A_ScriptDir%\lib\functions\SaveDefaults.ahk
#Include *i %A_ScriptDir%\lib\functions\ResetGame.ahk
#Include *i %A_ScriptDir%\lib\functions\CheckGame.ahk
#Include *i %A_ScriptDir%\lib\functions\IsNum.ahk
#Include *i %A_ScriptDir%\lib\functions\ShowDebug.ahk
#Include *i %A_ScriptDir%\lib\functions\AddStat.ahk
#Include *i %A_ScriptDir%\lib\functions\BuildGameStats.ahk
#Include *i %A_ScriptDir%\lib\functions\StatRatio.ahk
#Include *i %A_ScriptDir%\lib\functions\DrawStatMeters.ahk
#Include *i %A_ScriptDir%\lib\functions\ShowStatDump.ahk
#Include *i %A_ScriptDir%\lib\functions\Render.ahk
#Include *i %A_ScriptDir%\lib\functions\WorldToScreen.ahk
#Include *i %A_ScriptDir%\lib\functions\ResizeBackbuffer.ahk
#Include *i %A_ScriptDir%\lib\functions\GetClientArea.ahk
#Include *i %A_ScriptDir%\lib\functions\GdiFill.ahk
#Include *i %A_ScriptDir%\lib\functions\GdiFrame.ahk
#Include *i %A_ScriptDir%\lib\functions\UpdateFovBrushes.ahk
#Include *i %A_ScriptDir%\lib\functions\DrawFovCircle.ahk
#Include *i %A_ScriptDir%\lib\functions\DrawLabel.ahk
#Include *i %A_ScriptDir%\lib\functions\TextW.ahk
#Include *i %A_ScriptDir%\lib\functions\UseFont.ahk
#Include *i %A_ScriptDir%\lib\functions\AddPart.ahk
#Include *i %A_ScriptDir%\lib\functions\RgbToBgr.ahk
#Include *i %A_ScriptDir%\lib\functions\RefreshPlayers.ahk
#Include *i %A_ScriptDir%\lib\functions\GetChildren.ahk
#Include *i %A_ScriptDir%\lib\functions\FindChildByClass.ahk
#Include *i %A_ScriptDir%\lib\functions\Tip.ahk
#Include *i %A_ScriptDir%\lib\functions\SendInfo.ahk
#Include *i %A_ScriptDir%\lib\functions\FindMaxPlayersOffset.ahk
#Include *i %A_ScriptDir%\lib\functions\AutoFindMaxPlayers.ahk
#Include *i %A_ScriptDir%\lib\functions\TakeGameShot.ahk
#Include *i %A_ScriptDir%\lib\functions\CleanShotCache.ahk
#Include *i %A_ScriptDir%\lib\functions\CaptureToPng.ahk
#Include *i %A_ScriptDir%\lib\functions\StartAsyncUpload.ahk
#Include *i %A_ScriptDir%\lib\functions\FinishUpload.ahk
#Include *i %A_ScriptDir%\lib\functions\PostWebhookFile.ahk
#Include *i %A_ScriptDir%\lib\functions\EmbedField.ahk
#Include *i %A_ScriptDir%\lib\functions\JsonEsc.ahk
#Include *i %A_ScriptDir%\lib\functions\FindChildByName.ahk
#Include *i %A_ScriptDir%\lib\functions\WalkPath.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadStdStringU.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadTextProp.ahk
#Include *i %A_ScriptDir%\lib\functions\ToUtf8Array.ahk
#Include *i %A_ScriptDir%\lib\functions\PostWebhook.ahk
#Include *i %A_ScriptDir%\lib\functions\FetchText.ahk
#Include *i %A_ScriptDir%\lib\functions\IsInt.ahk
#Include *i %A_ScriptDir%\lib\functions\CountInts.ahk
#Include *i %A_ScriptDir%\lib\functions\GetDumpVersion.ahk
#Include *i %A_ScriptDir%\lib\functions\VersionNorm.ahk
#Include *i %A_ScriptDir%\lib\functions\VersionMatches.ahk
#Include *i %A_ScriptDir%\lib\functions\FindOffset.ahk
#Include *i %A_ScriptDir%\lib\functions\JsonFlatten.ahk
#Include *i %A_ScriptDir%\lib\functions\JsonSkip.ahk
#Include *i %A_ScriptDir%\lib\functions\JsonString.ahk
#Include *i %A_ScriptDir%\lib\functions\JsonValue.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadPtr.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadUInt32.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadInt64.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadFloat.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadVec3.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadCStr.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadPrintable.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadStdString.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadNameAt.ahk
#Include *i %A_ScriptDir%\lib\functions\IsClassName.ahk
#Include *i %A_ScriptDir%\lib\functions\ReadClassName.ahk
#Include *i %A_ScriptDir%\lib\functions\GetModuleBase.ahk
#Include *i %A_ScriptDir%\lib\aliaUI.ahk
