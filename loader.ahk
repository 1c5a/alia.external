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
accent := LoaderAccent(configFile)
accentHex := Format("{:06X}", accent & 0xFFFFFF)

Gui, Loader:New, +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox, esp.ahk updater
Gui, Loader:Color, 15151F
Gui, Loader:Font, s11 c%accentHex%, Segoe UI
Gui, Loader:Add, Text, x24 y18 w390 h28, esp.ahk
Gui, Loader:Font, s9 cD8D8E2, Segoe UI
Gui, Loader:Add, Text, vLoaderStatus x24 y54 w390 h24, Checking for updates...
Gui, Loader:Add, Progress, vLoaderProgress x24 y88 w390 h14 c%accentHex% Background30303A, 0
Gui, Loader:Add, Button, vLoaderLaunch gLoaderLaunch x24 y126 w185 h32 Disabled, Launch
Gui, Loader:Add, Button, gLoaderExit x229 y126 w185 h32, Exit
Gui, Loader:Show, w438 h178, esp.ahk updater

FileCreateDir, %installDir%
UrlDownloadToFile, %manifestUrl%, %manifestTmp%
if ErrorLevel {
    LoaderStatus("Could not download the update manifest.")
    GuiControl, Loader:Disable, LoaderLaunch
    return
}

FileRead, manifest, %manifestTmp%
if !RegExMatch(manifest, """version""\s*:\s*""([^""\\]+)""", mv)
    fatal := "The update manifest has no version."
else if !RegExMatch(manifest, """files""\s*:\s*\[(.*?)\]", mf)
    fatal := "The update manifest has no file list."
else
    fatal := ""
if (fatal != "") {
    LoaderStatus(fatal)
    GuiControl, Loader:Disable, LoaderLaunch
    return
}

remoteVersion := mv1
localVersion := ""
if FileExist(versionFile)
    FileRead, localVersion, %versionFile%
localVersion := Trim(localVersion)
needsUpdate := (remoteVersion != localVersion || !FileExist(mainFile))

if needsUpdate {
    fileCount := 0
    pos := 1
    while (pos := RegExMatch(mf1, """([^""\\]+)""", f, pos)) {
        fileCount++
        pos += StrLen(f)
    }
    pos := 1
    downloaded := 0
    failed := ""
    while (pos := RegExMatch(mf1, """([^""\\]+)""", f, pos)) {
        rel := f1
        pos += StrLen(f)
        dst := installDir "\" StrReplace(rel, "/", "\")
        SplitPath, dst, , dstDir
        FileCreateDir, %dstDir%
        tmp := dst ".tmp"
        LoaderStatus("Downloading " rel)
        UrlDownloadToFile, % repoRaw rel, %tmp%
        if ErrorLevel {
            failed := rel
            break
        }
        FileMove, %tmp%, %dst%, 1
        downloaded++
        pct := (fileCount > 0) ? Round(downloaded * 100 / fileCount) : 100
        GuiControl, Loader:, LoaderProgress, %pct%
        Sleep, 10
    }
    if (failed != "") {
        LoaderStatus("Update failed: " failed)
        if !FileExist(mainFile)
            GuiControl, Loader:Disable, LoaderLaunch
        return
    }
    FileDelete, %versionFile%
    FileAppend, %remoteVersion%, %versionFile%, UTF-8
} else {
    GuiControl, Loader:, LoaderProgress, 100
    LoaderStatus("Already up to date — " remoteVersion)
}

GuiControl, Loader:Enable, LoaderLaunch
return

LoaderLaunch:
    Run, % """" A_AhkPath """ """ mainFile """", , UseErrorLevel
    if ErrorLevel {
        LoaderStatus("Could not start main.ahk.")
        return
    }
    ExitApp
return

LoaderExit:
LoaderGuiClose:
    ExitApp
return

LoaderStatus(text) {
    GuiControl, Loader:, LoaderStatus, %text%
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
