FlushProfileSave() {
    global profSection, profIsCustom
    WriteProfile(profSection)
    if (profSection != "keys")
        profIsCustom := true
    UpdateUI()
}

; picks the label font for ESP text (applies on the next frame) and saves it; accepts an index or a font name
