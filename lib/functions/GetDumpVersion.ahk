GetDumpVersion(flat) {
    if flat.HasKey("Roblox Version")
        return flat["Roblox Version"]
    for k, v in flat {
        if (InStr(k, "version") && !IsInt(v))
            return v
    }
    return ""
}

