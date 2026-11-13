FindOffset(flat, key) {
    for _, cand in [key, "Offsets::" key] {
        if (flat.HasKey(cand) && IsInt(flat[cand]))
            return flat[cand] + 0
    }
    n := StrLen(key)
    for k, v in flat {
        if (StrLen(k) > n + 2 && SubStr(k, -n) = key && SubStr(k, -(n + 2), 2) = "::" && IsInt(v))
            return v + 0
    }
    return ""
}

