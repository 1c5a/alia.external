WorldToScreen(m, x, y, z, sw, sh, ByRef sx, ByRef sy) {
    global MATRIX_TRANSPOSED
    rs := MATRIX_TRANSPOSED ? 1 : 4
    cs := MATRIX_TRANSPOSED ? 4 : 1
    cw := m[3*rs]*x + m[3*rs + cs]*y + m[3*rs + 2*cs]*z + m[3*rs + 3*cs]
    if (cw < 0.001)
        return false
    cx := m[0]*x + m[cs]*y + m[2*cs]*z + m[3*cs]
    cy := m[rs]*x + m[rs + cs]*y + m[rs + 2*cs]*z + m[rs + 3*cs]
    sx := (sw / 2) * (1 + cx / cw)
    sy := (sh / 2) * (1 - cy / cw)
    return true
}

