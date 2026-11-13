WalkPath(hProc, start, path) {
    node := start
    for _, part in StrSplit(path, ".") {
        node := FindChildByName(hProc, node, part)
        if !node
            return 0
    }
    return node
}

; std::string with UTF-8 allowed (UI text can contain non-ASCII); same MSVC layout as ReadStdString
