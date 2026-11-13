SetStreamProof(hWnd, enable) {
    affinity := enable ? 0x11 : 0x00
    DllCall("SetWindowDisplayAffinity", "Ptr", hWnd, "UInt", affinity)
}

; keyToggle / keyExit / keyStream / keyHook / keyUI hold the requested keys (set by the key boxes)
; writes the current tunables into one INI section ("keys" = defaults, "game_<id>" = per-game)
; CFrame speed: each tick the local root part is moved along the Humanoid's MoveDirection by
; dt * (speed / 10), where speed is a random integer between Min and Max (as in the script this follows).
; Only while the Humanoid is moving and its WalkSpeed is above 5.
