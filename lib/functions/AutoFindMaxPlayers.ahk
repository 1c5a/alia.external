AutoFindMaxPlayers(hProc, pSvc, cur) {
    size := 0x800
    VarSetCapacity(buf, size, 0)
    nChunks := size // 0x100
    Loop %nChunks% {
        c := (A_Index - 1) * 0x100
        DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pSvc + c, "Ptr", &buf + c, "UPtr", 0x100, "UPtr", 0, "Int")
    }
    lo := (cur > 2) ? cur : 2
    o := 0x80
    while (o <= size - 8) {
        a := NumGet(buf, o, "UInt")
        b := NumGet(buf, o + 4, "UInt")
        if (a = b && a >= lo && a <= 300)
            return o
        o += 4
    }
    return 0
}

; screenshot of the Roblox client area only. The ESP overlay is hidden from capture by switching
; stream-proof on for the moment of the shot (and back off afterwards if it was off).
; The PNG lives in a cache folder that CleanShotCache() wipes after the webhook call.
