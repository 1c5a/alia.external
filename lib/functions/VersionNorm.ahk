VersionNorm(s) {
    s := StrReplace(s, ", ", ".")
    return RegExReplace(s, "[^0-9.]")
}

