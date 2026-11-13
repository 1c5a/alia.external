SaveCamlockConfig() {
    global settingsFile, camlockHoldKey, camlockSmooth, camlockFovOn, camlockFovFill
    global camlockFovAlpha, camlockFOV, camlockMaxDist, camlockHeadY
    v := camlockHoldKey
    IniWrite, %v%, %settingsFile%, keys, camlockhold
    v := Round(camlockSmooth * 100)
    IniWrite, %v%, %settingsFile%, keys, camlocksmooth
    v := camlockFovOn ? 1 : 0
    IniWrite, %v%, %settingsFile%, keys, camlockfovon
    v := camlockFovFill ? 1 : 0
    IniWrite, %v%, %settingsFile%, keys, camlockfovfill
    v := camlockFovAlpha
    IniWrite, %v%, %settingsFile%, keys, camlockfovalpha
    v := camlockFOV
    IniWrite, %v%, %settingsFile%, keys, camlockfov
    v := camlockMaxDist
    IniWrite, %v%, %settingsFile%, keys, camlockdist
    v := camlockHeadY
    IniWrite, %v%, %settingsFile%, keys, camlockheady
    SaveIniConfigToJson()
}

