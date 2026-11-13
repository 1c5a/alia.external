SpecTick() {
    global specOn, specLoopOn
    if (specOn && !specLoopOn)
        SpecLoop()
}

; tight loop while spectating: every ~1 ms the camera is kept in Scriptable mode and its position/rotation are written so it
; sits behind the player and looks at them. Mouse OR arrow keys orbit, PageUp / PageDown zoom. The target is looked up every 100 ms
; and the camera pointer every second. Camera write is throttled to 16 ms to stop the flicker caused by overwriting every 1 ms.
