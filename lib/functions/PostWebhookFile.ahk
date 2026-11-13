PostWebhookFile(url, json, file, ByRef err) {
    try {
        bnd := "----espahk" A_TickCount
        head := "--" bnd "`r`nContent-Disposition: form-data; name=""payload_json""`r`nContent-Type: application/json`r`n`r`n" json "`r`n--" bnd "`r`nContent-Disposition: form-data; name=""files[0]""; filename=""shot.jpg""`r`nContent-Type: image/jpeg`r`n`r`n"
        tail := "`r`n--" bnd "--`r`n"
        hl := StrPut(head, "UTF-8") - 1
        tl := StrPut(tail, "UTF-8") - 1
        VarSetCapacity(hb, hl + 1, 0)
        StrPut(head, &hb, "UTF-8")
        VarSetCapacity(tb, tl + 1, 0)
        StrPut(tail, &tb, "UTF-8")
        fo := FileOpen(file, "r")
        fl := fo.Length
        VarSetCapacity(fb, fl, 0)
        fo.RawRead(fb, fl)
        fo.Close()
        total := hl + fl + tl
        arr := ComObjArray(0x11, total)
        pv := NumGet(ComObjValue(arr) + 8 + A_PtrSize, 0, "Ptr")
        DllCall("RtlMoveMemory", "Ptr", pv, "Ptr", &hb, "UPtr", hl)
        DllCall("RtlMoveMemory", "Ptr", pv + hl, "Ptr", &fb, "UPtr", fl)
        DllCall("RtlMoveMemory", "Ptr", pv + hl + fl, "Ptr", &tb, "UPtr", tl)
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "multipart/form-data; boundary=" bnd)
        http.SetTimeouts(5000, 5000, 15000, 30000)
        http.Send(arr)
        if (http.Status < 200 || http.Status >= 300) {
            err := "HTTP " http.Status " (with screenshot) " SubStr(http.ResponseText, 1, 200)
            return false
        }
        return true
    } catch e {
        err := e.Message
        return false
    }
}

