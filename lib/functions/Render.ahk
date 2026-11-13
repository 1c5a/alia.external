Render() {
    global hwnd, hGui, hdcMem, ovX, ovY, ovW, ovH, espOn, players, localPrim, localTeam
    global hProc, dllBase, static_VisualEngine, off_VE_ViewMatrix
    global off_Hum_Health, off_Hum_MaxHealth, off_Prim_Position
    global TEAM_CHECK, MAX_DIST, HEAD_OFFSET, FEET_OFFSET, BOX_RATIO, BOXBAR_DIST
    global brushKey, brushOutline, brushBox, brushBack, brushGreen, brushYellow, brushRed
    global sideBottom, sideRight, sideLeft
    global dirtyOn, dL, dT, dR, dB
    global vBars, vHpBar, vHpW, vText, vTextBGR, vTextSize, vBoxAlpha, mobs, mobOn, mobHp, mobHpW, mobText, mobTextBGR, mobTextSize, mobDistMax
    global tagUser, tagDisp, tagHpPct, tagHpCur, tagDist
    global dbgMobs, dbgOut, dbgShown, dbgCnt
    global camlockOn, camlockFovOn, camlockFOV, camlockFovFill, fovPen, fovFillBrush

    if !WinExist("ahk_id " hwnd)
        ExitApp

    nx := 0
    ny := 0
    nw := 0
    nh := 0
    GetClientArea(hwnd, nx, ny, nw, nh)
    if (nw < 1 || nh < 1)
        return
    if (nw != ovW || nh != ovH) {
        ovX := nx
        ovY := ny
        ovW := nw
        ovH := nh
        WinMove, ahk_id %hGui%, , %ovX%, %ovY%, %ovW%, %ovH%
        ResizeBackbuffer(hGui, ovW, ovH)
        dirtyOn := true
        dL := 0
        dT := 0
        dR := ovW
        dB := ovH
    } else if (nx != ovX || ny != ovY) {
        ovX := nx
        ovY := ny
        WinMove, ahk_id %hGui%, , %ovX%, %ovY%
    }

    dbgOut := ""
    dbgCnt := 0
    ; only clear what was drawn last frame (not the whole overlay)
    if dirtyOn
        GdiFill(hdcMem, dL, dT, dR, dB, brushKey)
    drew := false
    cL := 99999
    cT := 99999
    cR := -1
    cB := -1

    ; Draw the enabled FOV circle around the actual cursor position.
    if (camlockOn && camlockFovOn && WinActive("ahk_id " hwnd) && fovPen) {
        VarSetCapacity(fpt, 8, 0)
        DllCall("GetCursorPos", "Ptr", &fpt)
        fcx := NumGet(fpt, 0, "Int") - ovX
        fcy := NumGet(fpt, 4, "Int") - ovY
        fbrush := camlockFovFill ? fovFillBrush : DllCall("GetStockObject", "Int", 5, "Ptr") ; NULL_BRUSH
        DrawFovCircle(hdcMem, fcx, fcy, camlockFOV, fovPen, fbrush)
        cL := fcx - camlockFOV
        cT := fcy - camlockFOV
        cR := fcx + camlockFOV
        cB := fcy + camlockFOV
        drew := true
    }

    if ((espOn || mobOn) && (WinActive("ahk_id " hwnd) || UiOpen())) {
        pVE := ReadPtr(hProc, dllBase + static_VisualEngine)
        if pVE {
            VarSetCapacity(vm, 64, 0)
            DllCall("ReadProcessMemory", "Ptr", hProc, "Ptr", pVE + off_VE_ViewMatrix, "Ptr", &vm, "UPtr", 64, "UPtr", 0, "Int")
            m := []
            Loop 16
                m[A_Index-1] := NumGet(vm, (A_Index-1)*4, "Float")

            hasLocal := false
            lx := 0
            ly := 0
            lz := 0
            if localPrim
                hasLocal := ReadVec3(hProc, localPrim + off_Prim_Position, lx, ly, lz)

            nBot := sideBottom.Length()
            nRight := sideRight.Length()
            nLeft := sideLeft.Length()

            for pass, grp in [players, mobs] {
                if (pass = 1) {
                    cOn := espOn
                    cDist := MAX_DIST
                    cBoxOk := (vBoxAlpha > 0)
                    cHp := (vBars && vHpBar)
                    cMisc := (vBars && (nBot + nRight + nLeft) > 0)
                    cHpW := vHpW
                    cText := vText
                    cBGR := vTextBGR
                    cSize := vTextSize
                } else {
                    cOn := mobOn
                    cDist := mobDistMax
                    cBoxOk := false
                    cHp := mobHp
                    cMisc := false
                    cHpW := mobHpW
                    cText := mobText
                    cBGR := mobTextBGR
                    cSize := mobTextSize
                }
                if !cOn
                    continue
                UseFont(cSize)
                lineH := cSize + 3
                for _, pl in grp {
                    if (pass = 1 && TEAM_CHECK && pl.team && pl.team = localTeam)
                        continue
                    x := 0
                    y := 0
                    z := 0
                    if !ReadVec3(hProc, pl.prim + off_Prim_Position, x, y, z) {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "position read failed")
                        continue
                    }
                    if (x = 0 && y = 0 && z = 0) {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "position is 0,0,0")
                        continue
                    }

                    hp := 100
                    maxhp := 100
                    if pl.hum {
                        hp := ReadFloat(hProc, pl.hum + off_Hum_Health)
                        maxhp := ReadFloat(hProc, pl.hum + off_Hum_MaxHealth)
                        if (hp <= 0) {
                            if (pass = 2 && dbgMobs)
                                DbgMob(pl.name, "hp <= 0 (" hp ")")
                            continue
                        }
                    }

                    ; Max distance (slider) hides the whole player; boxes and bars stop at BOXBAR_DIST
                    dist := 0
                    if hasLocal {
                        dist := Sqrt((x-lx)**2 + (y-ly)**2 + (z-lz)**2)
                        if (dist > cDist) {
                            if (pass = 2 && dbgMobs)
                                DbgMob(pl.name, "too far (" Round(dist) " > " cDist ")")
                            continue
                        }
                    }
                    inRange := (!hasLocal || dist <= BOXBAR_DIST)
                    drawBox := (inRange && cBoxOk)
                    drawHp := (inRange && cHp)
                    drawMisc := (inRange && cMisc)

                    ratio := (maxhp > 0) ? hp / maxhp : 1
                    if (ratio > 1)
                        ratio := 1
                    if (ratio < 0)
                        ratio := 0

                    ; text: line1 = names, line2 = health, line3 = distance (under the box)
                    line1 := ""
                    line2 := ""
                    line3 := ""
                    if cText {
                        if (pass = 1) {
                            parts := ""
                            if tagUser
                                parts := AddPart(parts, pl.name)
                            if tagDisp
                                parts := AddPart(parts, pl.disp)
                            line1 := StrReplace(parts, "`n", " | ")
                            parts := ""
                            if (pl.hum && tagHpPct)
                                parts := AddPart(parts, Round(ratio * 100) "%")
                            if (pl.hum && tagHpCur)
                                parts := AddPart(parts, Round(hp) "/" Round(maxhp))
                            line2 := StrReplace(parts, "`n", " | ")
                            if (tagDist && hasLocal)
                                line3 := "[" Round(dist) "m]"
                        } else {
                            line1 := pl.name
                            if hasLocal
                                line3 := "[" Round(dist) "m]"
                        }
                    }
                    if (!drawBox && !drawHp && !drawMisc && line1 = "" && line2 = "" && line3 = "") {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "nothing to draw (text off?)")
                        continue
                    }

                    tx := 0
                    ty := 0
                    bx := 0
                    by := 0
                    if !WorldToScreen(m, x, y + HEAD_OFFSET, z, ovW, ovH, tx, ty) {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "head point behind camera, dist " Round(dist))
                        continue
                    }
                    if !WorldToScreen(m, x, y - FEET_OFFSET, z, ovW, ovH, bx, by) {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "feet point behind camera, dist " Round(dist))
                        continue
                    }
                    bh := by - ty
                    if (bh > ovH * 3) {
                        if (pass = 2 && dbgMobs)
                            DbgMob(pl.name, "box height " Round(bh, 2) " too large, dist " Round(dist))
                        continue
                    }
                    ; far away the head/feet points can be under 1 px apart or even swapped (camera pitch): keep the text
                    ; at the mob's projected centre with a 1 px box instead of dropping it
                    if (bh < 1) {
                        cy := (ty + by) / 2
                        ty := cy - 0.5
                        by := cy + 0.5
                        bh := 1
                    }
                    bw := bh * BOX_RATIO
                    l := Round(tx - bw/2)
                    r := Round(tx + bw/2)
                    t := Round(ty)
                    b := Round(by)
                    mid := Round(tx)
                    if (pass = 2 && dbgMobs)
                        DbgMob(pl.name, "drawn at " Round(tx) "," Round(ty) " bh=" Round(bh, 1) " dist " Round(dist))

                    ; the health bar sits left of the box, extra bars continue further left
                    leftX := l - 3
                    if drawHp
                        leftX := leftX - cHpW - 3

                    nLines := (line1 != "") + (line2 != "")
                    baseY := Round(t - 3 - nLines * lineH)
                    if (baseY < 0)
                        baseY := 0
                    belowY := b + 2
                    if (drawMisc && nBot > 0)
                        belowY := belowY + 2 + 5 * nBot

                    ; grow this frame's dirty rectangle to cover everything drawn for this player
                    eL := l - 4
                    eR := r + 4
                    eT := t - 4
                    eB := b + 4
                    if drawHp
                        eL := l - cHpW - 8
                    if drawMisc {
                        eL := leftX - 5 * nLeft - 4
                        eR := r + 8 + 5 * nRight
                        eB := b + 8 + 5 * nBot
                    }
                    maxW := 0
                    for _, s in [line1, line2, line3] {
                        if (s != "") {
                            wv := TextW(hdcMem, s)
                            if (wv > maxW)
                                maxW := wv
                        }
                    }
                    if (maxW > 0) {
                        if (mid - maxW // 2 - 4 < eL)
                            eL := mid - maxW // 2 - 4
                        if (mid + maxW // 2 + 5 > eR)
                            eR := mid + maxW // 2 + 5
                    }
                    if (nLines > 0 && baseY - 2 < eT)
                        eT := baseY - 2
                    if (line3 != "" && belowY + lineH + 3 > eB)
                        eB := belowY + lineH + 3
                    drew := true
                    if (eL < cL)
                        cL := eL
                    if (eT < cT)
                        cT := eT
                    if (eR > cR)
                        cR := eR
                    if (eB > cB)
                        cB := eB

                    if drawBox {
                        GdiFrame(hdcMem, l-1, t-1, r+1, b+1, brushOutline)
                        GdiFrame(hdcMem, l, t, r, b, brushBox)
                        GdiFrame(hdcMem, l+1, t+1, r-1, b-1, brushOutline)
                    }
                    if drawHp {
                        hpBrush := (ratio > 0.6) ? brushGreen : (ratio > 0.3) ? brushYellow : brushRed
                        fh := Round((b - t) * ratio)
                        hx := l - 3
                        GdiFill(hdcMem, hx - cHpW - 1, t - 1, hx + 1, b + 1, brushOutline)
                        GdiFill(hdcMem, hx - cHpW, t, hx, b, brushBack)
                        GdiFill(hdcMem, hx - cHpW, b - fh, hx, b, hpBrush)
                    }
                    if drawMisc
                        DrawStatMeters(hdcMem, pl, l, t, r, b, leftX)
                    textY := baseY
                    if (line1 != "") {
                        DrawLabel(hdcMem, mid, textY, line1, cBGR)
                        textY := textY + lineH
                    }
                    if (line2 != "")
                        DrawLabel(hdcMem, mid, textY, line2, cBGR)
                    if (line3 != "")
                        DrawLabel(hdcMem, mid, belowY, line3, cBGR)
                }
            }
        }
    }

    if (dbgMobs && mobOn) {
        if (dbgOut != dbgShown) {
            dbgShown := dbgOut
            ToolTip, % (dbgOut != "") ? dbgOut : "(no mobs in the list)", 20, 20
        }
    }
    ; nothing drawn now and nothing to erase from last frame: skip the blit entirely
    if (!drew && !dirtyOn)
        return

    ; blit only the union of last frame's and this frame's drawn areas
    if (drew && dirtyOn) {
        uL := (dL < cL) ? dL : cL
        uT := (dT < cT) ? dT : cT
        uR := (dR > cR) ? dR : cR
        uB := (dB > cB) ? dB : cB
    } else if drew {
        uL := cL
        uT := cT
        uR := cR
        uB := cB
    } else {
        uL := dL
        uT := dT
        uR := dR
        uB := dB
    }
    if (uL < 0)
        uL := 0
    if (uT < 0)
        uT := 0
    if (uR > ovW)
        uR := ovW
    if (uB > ovH)
        uB := ovH
    if (uR > uL && uB > uT) {
        hdcWin := DllCall("GetDC", "Ptr", hGui, "Ptr")
        DllCall("BitBlt", "Ptr", hdcWin, "Int", uL, "Int", uT, "Int", uR - uL, "Int", uB - uT, "Ptr", hdcMem, "Int", uL, "Int", uT, "UInt", 0xCC0020)
        DllCall("ReleaseDC", "Ptr", hGui, "Ptr", hdcWin)
    }

    dirtyOn := drew
    if drew {
        dL := cL
        dT := cT
        dR := cR
        dB := cB
    }
}

