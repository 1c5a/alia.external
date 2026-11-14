#NoEnv
#SingleInstance Force
SetBatchLines, -1
DllCall("SetProcessDPIAware")

repoRaw := "https://raw.githubusercontent.com/1c5a/alia.external/main/"
cacheBust := A_Now . A_TickCount . A_MSec
EnvGet, localAppData, LocalAppData
if (localAppData = "") {
    MsgBox, 16, alia updater, Could not locate the LocalAppData folder.
    ExitApp
}
installDir := localAppData "\espahk"
manifestUrl := repoRaw "manifest.json?cb=" cacheBust
manifestTmp := A_Temp "\alia_manifest.json"
versionFile := installDir "\version.txt"
mainFile := installDir "\main.ahk"
configFile := installDir "\esp_settings.json"
isInstalled := false
IfEqual, A_ScriptDir, %installDir%
    isInstalled := true
loaderReady := false

accent := LoaderAccent(configFile)
accentHex := Format("{:06X}", accent & 0xFFFFFF)
Gui, Loader:New, +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox -Caption +Border, alia updater
Gui, Loader:Color, 11111A
Gui, Loader:Font, s11 c%accentHex%, Segoe UI
Gui, Loader:Add, Text, x28 y18 w390 h30, alia
Gui, Loader:Font, s10 c%accentHex%, Segoe UI
Gui, Loader:Add, Text, x474 y18 w18 h28 gLoaderExit Center, x
Gui, Loader:Add, Text, x28 y49 w460 h2 Background%accentHex%
Gui, Loader:Font, s9 cD8D8E2, Segoe UI
Gui, Loader:Add, Text, vLoaderStatus x28 y68 w460 h24, Checking for updates...
Gui, Loader:Add, Text, x28 y104 w460 h10 Background292936
Gui, Loader:Add, Text, vLoaderFill x28 y104 w1 h10 Background%accentHex%
Gui, Loader:Add, Text, vLoaderVersion x28 y124 w460 h20 c90909C,
Gui, Loader:Font, s9 cFFFFFF, Segoe UI
Gui, Loader:Add, Text, vLoaderLaunch x28 y164 w220 h34 Background242431 gLoaderLaunch Center, Launch
Gui, Loader:Add, Text, vLoaderClose x268 y164 w220 h34 Background242431 gLoaderExit Center, Close
Gui, Loader:Show, w516 h220, alia updater

FileCreateDir, %installDir%
if !LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
    LoaderStatus("Update failed. Check your connection.")
    return
}
if (!isInstalled)
    LoaderSelfUpdate(repoRaw)
LoaderStatus("Ready to launch")
loaderReady := true
GuiControl, Loader:, LoaderLaunch, Launch
return

LoaderLaunch:
    if (!loaderReady)
        return
    q := Chr(34)
    runCmd := q . A_AhkPath . q . " " . q . mainFile . q
    Run, %runCmd%, , UseErrorLevel
    if !ErrorLevel
        ExitApp
    LoaderStatus("Could not start main.ahk")
return

LoaderExit:
GuiClose:
GuiEscape:
    ExitApp
return

LoaderStatus(text) {
    GuiControl, Loader:, LoaderStatus, %text%
}

LoaderProgress(value) {
    value := Max(0, Min(100, Round(value)))
    width := Max(1, Round(460 * value / 100))
    move := "w" . width
    GuiControl, Loader:Move, LoaderFill, %move%
}

LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
    FileDelete, %manifestTmp%
    if !LoaderFetchManifest(manifestUrl, manifestTmp)
        return false
    FileRead, manifest, %manifestTmp%
    if !RegExMatch(manifest, """version""\s*:\s*""([^""\\]+)""", mv)
        return false
    if !RegExMatch(manifest, """files""\s*:\s*\[(.*?)\]", mf)
        return false
    remoteVersion := mv1
    localVersion := ""
    if FileExist(versionFile)
        FileRead, localVersion, %versionFile%
    localVersion := Trim(localVersion)
    installedLabel := (localVersion != "") ? localVersion : "none"
    versionLine := "Manifest v" . remoteVersion . "  |  Installed v" . installedLabel
    GuiControl, Loader:, LoaderVersion, %versionLine%
    if (remoteVersion = localVersion && FileExist(mainFile))
        return true

    fileCount := 0
    pos := 1
    while (pos := RegExMatch(mf1, """([^""\\]+)""", f, pos)) {
        fileCount++
        pos += StrLen(f)
    }
    pos := 1
    downloaded := 0
    while (pos := RegExMatch(mf1, """([^""\\]+)""", f, pos)) {
        rel := f1
        pos += StrLen(f)
        dst := installDir "\" StrReplace(rel, "/", "\")
        SplitPath, dst, , dstDir
        FileCreateDir, %dstDir%
        tmp := dst ".tmp"
        LoaderStatus("Downloading " . rel)
        fileUrl := repoRaw . rel . "?cb=" . A_Now . A_TickCount . A_MSec
        if !LoaderFetchFile(fileUrl, tmp) {
            FileDelete, %tmp%
            return false
        }
        FileMove, %tmp%, %dst%, 1
        if ErrorLevel
            return false
        downloaded++
        LoaderProgress(fileCount ? Round(downloaded * 100 / fileCount) : 100)
        Sleep, 10
    }
    FileDelete, %versionFile%
    FileAppend, %remoteVersion%, %versionFile%, UTF-8
    return !ErrorLevel
}

LoaderSelfUpdate(repoRaw) {
    source := repoRaw . "loader.ahk?cb=" . A_Now . A_TickCount . A_MSec
    tmp := A_ScriptFullPath . ".selfupdate.tmp"
    FileDelete, %tmp%
    if !LoaderFetchFile(source, tmp)
        return false
    FileMove, %tmp%, %A_ScriptFullPath%, 1
    return !ErrorLevel
}

LoaderFetchFile(url, dst) {
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    if !IsObject(http)
        return false
    try {
        http.Open("GET", url, false)
        http.SetRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
        http.SetRequestHeader("Pragma", "no-cache")
        http.SetRequestHeader("User-Agent", "alia-updater/2")
        http.Send()
        if (http.Status != 200)
            return false
        stream := ComObjCreate("ADODB.Stream")
        stream.Type := 1
        stream.Open()
        stream.Write(http.ResponseBody)
        stream.SaveToFile(dst, 2)
        stream.Close()
    } catch e {
        return false
    }
    return FileExist(dst) ? true : false
}

LoaderFetchManifest(url, dst) {
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    if !IsObject(http)
        return false
    try {
        http.Open("GET", url, false)
        http.SetRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
        http.SetRequestHeader("Pragma", "no-cache")
        http.SetRequestHeader("User-Agent", "alia-updater/1")
        http.Send()
        if (http.Status != 200)
            return false
        raw := http.ResponseText
    } catch e {
        return false
    }
    if (raw = "")
        return false
    FileDelete, %dst%
    FileAppend, %raw%, %dst%, UTF-8
    return !ErrorLevel
}

LoaderAccent(file) {
    if FileExist(file) {
        FileRead, raw, %file%
        if RegExMatch(raw, """el_uiaccent""\s*:\s*""?([0-9]+)""?", m)
            return m1 + 0
        if RegExMatch(raw, """accent""\s*:\s*""?([0-9]+)""?", m)
            return m1 + 0
    }
    return 0xFF69B4
}
