VersionMatches(remote, localHash, fileVer) {
    if (remote = "")
        return false
    if (localHash != "" && InStr(remote, localHash))
        return true
    if (fileVer != "" && VersionNorm(remote) = VersionNorm(fileVer))
        return true
    return false
}

