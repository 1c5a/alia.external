LoadProfile() {
    global settingsFile, gameId, profSection, profIsCustom
    global GameDefs, statOn, off_DCV_Value, off_DCV_Max
    global MAX_DIST, HEAD_OFFSET, FEET_OFFSET, BOX_RATIO, TEAM_CHECK, TARGET_PART
    IniRead, dMD, %settingsFile%, keys, maxdist, 1000
    IniRead, dHO, %settingsFile%, keys, headoff, 2.8
    IniRead, dFO, %settingsFile%, keys, feetoff, 3.2
    IniRead, dBR, %settingsFile%, keys, boxratio, 0.55
    IniRead, dTC, %settingsFile%, keys, teamcheck, 0
    IniRead, dTP, %settingsFile%, keys, target, HumanoidRootPart
    profSection := (gameId > 0) ? "game_" gameId : "keys"
    profIsCustom := false
    if (profSection != "keys") {
        IniRead, probe, %settingsFile%, %profSection%, maxdist
        profIsCustom := (probe != "ERROR")
    }
    IniRead, gMD, %settingsFile%, %profSection%, maxdist, %dMD%
    IniRead, gHO, %settingsFile%, %profSection%, headoff, %dHO%
    IniRead, gFO, %settingsFile%, %profSection%, feetoff, %dFO%
    IniRead, gBR, %settingsFile%, %profSection%, boxratio, %dBR%
    IniRead, gTC, %settingsFile%, %profSection%, teamcheck, %dTC%
    IniRead, gTP, %settingsFile%, %profSection%, target, %dTP%
    MAX_DIST := (gMD > 0) ? gMD + 0 : 1000
    HEAD_OFFSET := (gHO > 0) ? gHO + 0 : 2.8
    FEET_OFFSET := (gFO > 0) ? gFO + 0 : 3.2
    BOX_RATIO := (gBR > 0) ? gBR + 0 : 0.55
    TEAM_CHECK := (gTC = "1") ? true : false
    TARGET_PART := (Trim(gTP) != "") ? Trim(gTP) : "HumanoidRootPart"
    if (MAX_DIST < 100)
        MAX_DIST := 100
    if (MAX_DIST > 10000)
        MAX_DIST := 10000
    statOn := {}
    IniRead, vV, %settingsFile%, keys, dcvvalue, %off_DCV_Value%
    IniRead, vM, %settingsFile%, keys, dcvmax, %off_DCV_Max%
    off_DCV_Value := vV + 0
    off_DCV_Max := vM + 0
    BuildGameStats()
}

