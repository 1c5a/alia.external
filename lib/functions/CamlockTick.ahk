CamlockTick() {
    global hProc, dllBase, static_VisualEngine, off_VE_ViewMatrix
    global off_Prim_Position, off_Hum_Health
    global players, localPrim, localTeam, TEAM_CHECK
    global ovX, ovY, ovW, ovH, hwnd
    global camlockOn, camlockSmooth, camlockFOV, camlockHeadY, camlockHoldKey, camlockMaxDist, camlockFovOn, camlockTargetPart
    global camlockTarget, ui, camlockHoldLatched, camlockHoldPrev

    ; Camlock is active only when the toggle is enabled AND the configured
    ; hold key is physically down while Roblox is the foreground window.
    physicalHold := (camlockHoldKey != "" && camlockHoldKey != "None" && GetKeyState(camlockHoldKey, "P"))
    holdEl := ui.Find("camlockhold")
    if (camlockHoldKey = "" || camlockHoldKey = "None") {
        camlockHoldLatched := false
        camlockHoldPrev := false
    } else if (IsObject(holdEl) && holdEl.mode = "toggle") {
        if (physicalHold && !camlockHoldPrev)
            camlockHoldLatched := !camlockHoldLatched
        holdDown := camlockHoldLatched
    } else {
        camlockHoldLatched := false
        holdDown := physicalHold
    }
    camlockHoldPrev := physicalHold
    if (!camlockOn || !holdDown || !WinActive("ahk_id " hwnd)) {
        if (camlockTarget != "") {
            camlockTarget := ""
            el := ui.Find("camlockstatus")
            if IsObject(el) {
                el.label := "Target: none"
                ui.Redraw()
            }
        }
        ToolTip
        return
    }

    ToolTip, % "camlock running / players: " . players.Length() . " / on: " . camlockOn

    ; --- read the current view matrix (same 64 bytes Render() uses) ---
    pVE := ReadPtr(hProc, dllBase + static_VisualEngine)
    if !pVE
        return
    VarSetCapacity(vm, 64, 0)
    if !DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pVE + off_VE_ViewMatrix, "Ptr", &vm, "UPtr", 64, "UPtr", 0, "Int")
        return
    m := []
    Loop 16
        m[A_Index-1] := NumGet(vm, (A_Index-1)*4, "Float")

    ; --- find the best target ---
    ; The FOV centre follows the real cursor, not the middle of the window.
    VarSetCapacity(cpt, 8, 0)
    DllCall("GetCursorPos", "Ptr", &cpt)
    cx := NumGet(cpt, 0, "Int") - ovX
    cy := NumGet(cpt, 4, "Int") - ovY
    bestScore := 1.0e20
    bestSX := 0
    bestSY := 0
    bestName := ""

    ; Measure the target limit in game/world units from the local root part.
    localX := 0
    localY := 0
    localZ := 0
    if (localPrim < 0x10000 || !ReadVec3(hProc, localPrim + off_Prim_Position, localX, localY, localZ))
        return

    ; Once a target has been acquired, keep using that player until the hold
    ; key is released. This prevents a crossing player from stealing the lock.
    if (camlockTarget != "") {
        lockedFound := false
        for _, pl in players {
            if (pl.name != camlockTarget)
                continue
            if (TEAM_CHECK && pl.team && pl.team = localTeam)
                break
            if (pl.hum && ReadFloat(hProc, pl.hum + off_Hum_Health) <= 0)
                break
            ex := 0
            ey := 0
            ez := 0
            if (camlockTargetPart = "Head") {
                if (pl.headPrim < 0x10000)
                    break
                aimPrim := pl.headPrim
            } else
                aimPrim := pl.prim
            if !ReadVec3(hProc, aimPrim + off_Prim_Position, ex, ey, ez)
                break
            if !WorldToScreen(m, ex, ey, ez, ovW, ovH, bestSX, bestSY)
                break
            bestName := pl.name
            lockedFound := true
            break
        }
        ; Do not acquire a replacement while the hold key is still down.
        if !lockedFound
            return
    } else {
        for _, pl in players {
            ; team check
            if (TEAM_CHECK && pl.team && pl.team = localTeam)
                continue
            ; must be alive
            if (pl.hum) {
                hp := ReadFloat(hProc, pl.hum + off_Hum_Health)
                if (hp <= 0)
                    continue
            }
            ; read position (aim camlockHeadY units above HRP)
            ex := 0
            ey := 0
            ez := 0
            if (camlockTargetPart = "Head") {
                if (pl.headPrim < 0x10000)
                    continue
                aimPrim := pl.headPrim
            } else
                aimPrim := pl.prim
            if !ReadVec3(hProc, aimPrim + off_Prim_Position, ex, ey, ez)
                continue

            distX := ex - localX
            distY := ey - localY
            distZ := ez - localZ
            if (Sqrt(distX*distX + distY*distY + distZ*distZ) > camlockMaxDist)
                continue

            sx := 0
            sy := 0
            if !WorldToScreen(m, ex, ey, ez, ovW, ovH, sx, sy)
                continue

            dx := sx - cx
            dy := sy - cy
            d := Sqrt(dx*dx + dy*dy)
            worldDist := Sqrt(distX*distX + distY*distY + distZ*distZ)
            screenNorm := d / (camlockFovOn ? camlockFOV : Max(ovW, ovH))
            bodyNorm := worldDist / camlockMaxDist
            score := screenNorm * 0.70 + bodyNorm * 0.30
            if (score >= bestScore)
                continue

            bestScore := score
            bestSX := sx
            bestSY := sy
            bestName := pl.name
        }

        ; If nobody is inside the FOV circle, acquire the nearest visible
        ; player instead of failing half the time when the hold begins off aim.
        if (bestName = "") {
            fallbackScore := 1.0e20
            for _, pl in players {
                if (TEAM_CHECK && pl.team && pl.team = localTeam)
                    continue
                if (pl.hum && ReadFloat(hProc, pl.hum + off_Hum_Health) <= 0)
                    continue
                ex := 0
                ey := 0
                ez := 0
                if (camlockTargetPart = "Head") {
                    if (pl.headPrim < 0x10000)
                        continue
                    aimPrim := pl.headPrim
                } else
                    aimPrim := pl.prim
                if !ReadVec3(hProc, aimPrim + off_Prim_Position, ex, ey, ez)
                    continue
                distX := ex - localX
                distY := ey - localY
                distZ := ez - localZ
                if (Sqrt(distX*distX + distY*distY + distZ*distZ) > camlockMaxDist)
                    continue
                sx := 0
                sy := 0
                if !WorldToScreen(m, ex, ey, ez, ovW, ovH, sx, sy)
                    continue
                dx := sx - cx
                dy := sy - cy
                worldDist := Sqrt(distX*distX + distY*distY + distZ*distZ)
                screenNorm := d / Max(ovW, ovH)
                bodyNorm := worldDist / camlockMaxDist
                score := screenNorm * 0.70 + bodyNorm * 0.30
                if (score < fallbackScore) {
                    fallbackScore := score
                    bestSX := sx
                    bestSY := sy
                    bestName := pl.name
                }
            }
        }
    }

    ; --- update the status label ---
    if (bestName != camlockTarget) {
        camlockTarget := bestName
        el := ui.Find("camlockstatus")
        if IsObject(el) {
            el.label := "Target: " (bestName != "" ? bestName : "none")
            ui.Redraw()
        }
    }

    if (bestName = "")
        return

    ; --- move cursor toward target ---
    ; current cursor position
    VarSetCapacity(pt, 8, 0)
    DllCall("GetCursorPos", "Ptr", &pt)
    curX := NumGet(pt, 0, "Int")
    curY := NumGet(pt, 4, "Int")

    tgtX := ovX + Round(bestSX)
    tgtY := ovY + Round(bestSY)

    s := Max(0.0, Min(0.98, camlockSmooth))
    newX := Round(curX + (tgtX - curX) * (1.0 - s))
    newY := Round(curY + (tgtY - curY) * (1.0 - s))

    dX := newX - curX
    dY := newY - curY

    ; Large deviations are corrected immediately so fast target movement or
    ; manually pulling the cursor away cannot leave the lock visibly behind.
    ; Smaller corrections still use the selected smoothing value.
    if (Abs(tgtX - curX) > 120 || Abs(tgtY - curY) > 120) {
        dX := tgtX - curX
        dY := tgtY - curY
    } else if (s > 0.001) {
        maxStep := 64 + Round((1.0 - s) * 136)
        if (Abs(dX) > maxStep)
            dX := (dX > 0) ? maxStep : -maxStep
        if (Abs(dY) > maxStep)
            dY := (dY > 0) ? maxStep : -maxStep
    }

    if (dX != 0 || dY != 0) {
        ; MOUSEEVENTF_MOVE = 0x0001 - sends relative raw movement, Roblox reads this
        DllCall("mouse_event", "UInt", 0x0001, "Int", dX, "Int", dY, "UInt", 0, "UPtr", 0)
    }
}

; ---- Spectate: point the camera's CameraSubject at another player's Humanoid ----
