#NoEnv
#SingleInstance Force
SetBatchLines, -1
DllCall("SetProcessDPIAware")

repoRaw := "https://raw.githubusercontent.com/1c5a/alia.external/main/"
cacheBust := A_Now . A_TickCount . A_MSec
commitRaw := ""
if LoaderGetMainCommit(commitRaw)
    repoRaw := "https://raw.githubusercontent.com/1c5a/alia.external/" . commitRaw . "/"
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
forceUi := InStr(DllCall("GetCommandLine", "Str"), "--alia-ui") > 0
showUi := isInstalled || forceUi
loaderReady := false

if (showUi) {
    accent := LoaderAccent(configFile)
    loaderUi := new AliaUI({TAB_W: 620, TAB_H: 300, Accent: accent, ToggleKey: "None", StartVisible: true, TabOnly: true})
    loaderUi.Tab(1, "alia updater", "download")
    loaderUi.Add(1, {type: "header", label: "alia"})
    loaderUi.Add(1, {type: "label", key: "loaderstatus", label: "Checking for updates..."})
    loaderUi.Add(1, {type: "label", key: "loaderversion", label: ""})
    loaderUi.Add(1, {type: "progress", key: "loaderprogress", label: "Download progress", value: 0})
    loaderUi.Add(1, {type: "button", key: "loaderlaunch", label: "Launch"})
    loaderUi.Add(1, {type: "button", key: "loaderclose", label: "Close"})
    loaderUi.OnEvent(Func("LoaderEvent"))
    loaderUi.Start()
    OpenTab(1)
}

FileCreateDir, %installDir%
if !LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
    LoaderStatus("Update failed. Check your connection.")
    return
}
if (!isInstalled && !forceUi) {
    if (LoaderSelfUpdate(repoRaw)) {
        q := Chr(34)
        runCmd := q . A_AhkPath . q . " " . q . installDir . "\loader.ahk" . q . " --alia-ui"
        Run, %runCmd%, , UseErrorLevel
        ExitApp
    }
}
if (showUi) {
    LoaderStatus("Ready to launch")
    loaderReady := true
}
return

LoaderEvent(key, value, extra) {
    global mainFile, loaderReady
    if (key = "loaderclose")
        ExitApp
    if (key = "loaderlaunch" && loaderReady) {
        q := Chr(34)
        runCmd := q . A_AhkPath . q . " " . q . mainFile . q
        Run, %runCmd%, , UseErrorLevel
        if !ErrorLevel
            ExitApp
        LoaderStatus("Could not start main.ahk")
    }
}

LoaderStatus(text) {
    global showUi, loaderUi
    if (!showUi)
        return
    el := loaderUi.Find("loaderstatus")
    if IsObject(el) {
        el.label := text
        loaderUi.Redraw()
    }
}

LoaderProgress(value) {
    global showUi, loaderUi
    if (!showUi)
        return
    loaderUi.Set("loaderprogress", Max(0, Min(100, Round(value))))
    loaderUi.Redraw()
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
    if (showUi) {
        versionEl := loaderUi.Find("loaderversion")
        if IsObject(versionEl)
            versionEl.label := versionLine
        loaderUi.Redraw()
    }
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

LoaderGetMainCommit(ByRef sha) {
    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    if !IsObject(http)
        return false
    try {
        http.Open("GET", "https://api.github.com/repos/1c5a/alia.external/commits/main?cb=" . A_Now . A_TickCount . A_MSec, false)
        http.SetRequestHeader("Cache-Control", "no-cache, no-store, max-age=0")
        http.SetRequestHeader("Pragma", "no-cache")
        http.SetRequestHeader("User-Agent", "alia-updater/3")
        http.Send()
        if (http.Status != 200)
            return false
        raw := http.ResponseText
    } catch e {
        return false
    }
    if RegExMatch(raw, """sha""\s*:\s*""([0-9a-fA-F]{40})""", m) {
        sha := m1
        return true
    }
    return false
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

#Include *i %A_ScriptDir%\lib\aliaUI.ahk
