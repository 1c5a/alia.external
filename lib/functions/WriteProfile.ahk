WriteProfile(sec) {
    global settingsFile, MAX_DIST, HEAD_OFFSET, FEET_OFFSET, BOX_RATIO, TEAM_CHECK, TARGET_PART, gameId, GameDefs, statOn
    IniWrite, %MAX_DIST%, %settingsFile%, %sec%, maxdist
    IniWrite, %HEAD_OFFSET%, %settingsFile%, %sec%, headoff
    IniWrite, %FEET_OFFSET%, %settingsFile%, %sec%, feetoff
    IniWrite, %BOX_RATIO%, %settingsFile%, %sec%, boxratio
    IniWrite, % (TEAM_CHECK ? 1 : 0), %settingsFile%, %sec%, teamcheck
    IniWrite, %TARGET_PART%, %settingsFile%, %sec%, target
}

; defaults come from [keys]; a [game_<id>] section overrides them for that game
