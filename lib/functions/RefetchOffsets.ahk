RefetchOffsets() {
    global cacheFile
    FileDelete, %cacheFile%
    Reload
}

