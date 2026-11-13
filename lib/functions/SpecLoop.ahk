SpecLoop() {
    global hProc, players, specOn, specName, specCam, specLoopOn, specYaw, specPitch, specDist
    global off_Cam_Type, off_Cam_Rot, off_Cam_Pos, off_Prim_Position
    global specMouseSens, specLastMouseX, specLastMouseY, specMouseInit
    if specLoopOn
        return
    specLoopOn := true
    prim := 0
    lookAt := 0
    camAt := 0
    writeAt := 0
    last := A_TickCount
    pumpAt := last
    VarSetCapacity(wb, 48, 0)
    ; AutoHotkey's own Sleep, 1 really waits 10-15 ms, which is a frame or more: use the Windows Sleep (1 ms with
    ; timeBeginPeriod) and run this thread at the highest priority
    hThr := DllCall("GetCurrentThread", "Ptr")
    DllCall("SetThreadPriority", "Ptr", hThr, "Int", 2)
    ; seed mouse position so first delta is 0
    VarSetCapacity(mptBuf, 8, 0)
    DllCall("GetCursorPos", "Ptr", &mptBuf)
    specLastMouseX := NumGet(mptBuf, 0, "Int")
    specLastMouseY := NumGet(mptBuf, 4, "Int")
    specMouseInit := true
    while specOn {
        now := A_TickCount
        dt := (now - last) / 1000
        last := now
        if (now - lookAt > 100) {
            lookAt := now
            prim := 0
            for _, pl in players {
                if (pl.name = specName && pl.prim > 0x10000) {
                    prim := pl.prim
                    break
                }
            }
            if !prim {
                DllCall("SetThreadPriority", "Ptr", hThr, "Int", 0)
                specLoopOn := false
                SpecStop("Spectating: off (player gone)")
                return
            }
        }
        if (specCam < 0x10000 || now - camAt > 1000) {
            camAt := now
            c := GetCamera()
            if (c > 0x10000)
                specCam := c
        }
        if (dt > 0.1)
            dt := 0.1
        ; --- mouse orbit (right-button held to look) ---
        VarSetCapacity(mptBuf2, 8, 0)
        DllCall("GetCursorPos", "Ptr", &mptBuf2)
        curMX := NumGet(mptBuf2, 0, "Int")
        curMY := NumGet(mptBuf2, 4, "Int")
        if GetKeyState("RButton", "P") {
            mdx := curMX - specLastMouseX
            mdy := curMY - specLastMouseY
            if (mdx != 0 || mdy != 0) {
                specYaw += mdx * specMouseSens
                specPitch := Max(-1.4, Min(1.4, specPitch - mdy * specMouseSens))
            }
        }
        specLastMouseX := curMX
        specLastMouseY := curMY
        ; --- arrow key orbit (still works alongside mouse) ---
        if GetKeyState("Left", "P")
            specYaw -= 1.8 * dt
        if GetKeyState("Right", "P")
            specYaw += 1.8 * dt
        if GetKeyState("Up", "P")
            specPitch := Min(1.4, specPitch + 1.2 * dt)
        if GetKeyState("Down", "P")
            specPitch := Max(-1.4, specPitch - 1.2 * dt)
        if GetKeyState("PgUp", "P")
            specDist := Max(2, specDist - 15 * dt)
        if GetKeyState("PgDn", "P")
            specDist := Min(80, specDist + 15 * dt)
        ; --- only write to process every 16 ms (~60 fps) to stop flicker ---
        if (specCam > 0x10000 && now - writeAt >= 16) {
            writeAt := now
            tx := 0
            ty := 0
            tz := 0
            if ReadVec3(hProc, prim + off_Prim_Position, tx, ty, tz) {
                cp := Cos(specPitch)
                lx := cp * Sin(specYaw)
                ly := Sin(specPitch)
                lz := cp * Cos(specYaw)
                ; look = (lx,ly,lz); right = look x up; up' = right x look; back = -look
                rxx := -lz
                rxz := lx
                rl := Sqrt(rxx*rxx + rxz*rxz)
                rxx /= rl
                rxz /= rl
                uxx := -rxz * ly
                uyy := rxz * lx - rxx * lz
                uzz := rxx * ly
                ty += 1.5
                NumPut(rxx, wb, 0, "Float")
                NumPut(uxx, wb, 4, "Float")
                NumPut(-lx, wb, 8, "Float")
                NumPut(0, wb, 12, "Float")
                NumPut(uyy, wb, 16, "Float")
                NumPut(-ly, wb, 20, "Float")
                NumPut(rxz, wb, 24, "Float")
                NumPut(uzz, wb, 28, "Float")
                NumPut(-lz, wb, 32, "Float")
                NumPut(tx - lx * specDist, wb, 36, "Float")
                NumPut(ty - ly * specDist, wb, 40, "Float")
                NumPut(tz - lz * specDist, wb, 44, "Float")
                WriteInt32(hProc, specCam + off_Cam_Type, 6)
                DllCall("WriteProcessMemory", "Ptr", hProc, "Ptr", specCam + off_Cam_Rot, "Ptr", &wb, "UPtr", 48, "UPtr", 0, "Int")
            }
        }
        DllCall("Sleep", "UInt", 1)
        if (A_TickCount - pumpAt > 15) {
            pumpAt := A_TickCount
            Sleep, -1 ; let the UI and the list window process their messages
        }
    }
    DllCall("SetThreadPriority", "Ptr", hThr, "Int", 0)
    specLoopOn := false
}

