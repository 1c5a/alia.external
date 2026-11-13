ShowStatDump() {
    global hProc, players
    Gui, UI:+OwnDialogs
    out := "Plausible doubles (non-zero) per stat object.`nCompare with the in-game numbers, then type the Value and Max offsets into the two boxes.`n(Dump while stats are non-zero.)`n`n"
    shown := 0
    for _, pl in players {
        for nm, ptr in pl.stats {
            out .= "== " pl.name " / " nm " @ 0x" Format("{:X}", ptr) "`n"
            VarSetCapacity(buf, 0x180, 0)
            DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", ptr + 0x80, "Ptr", &buf, "UPtr", 0x180, "UPtr", 0, "Int")
            Loop 48 {
                o := (A_Index - 1) * 8
                d := NumGet(buf, o, "Double")
                if (IsNum(d) && Abs(d) >= 0.0001 && Abs(d) < 1000000)
                    out .= " +0x" Format("{:X}", 0x80 + o) " = " d "`n"
            }
            shown++
            if (shown >= 4)
                break 2
        }
    }
    if (shown = 0)
        out .= "No stat objects found on any cached player yet."
    MsgBox % out
}

