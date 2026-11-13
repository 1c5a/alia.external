#NoEnv
#SingleInstance Force
SetBatchLines, -1

; This loader can run from any folder. It downloads the current manifest and
; installs the complete macro under %LocalAppData%\espahk.
repoRaw := "https://raw.githubusercontent.com/1c5a/alia.external/main/"
installDir := A_LocalAppData "\espahk"
manifestUrl := repoRaw "manifest.json"
manifestTmp := A_Temp "\espahk_manifest.json"
versionFile := installDir "\version.txt"
mainFile := installDir "\main.ahk"

FileCreateDir, %installDir%
UrlDownloadToFile, %manifestUrl%, %manifestTmp%
if ErrorLevel {
    MsgBox, 16, esp.ahk updater, Could not download the update manifest.
    ExitApp
}

FileRead, manifest, %manifestTmp%
if !RegExMatch(manifest, """version""\s*:\s*""([^""\\]+)""", mv)
    fatal := "The update manifest has no version."
else if !RegExMatch(manifest, """files""\s*:\s*\[(.*?)\]", mf)
    fatal := "The update manifest has no file list."
else
    fatal := ""
if (fatal != "") {
    MsgBox, 16, esp.ahk updater, %fatal%
    ExitApp
}

remoteVersion := mv1
localVersion := ""
if FileExist(versionFile)
    FileRead, localVersion, %versionFile%
localVersion := Trim(localVersion)

if (remoteVersion != localVersion || !FileExist(mainFile)) {
    pos := 1
    failed := ""
    while (pos := RegExMatch(mf1, """([^""\\]+)""", f, pos)) {
        rel := f1
        pos += StrLen(f)
        dst := installDir "\" StrReplace(rel, "/", "\")
        SplitPath, dst, , dstDir
        FileCreateDir, %dstDir%
        tmp := dst ".tmp"
        UrlDownloadToFile, % repoRaw rel, %tmp%
        if ErrorLevel {
            failed := rel
            break
        }
        FileMove, %tmp%, %dst%, 1
    }
    if (failed != "") {
        MsgBox, 16, esp.ahk updater, Update failed while downloading:`n%failed%
        ExitApp
    }
    FileDelete, %versionFile%
    FileAppend, %remoteVersion%, %versionFile%, UTF-8
}

Run, % """" A_AhkPath """ """ mainFile """", , UseErrorLevel
if ErrorLevel {
    MsgBox, 16, esp.ahk updater, Could not start main.ahk.
    ExitApp
}
ExitApp
