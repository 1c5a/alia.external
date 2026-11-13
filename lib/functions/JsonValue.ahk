JsonValue(text, ByRef pos, path, out) {
    JsonSkip(text, pos)
    c := SubStr(text, pos, 1)
    if (c = "{") {
        pos++
        JsonSkip(text, pos)
        if (SubStr(text, pos, 1) = "}") {
            pos++
            return
        }
        Loop {
            JsonSkip(text, pos)
            if (SubStr(text, pos, 1) != """")
                break
            key := JsonString(text, pos)
            JsonSkip(text, pos)
            pos++
            JsonValue(text, pos, (path = "") ? key : path "::" key, out)
            JsonSkip(text, pos)
            d := SubStr(text, pos, 1)
            pos++
            if (d != ",")
                break
        }
    } else if (c = "[") {
        pos++
        JsonSkip(text, pos)
        if (SubStr(text, pos, 1) = "]") {
            pos++
            return
        }
        idx := 0
        Loop {
            if (pos > StrLen(text))
                break
            JsonValue(text, pos, path "[" idx "]", out)
            idx++
            JsonSkip(text, pos)
            d := SubStr(text, pos, 1)
            pos++
            if (d != ",")
                break
        }
    } else if (c = """") {
        out[path] := JsonString(text, pos)
    } else {
        if (RegExMatch(text, "(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?|true|false|null)", m, pos) = pos) {
            out[path] := m1
            pos += StrLen(m1)
        } else {
            pos++
        }
    }
}

