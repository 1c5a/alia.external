IsClassName(s) {
    return (StrLen(s) >= 2 && StrLen(s) <= 64 && RegExMatch(s, "^[A-Za-z][A-Za-z0-9_]*$"))
}

