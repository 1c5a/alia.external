DbgRaw(v) {
    if !IsObject(v)
        return v
    out := "{"
    for k, x in v
        out .= k "=" (IsObject(x) ? "<obj>" : x) ";"
    return out "}"
}

; ============================================================
;  Alia settings menu
; ============================================================
