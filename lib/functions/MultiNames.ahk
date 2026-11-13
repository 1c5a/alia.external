MultiNames(raw, items) {
    sel := {}
    if !IsObject(items)
        return sel
    n := items.MaxIndex()
    if IsObject(raw) {
        allBool := true
        cnt := 0
        for k, v in raw {
            cnt++
            if (IsObject(v) || !(v = 0 || v = 1))
                allBool := false
        }
        if (allBool && cnt = n) {
            for k, v in raw {
                if (v && IsInt(k) && k >= 1 && k <= n)
                    sel[items[k + 0]] := true
            }
            return sel
        }
        for k, v in raw {
            if IsObject(v)
                continue
            hit := ""
            Loop, % n {
                nm := items[A_Index]
                if ((k = nm && v && v != "0") || v = nm) {
                    hit := nm
                    break
                }
            }
            if (hit = "" && IsInt(v) && v >= 1 && v <= n)
                hit := items[v + 0]
            if (hit != "")
                sel[hit] := true
        }
        return sel
    }
    s := Trim(raw)
    if (s = "" || s = "None")
        return sel
    found := false
    Loop, % n {
        nm := items[A_Index]
        if InStr(s, nm) {
            sel[nm] := true
            found := true
        }
    }
    if found
        return sel
    if RegExMatch(s, "^\d+(\s*[,|;]\s*\d+)+$") {
        Loop, Parse, s, `,|;, %A_Space%
        {
            if (IsInt(A_LoopField) && A_LoopField >= 1 && A_LoopField <= n)
                sel[items[A_LoopField + 0]] := true
        }
        return sel
    }
    if IsInt(s) {
        m := s + 0
        Loop, % n {
            if ((m >> (A_Index - 1)) & 1)
                sel[items[A_Index]] := true
        }
    }
    return sel
}

; shows a menu value (maybe an object) as text, for the debug window
