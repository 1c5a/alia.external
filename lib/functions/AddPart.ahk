AddPart(list, s) {
    if (s = "")
        return list
    if InStr("`n" list "`n", "`n" s "`n")
        return list
    if (list = "")
        return s
    return list "`n" s
}

; menu colours are 0xRRGGBB, GDI wants 0xBBGGRR; pure black is the overlay's see-through colour, so it becomes near-black
