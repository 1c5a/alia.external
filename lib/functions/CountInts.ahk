CountInts(flat) {
    n := 0
    for k, v in flat {
        if IsInt(v)
            n++
    }
    return n
}

