CleanShotCache() {
    global appDir
    cacheDir := appDir "\cache"
    FileDelete, %cacheDir%\*.*
    FileRemoveDir, %cacheDir%, 1
}

