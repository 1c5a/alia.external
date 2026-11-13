UiOpen() {
    global visible, uiTarget
    return (visible && uiTarget) ? true : false
}

; one-shot call outside of the click handler (dialogs, reloads, long work)
