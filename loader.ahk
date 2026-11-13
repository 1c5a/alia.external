#NoEnv
#SingleInstance Force
SetBatchLines, -1

repoRaw := "https://raw.githubusercontent.com/1c5a/alia.external/main/"
installDir := A_LocalAppData "\espahk"
manifestUrl := repoRaw "manifest.json"
manifestTmp := A_Temp "\espahk_manifest.json"
versionFile := installDir "\version.txt"
mainFile := installDir "\main.ahk"
configFile := installDir "\esp_settings.json"
bootstrap := !FileExist(A_ScriptDir "\lib\aliaUI.ahk")

if bootstrap {
    FileCreateDir, %installDir%
    if !LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
        MsgBox, 16, esp.ahk updater, The updater could not install the latest files.
        ExitApp
    }
    Run, % """" A_AhkPath """ """ installDir "\loader.ahk"""", , UseErrorLevel
    ExitApp
}

accent := LoaderAccent(configFile)
loaderUi := new AliaUI({TAB_W: 620, TAB_H: 300, Accent: accent, ToggleKey: "None"})
loaderUi.Tab(1, "Updater", "download")
loaderUi.Add(1, {type: "header", label: "esp.ahk updater"})
loaderUi.Add(1, {type: "label", key: "loaderstatus", label: "Checking for updates..."})
loaderUi.Add(1, {type: "slider", key: "loaderprogress", label: "Download progress", lo: 0, hi: 100, step: 1, value: 0, suffix: "%"})
loaderUi.Add(1, {type: "button", key: "loaderlaunch", label: "Launch"})
loaderUi.OnEvent(Func("LoaderEvent"))
loaderUi.Start()
OpenTab(1)

FileCreateDir, %installDir%
if !LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
    LoaderStatus("Update failed. Check your connection.")
    return
}
LoaderStatus("Ready to launch")
LoaderProgress(100)
return

LoaderEvent(key, value, extra) {
    global mainFile
    if (key = "loaderlaunch") {
        Run, % """" A_AhkPath """ """ mainFile """", , UseErrorLevel
        if !ErrorLevel
            ExitApp
        LoaderStatus("Could not start main.ahk")
    }
}

LoaderStatus(text) {
    global loaderUi
    if !IsObject(loaderUi)
        return
    el := loaderUi.Find("loaderstatus")
    if IsObject(el) {
        el.label := text
        loaderUi.Redraw()
    }
}

LoaderProgress(value) {
    global loaderUi
    if !IsObject(loaderUi)
        return
    loaderUi.Set("loaderprogress", value)
    loaderUi.Redraw()
}

LoaderDownload(manifestUrl, manifestTmp, installDir, versionFile, mainFile, repoRaw) {
    global loaderUi
    UrlDownloadToFile, %manifestUrl%, %manifestTmp%
    if ErrorLevel
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
        if (dst = A_ScriptFullPath)
            continue
        SplitPath, dst, , dstDir
        FileCreateDir, %dstDir%
        tmp := dst ".tmp"
        LoaderStatus("Downloading " rel)
        UrlDownloadToFile, % repoRaw rel, %tmp%
        if ErrorLevel
            return false
        FileMove, %tmp%, %dst%, 1
        downloaded++
        LoaderProgress(fileCount ? Round(downloaded * 100 / fileCount) : 100)
        Sleep, 10
    }
    FileDelete, %versionFile%
    FileAppend, %remoteVersion%, %versionFile%, UTF-8
    return true
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
