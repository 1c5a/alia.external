WalkTick() {
    global hProc, wsOn, wsMin, wsMax, wsPrev, wsFreq, wsSpd, wsSpdAt, localHum, localPrim
    global off_Hum_MoveDir, off_Hum_WalkSpeed, off_Prim_Position
    if (!wsOn || localHum < 0x10000 || localPrim < 0x10000 || off_Hum_MoveDir < 0x10) {
        wsPrev := 0
        return
    }
    if !wsFreq
        DllCall("QueryPerformanceFrequency", "Int64*", wsFreq)
    now := 0
    DllCall("QueryPerformanceCounter", "Int64*", now)
    if !wsPrev {
        wsPrev := now
        return
    }
    dt := (now - wsPrev) / wsFreq
    wsPrev := now
    if (dt <= 0 || dt > 0.05)
        return
    if (off_Hum_WalkSpeed >= 0x10 && ReadFloat(hProc, localHum + off_Hum_WalkSpeed) <= 5)
        return
    dx := 0
    dy := 0
    dz := 0
    if !ReadVec3(hProc, localHum + off_Hum_MoveDir, dx, dy, dz)
        return
    mag := Sqrt(dx*dx + dy*dy + dz*dz)
    if (mag < 0.001 || mag > 1.5)
        return
    lo := (wsMin < wsMax) ? wsMin : wsMax
    hi := (wsMin > wsMax) ? wsMin : wsMax
    ; a new random speed only every 100 ms (a fresh one every tick makes the steps uneven)
    if (now - wsSpdAt > wsFreq * 0.1) {
        Random, wsSpd, %lo%, %hi%
        wsSpdAt := now
    }
    step := dt * (wsSpd / 10) / mag
    x := 0
    y := 0
    z := 0
    if !ReadVec3(hProc, localPrim + off_Prim_Position, x, y, z)
        return
    WriteVec3(hProc, localPrim + off_Prim_Position, x + dx * step, y + dy * step, z + dz * step)
}

