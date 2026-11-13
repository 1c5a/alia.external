SpecStop(msg) {
    global hProc, specOn, specName, specOrig, specOrigType, localHum, off_Cam_Subject, off_Cam_Type
    if specOn {
        specOn := false
        Sleep, 5
        cam := GetCamera()
        if (cam > 0x10000) {
            WriteInt32(hProc, cam + off_Cam_Type, (specOrigType = 6) ? 5 : specOrigType)
            if (localHum > 0x10000)
                WritePtr(hProc, cam + off_Cam_Subject, localHum)
        }
    }
    specOn := false
    specName := ""
    specOrig := 0
    if (msg != "")
        SpecLabel(msg)
}

; ---- Instance attributes (like Instance:GetAttribute) ----
; the attribute list of an instance as [{name, node}, ...]. If the first name cannot be read, the name
; offset is searched inside the node (once) and saved
