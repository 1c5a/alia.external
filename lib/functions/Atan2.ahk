Atan2(y, x) {
    if (x > 0)
        return ATan(y / x)
    if (x < 0)
        return ATan(y / x) + ((y >= 0) ? 3.14159265358979 : -3.14159265358979)
    return (y > 0) ? 1.5707963267949 : ((y < 0) ? -1.5707963267949 : 0)
}

; ---- player list window: click a name to spectate that player at once ----
