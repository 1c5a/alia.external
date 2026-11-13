SpecSelectName(name) {
    global hProc, players, specOn, specName, specCam, specOrigType, specYaw, specPitch
    global off_WS_Camera, off_Cam_Type, off_Cam_Rot
    if (name = "")
        return
    if (off_WS_Camera < 0x10) {
        Tip("Workspace::CurrentCamera offset not in the dump - set it on the Debug tab", 4500)
        return
    }
    cam := GetCamera()
    if (cam < 0x10000) {
        Tip("Camera not found")
        return
    }
    for _, pl in players {
        if (pl.name = name && pl.hum > 0x10000) {
            if !specOn {
                specOrigType := ReadInt32(hProc, cam + off_Cam_Type)
                ; start from where the camera is already looking
                ; the camera's back vector is the third column of its rotation matrix (floats 2, 5, 8)
                lx := -ReadFloat(hProc, cam + off_Cam_Rot + 8)
                ly := -ReadFloat(hProc, cam + off_Cam_Rot + 20)
                lz := -ReadFloat(hProc, cam + off_Cam_Rot + 32)
                specYaw := Atan2(lx, lz)
                specPitch := ASin(Max(-0.99, Min(0.99, ly)))
            }
            specCam := cam
            specName := name
            specOn := true
            SpecLabel("Spectating: " name)
            SetTimer, SpecKick, -1
            return
        }
    }
    Tip("Player not found")
}

