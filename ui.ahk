; ALIA.UI.LIB

class EasyUI {
    __New(opts := "") {
        EUI_Init(opts)
    }

    Tab(n, title, icon := "") {
        global tabTitle, ringIcons
        tabTitle[n] := title
        if (icon != "")
            ringIcons[n] := icon
        return this
    }

    Add(n, el) {
        UIAdd(n, el)
        return this
    }

    OnEvent(fn) {
        global EUI_Handler
        EUI_Handler := IsObject(fn) ? fn : Func(fn)
    }

    OnRing(fn) {
        global EUI_RingHandler
        EUI_RingHandler := IsObject(fn) ? fn : Func(fn)
    }

    AddIcon(name, data) {
        EUI_AddIcon(name, data)
    }

    Start() {
        EUI_Start()
    }

    Find(key) {
        return FindEl(key)
    }

    Get(key) {
        el := FindEl(key)
        if (!IsObject(el))
            return ""
        if (el.type = "color")
            return el.color
        if (el.type = "keybind")
            return el.bind
        return el.value
    }

    Set(key, value) {
        global needDraw
        el := FindEl(key)
        if (!IsObject(el))
            return false
        if (el.type = "color")
            el.color := value
        else if (el.type = "keybind")
            el.bind := value
        else
            el.value := value
        needDraw := true
        return true
    }

    Show() {
        ShowOverlay()
    }

    Hide() {
        HideOverlay()
    }

    Toggle() {
        ToggleOverlay()
    }

    Redraw() {
        global needDraw
        needDraw := true
    }

    SetAccent(rgb) {
        SetAccent(rgb)
    }

    Quit() {
        ExitApp
    }
}
tab panel size
EUI_Init(opts := "") {
    global
    local k, v, allowed, acc, tk

    OUTER_R := 230
    HOLE_R := 110
    EXPAND := 16
    LINE_W := 3
    GAP := 4
    CORNER_R := 40
    PENT_R := 88
    PENT_EXP := 8
    PENT_COR := 40
    EASE := 0.22
    TAB_W := 600
    TAB_H := 440
    FADE_STEP := 0.2
    TAB_COR := 32
    TITLE_H := 40

    acc := 0xFF69B4
    tk := "F8"
    allowed := " OUTER_R HOLE_R EXPAND LINE_W GAP CORNER_R PENT_R PENT_EXP PENT_COR EASE TAB_W TAB_H FADE_STEP TAB_COR TITLE_H "
    if (IsObject(opts)) {
        for k, v in opts {
            if (k = "Accent")
                acc := v
            else if (k = "ToggleKey")
                tk := v
            else if (InStr(allowed, " " . k . " "))
                %k% := v
        }
    }

    RSIZE := Max((OUTER_R + EXPAND + LINE_W + 2) * 2, TAB_W + LINE_W * 2 + 8, TAB_H + LINE_W * 2 + 8)
    RX := (A_ScreenWidth - RSIZE) // 2
    RY := (A_ScreenHeight - RSIZE) // 2
    hover := 0
    visible := true
    uiA := 1
    uiTarget := 1
    ACC_A := 1
    anim := [0, 0, 0, 0, 0, 0]

    mode := "ring"
    ringA := 1
    tabA := 0
    activeTab := 0
    tabTitle := ["Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5", "Settings"]
    ringIcons := ["sliders-horizontal", "mouse-pointer-click", "palette", "monitor", "info", "settings"]
    tabUI := []
    hoverEl := 0
    hoverSub := 0
    dragEl := 0
    listenEl := 0
    pickEl := 0
    pickOpen := 0
    pickA := 0
    ddOpen := 0
    ddEl := 0
    ddA := 0
    ddHover := 0
    dragCh := 0
    pkX := 0
    pkY := 0
    PK_W := 310
    PK_H := 280
    SQ_W := 242
    SQ_H := 140
    HB_W := 24
    pkH := 0
    pkS := 0
    pkV := 0
    editField := 0
    editText := ""
    editFresh := 0
    editOrig := 0
    editOrigA := 100
    inputEl := 0
    inputOrig := ""
    inHook := ""
    inputCaret := 0
    inputAnchor := 0
    inputDrag := 0
    blinkOn := 1
    colMul := 1
    needDraw := false
    EUI_Handler := ""
    EUI_RingHandler := ""

    CoordMode, Mouse, Screen
    SetBatchLines, -1

    Gui, UI:+AlwaysOnTop -Caption +ToolWindow +HwndUIHwnd
    Gui, UI:Color, 000000
    Gui, UI:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
    EnableBlur(UIHwnd, 3)
    WinSet, Transparent, 230, ahk_id %UIHwnd%

    Gui, Ring:+AlwaysOnTop -Caption +ToolWindow +E0x80000 +OwnerUI +HwndhRing
    Gui, Ring:Show, x%RX% y%RY% w%RSIZE% h%RSIZE% NA

    DllCall("LoadLibrary", "Str", "gdiplus")
    VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0)
    NumPut(1, si, 0, "UInt")
    DllCall("gdiplus\GdiplusStartup", "Ptr*", gdipToken, "Ptr", &si, "Ptr", 0)

    rhdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
    VarSetCapacity(bi, 40, 0)
    NumPut(40, bi, 0, "UInt")
    NumPut(RSIZE, bi, 4, "Int")
    NumPut(-RSIZE, bi, 8, "Int")
    NumPut(1, bi, 12, "UShort")
    NumPut(32, bi, 14, "UShort")
    rhbm := DllCall("CreateDIBSection", "Ptr", rhdc, "Ptr", &bi, "UInt", 0, "Ptr*", 0, "Ptr", 0, "UInt", 0, "Ptr")
    DllCall("SelectObject", "Ptr", rhdc, "Ptr", rhbm)
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", rhdc, "Ptr*", rg)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", rg, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", rg, "Int", 4)

    SetAccent(acc)
    BuildSettingsTab(tk, acc)
}

EUI_Start() {
    global
    Loop, 6 {
        if (!IsObject(tabUI[A_Index]))
            tabUI[A_Index] := []
        LayoutTab(A_Index)
    }
    DrawRing()
    OnMessage(0x201, "RingClick")
    OnMessage(0x203, "RingClick")
    SetTimer, RingHover, 15
    SetTimer, BindPoll, 15
}

EUI_AddIcon(name, data) {
    global EUI_UserIcons
    if (!IsObject(EUI_UserIcons))
        EUI_UserIcons := {}
    arr := []
    for i, tok in StrSplit(data, " ") {
        if (tok = "")
            continue
        if (tok = "M")
            arr.Push(0)
        else if (tok = "L")
            arr.Push(1)
        else if (tok = "C")
            arr.Push(2)
        else if (tok = "Z")
            arr.Push(3)
        else
            arr.Push(tok + 0)
    }
    EUI_UserIcons[name] := arr
}

$Esc::
    if (!visible || !uiTarget) {
        Send, {Esc}
        return
    }
    if (inputEl) {
        StopInput(false)
        KeyWait, Esc
        return
    }
    if (ddOpen) {
        ddOpen := 0
        needDraw := true
        KeyWait, Esc
        return
    }
    if (editField) {
        CancelEdit()
        KeyWait, Esc
        return
    }
    if (listenEl) {
        listenEl := 0
        needDraw := true
        KeyWait, Esc
        return
    }
ExitApp
return

RingHover:
    MouseGetPos, mx, my
    changed := false

    if (uiA != uiTarget) {
        uiA += (uiTarget > uiA) ? 0.14 : -0.14
        uiA := uiA < 0 ? 0 : (uiA > 1 ? 1 : uiA)
        WinSet, Transparent, % Round(230 * uiA), ahk_id %UIHwnd%
        changed := true
        if (uiA = 0 && uiTarget = 0) {
            DrawRing()
            SetTimer, RingHover, Off
            Gui, Ring:Hide
            Gui, UI:Hide
            visible := false
            return
        }
    }

    if (mode = "ringout") {
        ringA -= FADE_STEP
        if (ringA <= 0) {
            ringA := 0
            mode := "tabin"
        }
        changed := true
    } else if (mode = "tabin") {
        tabA += FADE_STEP
        ringA -= FADE_STEP
        if (ringA < 0)
            ringA := 0
        if (tabA >= 1) {
            tabA := 1
            ringA := 0
            mode := "tab"
        }
        changed := true
    } else if (mode = "tabout") {
        tabA -= FADE_STEP
        if (tabA <= 0) {
            tabA := 0
            mode := "ringin"
        }
        changed := true
    } else if (mode = "ringin") {
        ringA += FADE_STEP
        tabA -= FADE_STEP
        if (tabA < 0)
            tabA := 0
        if (ringA >= 1) {
            ringA := 1
            tabA := 0
            mode := "ring"
        }
        changed := true
    }

    if (mode = "ring" || mode = "ringin" || mode = "tabin" || mode = "tab")
        hover := HitTest(mx, my)
    else
        hover := 0

    if (mode = "tab" || mode = "tabin") {
        if (dragEl) {
            if (GetKeyState("LButton", "P")) {
                if (SliderSet(tabUI[activeTab][dragEl], mx))
                    changed := true
                hoverEl := dragEl
            } else {
                dragEl := 0
            }
        }
        if (dragCh) {
            if (GetKeyState("LButton", "P")) {
                if (PickDrag(tabUI[activeTab][pickEl], dragCh, mx, my))
                    changed := true
            } else {
                dragCh := 0
            }
        }
        if (inputDrag) {
            if (GetKeyState("LButton", "P")) {
                if (InputDragTo(mx))
                    changed := true
            } else {
                inputDrag := 0
            }
        }
        if (ddOpen) {
            nh := DdHit(mx, my)
            if (nh != ddHover) {
                ddHover := nh
                changed := true
            }
        }
        if (pickOpen || ddOpen) {
            hoverEl := 0
            hoverSub := 0
        } else if (!dragEl) {
            hoverEl := TabHit(mx, my)
        }
    } else {
        dragEl := 0
        dragCh := 0
        inputDrag := 0
        ddOpen := 0
        pickOpen := 0
        editField := 0
        StopInput(true)
        hoverEl := 0
        hoverSub := 0
    }
    if (editField || inputEl) {
        bo := Mod(A_TickCount // 500, 2)
        if (bo != blinkOn) {
            blinkOn := bo
            changed := true
        }
    }
    pa := StepTo(pickA, pickOpen ? 1 : 0, 0.3)
    if (pa != pickA) {
        pickA := pa
        changed := true
    }
    if (pickA = 0 && !pickOpen)
        pickEl := 0
    da := StepTo(ddA, ddOpen ? 1 : 0, 0.3)
    if (da != ddA) {
        ddA := da
        changed := true
    }
    if (ddA = 0 && !ddOpen)
        ddEl := 0
    if (tabA > 0 && TweenTabUI())
        changed := true

    Loop, 6 {
        target := (A_Index = hover) ? 1 : 0
        v := anim[A_Index]
        nv := v + (target - v) * EASE
        if (Abs(nv - target) < 0.005)
            nv := target
        if (nv != v) {
            anim[A_Index] := nv
            changed := true
        }
    }
    if (changed || needDraw) {
        needDraw := false
        DrawRing()
    }
return

BindPoll:
    BindTick()
return

RingClick(wParam, lParam, msg, hwnd) {
    global hRing, UIHwnd, hover, mode, tabUI, activeTab, listenEl, pickEl, pickOpen, dragCh, editField, uiTarget, inputEl, ddOpen, ddEl
    if (hwnd != hRing && hwnd != UIHwnd)
        return
    if (!uiTarget)
        return
    MouseGetPos, mx, my
    hover := HitTest(mx, my)
    if (mode = "tab" || mode = "tabin") {
        listenEl := 0
        if (inputEl && !pickOpen && hover != 0 && TabHit(mx, my) = inputEl) {
            InputMouse(mx, msg = 0x203)
            DrawRing()
            return
        }
        StopInput(true)
        if (ddOpen) {
            o := DdHit(mx, my)
            if (o) {
                el := tabUI[activeTab][ddEl]
                el.value := o
                UIEvent(el.key, o, el.items[o])
            }
            ddOpen := 0
            DrawRing()
            return
        }
        if (hover = 0) {
            CloseTab()
            return
        }
        if (pickOpen) {
            part := PickerHit(mx, my)
            if (part >= 3 && part <= 7) {
                if (editField != part - 2) {
                    CommitEdit()
                    StartEdit(part - 2)
                }
            } else {
                CommitEdit()
                if (part = 1 || part = 2 || part = 8) {
                    dragCh := part
                    PickDrag(tabUI[activeTab][pickEl], part, mx, my)
                } else if (part = 0) {
                    pickOpen := 0
                }
            }
            DrawRing()
            return
        }
        idx := TabHit(mx, my)
        if (idx)
            ElemPress(idx, mx)
        else
            DrawRing()
        return
    }
    if (hwnd != hRing || !hover || (mode != "ring" && mode != "ringin"))
        return
    RingAction(hover)
}

OpenTab(n) {
    global mode, activeTab, pickOpen, pickEl, pickA, listenEl, ddOpen, ddEl, ddA
    if (mode != "ring" && mode != "ringin")
        return
    pickOpen := 0
    pickEl := 0
    pickA := 0
    ddOpen := 0
    ddEl := 0
    ddA := 0
    listenEl := 0
    activeTab := n
    mode := "tabin"
}

CloseTab() {
    global mode, pickOpen, listenEl, dragCh
    if (mode != "tab" && mode != "tabin")
        return
    CommitEdit()
    StopInput(true)
    pickOpen := 0
    listenEl := 0
    dragCh := 0
    mode := "ringin"
}

RingAction(n) {
    global EUI_RingHandler
    OpenTab(n)
    if (IsObject(EUI_RingHandler))
        EUI_RingHandler.Call(n)
}

HitTest(mx, my) {
    global RX, RY, RSIZE, OUTER_R, HOLE_R, EXPAND, PENT_R, PENT_EXP, anim, mode, TAB_W, TAB_H
    dx := mx - (RX + RSIZE / 2)
    dy := my - (RY + RSIZE / 2)
    d := Sqrt(dx * dx + dy * dy)

    if (mode = "tab" || mode = "tabin") {
        lx := mx - RX
        ly := my - RY
        if (lx >= RSIZE / 2 - TAB_W / 2 && lx <= RSIZE / 2 + TAB_W / 2 && ly >= RSIZE / 2 - TAB_H / 2 && ly <= RSIZE / 2 + TAB_H / 2)
        return 8
        return 0
    }

    apo := (PENT_R + PENT_EXP * anim[6]) * 0.809017
    inside := true
    Loop, 5 {
        na := (-54 + (A_Index - 1) * 72) * 0.0174532925
        if (dx * Cos(na) + dy * Sin(na) > apo) {
            inside := false
            break
        }
    }
    if (inside)
        return 6

    if (d < HOLE_R - 6)
        return 0
    ang := DllCall("msvcrt\atan2", "Double", dy, "Double", dx, "Cdecl Double") * 57.29578
    seg := Floor(Mod(ang + 450, 360) / 72) + 1
    if (d > OUTER_R + EXPAND * anim[seg])
        return 0
return seg
}

DrawRing() {
    global hRing, rhdc, rg, RSIZE, RX, RY, OUTER_R, HOLE_R, EXPAND, LINE_W, GAP, CORNER_R, PENT_R, PENT_EXP, PENT_COR, anim, ringA, ACC, ACC_OUT, uiA, ACC_A, ringIcons
    outline := (Round(0x90 * ringA) << 24) | ACC_OUT
    c := RSIZE / 2

    DllCall("gdiplus\GdipGraphicsClear", "Ptr", rg, "UInt", 0x00000000)
    DllCall("gdiplus\GdipCreatePen1", "UInt", outline, "Float", LINE_W, "Int", 2, "Ptr*", pen)

    if (ringA > 0) {
        Loop, 2 {
            pass := A_Index
            Loop, 5 {
                i := A_Index
                t := anim[i]
                grown := (t > 0.01)
                if ((pass = 1 && grown) || (pass = 2 && !grown))
                    continue
                ro := OUTER_R + EXPAND * t
                ri := HOLE_R - 6 * t
                a0 := -90 + (i - 1) * 72 + GAP / 2
                a1 := a0 + 72 - GAP
                alpha := Round((0x80 + (0xB0 - 0x80) * t) * ringA * ACC_A)
                fillColor := (alpha << 24) | ACC

                DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
                RoundedSector(path, c, ri, ro, a0, a1, CORNER_R)
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", fillColor, "Ptr*", brush)
                DllCall("gdiplus\GdipFillPath", "Ptr", rg, "Ptr", brush, "Ptr", path)
                DllCall("gdiplus\GdipDrawPath", "Ptr", rg, "Ptr", pen, "Ptr", path)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
                DllCall("gdiplus\GdipDeletePath", "Ptr", path)
                ang := (a0 + a1) / 2 * 0.0174532925
                mid := (ri + ro) / 2
                DrawIcon(ringIcons[i], c + mid * Cos(ang), c + mid * Sin(ang), 30 + 5 * t, (Round(0xF0 * ringA) << 24) | 0xFFFFFF)
            }
        }
        t := anim[6]
        alpha := Round((0x80 + (0xB0 - 0x80) * t) * ringA * ACC_A)
        fillColor := (alpha << 24) | ACC
        DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
        RoundedPentagon(path, c, PENT_R + PENT_EXP * t, PENT_COR)
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", fillColor, "Ptr*", brush)
        DllCall("gdiplus\GdipFillPath", "Ptr", rg, "Ptr", brush, "Ptr", path)
        DllCall("gdiplus\GdipDrawPath", "Ptr", rg, "Ptr", pen, "Ptr", path)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
        DllCall("gdiplus\GdipDeletePath", "Ptr", path)
        DrawIcon(ringIcons[6], c, c, 40 + 6 * t, (Round(0xF0 * ringA) << 24) | 0xFFFFFF)

    }
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)

    DrawTab(c)

    VarSetCapacity(ptDst, 8)
    NumPut(RX, ptDst, 0, "Int")
    NumPut(RY, ptDst, 4, "Int")
    VarSetCapacity(sz, 8)
    NumPut(RSIZE, sz, 0, "Int")
    NumPut(RSIZE, sz, 4, "Int")
    VarSetCapacity(ptSrc, 8, 0)
    blend := (Round(255 * uiA) << 16) | 0x01000000
    DllCall("UpdateLayeredWindow", "Ptr", hRing, "Ptr", 0, "Ptr", &ptDst, "Ptr", &sz, "Ptr", rhdc, "Ptr", &ptSrc, "UInt", 0, "UInt*", blend, "UInt", 2)
}

DrawTab(c) {
    global rg, tabA, activeTab, tabTitle, tabUI, TAB_W, TAB_H, TAB_COR, TITLE_H, LINE_W, ringIcons
    if (tabA <= 0 || !activeTab)
        return
    x := c - TAB_W / 2
    y := c - TAB_H / 2

    FillRR(x, y, TAB_W, TAB_H, TAB_COR, Col(0x80, 0xFE0001))
    StrokeRR(x, y, TAB_W, TAB_H, TAB_COR, Col(0x90, 0xFE0002), LINE_W)

    DrawText(rg, tabTitle[activeTab], x + 28, y + 14, TAB_W - 56, TITLE_H, 28, Col(0xFF, 0xFFFFFF), 0, 1)
    Ln(x + 28, y + 70, x + TAB_W - 28, y + 70, Col(0x70, 0xFE0002), 1.5)

    for idx, el in tabUI[activeTab] {
        DrawEl(el, idx)
    }
    DrawPicker()
    DrawDropdownList()
}

DrawEl(el, idx) {
    global rg, listenEl, ACC_DEEP, inputEl, blinkOn, ddEl, ddOpen
    t := el.type
    x := el.x
    y := el.y
    w := el.w
    h := el.h
    hv := el.anim
    white := Col(0xFF, 0xFFFFFF)

    if (t = "header") {
        DrawText(rg, el.label, x, y, w, h, 13, Col(0xC0, 0xFFFFFF), 0, 1, 1)

    } else if (t = "label") {
        DrawText(rg, el.label, x, y, w, h, 16, Col(0xD8, 0xFFFFFF), 0, 1)

    } else if (t = "divider") {
        Ln(x, y + h / 2, x + w, y + h / 2, Col(0x70, 0xFE0002), 1.5)

    } else if (t = "toggle") {
        bs := 24
        by := y + (h - bs) / 2
        k := el.knob
        s1 := el.sa[1]
        FillRR(x, by, bs, bs, 7, Col(0x30 + 0x20 * s1 + 0xA0 * k, 0xFFFFFF))
        StrokeRR(x, by, bs, bs, 7, Col(0x90 + 0x4F * s1, 0xFE0002), 1.5)
        if (k > 0.02)
            DrawCheck(x, by, bs, Col(0xFF * k, 0xFE0003))
        io := RowIcon(el, x + 38, y + h / 2)
        DrawText(rg, el.label, x + 38 + io, y, ChipsLeft(el) - 8 - (x + 38 + io), h, 17, white, 0, 1)
        if (el.color != "") {
            ChipRect(el, 2, cx, cy, cw, ch)
            DrawColorChip(cx, cy, cw, ch, el.color, el.sa[2], el.alpha)
        }
        if (el.bind != "") {
            ChipRect(el, 3, cx, cy, cw, ch)
            DrawBindChip(cx, cy, cw, ch, el.bind, el.sa[3], el.flash, listenEl = idx)
        }

    } else if (t = "color") {
        ChipRect(el, 2, cx, cy, cw, ch)
        ctxt := Format("#{:06X}", el.color)
        if (el.alpha < 100)
            ctxt := ctxt . " " . Round(el.alpha) . "%"
        io := RowIcon(el, x, y + h / 2)
        DrawText(rg, el.label, x + io, y, cx - x - 130 - io, h, 17, white, 0, 1)
        DrawText(rg, ctxt, cx - 130, y, 120, h, 14, Col(0xB0, 0xFFFFFF), 2, 1)
        DrawColorChip(cx, cy, cw, ch, el.color, el.sa[2], el.alpha)

    } else if (t = "dropdown") {
        DdRect(el, bx, by, bw, bh)
        isOpen := (ddEl = idx && ddOpen)
        DrawText(rg, el.label, x, y, bx - x - 10, h, 17, white, 0, 1)
        FillRR(bx, by, bw, bh, 8, Col(isOpen ? 0x58 : (0x30 + 0x18 * hv), 0xFFFFFF))
        StrokeRR(bx, by, bw, bh, 8, Col(isOpen ? 0xFF : 0x90, 0xFE0002), isOpen ? 2 : 1.5)
        DrawText(rg, el.items[el.value], bx + 12, by, bw - 44, bh, 15, Col(0xFF, 0xFFFFFF), 0, 1)
        DrawChevron(bx + bw - 18, by + bh / 2, isOpen, Col(0xE0, 0xFFFFFF))

    } else if (t = "input") {
        InputRect(el, bx, by, bw, bh)
        act := (inputEl = idx)
        io := RowIcon(el, x, y + h / 2)
        DrawText(rg, el.label, x + io, y, bx - x - 10 - io, h, 17, white, 0, 1)
        FillRR(bx, by, bw, bh, 8, Col(act ? 0x58 : (0x30 + 0x18 * hv), 0xFFFFFF))
        StrokeRR(bx, by, bw, bh, 8, Col(act ? 0xFF : 0x90, 0xFE0002), act ? 2 : 1.5)
        DrawInputText(el, act, bx, by, bw, bh)

    } else if (t = "keybind") {
        ChipRect(el, 3, cx, cy, cw, ch)
        io := RowIcon(el, x, y + h / 2)
        DrawText(rg, el.label, x + io, y, cx - x - 10 - io, h, 17, white, 0, 1)
        DrawBindChip(cx, cy, cw, ch, el.bind, el.sa[3], el.flash, listenEl = idx)

    } else if (t = "slider") {
        io := RowIcon(el, x, y + 14)
        DrawText(rg, el.label, x + io, y, w - 90 - io, 28, 17, white, 0, 1)
        DrawText(rg, SliderText(el), x + w - 90, y, 90, 28, 16, Col(0xE0, 0xFFFFFF), 2, 1)
        ty := y + 28 + (h - 28) / 2
        tx0 := x + 10
        tx1 := x + w - 10
        px := tx0 + (tx1 - tx0) * (el.value - el.lo) / (el.hi - el.lo)
        FillRR(tx0, ty - 3, tx1 - tx0, 6, 3, Col(0x38, 0xFFFFFF))
        fw := px - tx0
        if (fw > 1)
            FillRR(tx0, ty - 3, fw, 6, Min(3, fw / 2), Col(0xE0, 0xFFFFFF))
        r := 9 + 3 * hv
        FillCircle(px, ty, r, white)
        StrokeCircle(px, ty, r, Col(0xB0, 0xFE0001), 2)

    } else if (t = "button") {
        DrawButton(x, y + 4, w, h - 8, el.label, hv, el.flash, el.icon)

    } else if (t = "buttons") {
        n := el.items.MaxIndex()
        gap := 10
        iw := (w - gap * (n - 1)) / n
        Loop, % n {
            i := A_Index
            DrawButton(x + (i - 1) * (iw + gap), y + 4, iw, h - 8, el.items[i], el.sa[i], el.sf[i])
        }

    } else if (t = "segment") {
        n := el.items.MaxIndex()
        by := y + 4
        bh := h - 8
        iw := w / n
        FillRR(x, by, w, bh, bh / 2, Col(0x28, 0xFFFFFF))
        StrokeRR(x, by, w, bh, bh / 2, Col(0x90, 0xFE0002), 1.5)
        Loop, % n {
            i := A_Index
            sf := el.sf[i]
            sa := el.sa[i]
            ix := x + (i - 1) * iw
            a := Round(0xD8 * sf + 0x38 * sa * (1 - sf))
            if (a > 0)
                FillRR(ix + 3, by + 3, iw - 6, bh - 6, (bh - 6) / 2, Col(a, 0xFFFFFF))
            DrawText(rg, el.items[i], ix, by, iw, bh, 16, Col(0xFF, LerpRGB(0xFFFFFF, ACC_DEEP, sf)), 1, 1)
        }
    }
}

IconData(name) {
    static icons
    global EUI_UserIcons
    if (IsObject(EUI_UserIcons) && EUI_UserIcons.HasKey(name))
        return EUI_UserIcons[name]
    if (!IsObject(icons)) {
        icons := {}
        for bi, block in LucideIcons() {
            for li, line in StrSplit(block, "`n", "`r") {
                eq := InStr(line, "=")
                if (!eq)
                    continue
                arr := []
                for ti, tok in StrSplit(SubStr(line, eq + 1), " ") {
                    if (tok = "")
                        continue
                    if (tok = "M")
                        arr.Push(0)
                    else if (tok = "L")
                        arr.Push(1)
                    else if (tok = "C")
                        arr.Push(2)
                    else if (tok = "Z")
                        arr.Push(3)
                    else
                        arr.Push(tok + 0)
                }
                icons[SubStr(line, 1, eq - 1)] := arr
            }
        }
    }
return icons[name]
}

DrawIcon(name, cx, cy, size, argb) {
    global rg
    d := IconData(name)
    if (!IsObject(d))
        return
    k := size / 24
    n := d.MaxIndex()
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    i := 1
    px := 0
    py := 0
    while (i <= n) {
        op := d[i]
        if (op = 0) {
            px := cx + (d[i + 1] - 12) * k
            py := cy + (d[i + 2] - 12) * k
            DllCall("gdiplus\GdipStartPathFigure", "Ptr", path)
            i += 3
        } else if (op = 1) {
            nx := cx + (d[i + 1] - 12) * k
            ny := cy + (d[i + 2] - 12) * k
            if (Abs(nx - px) + Abs(ny - py) < 0.05 * k)
                DllCall("gdiplus\GdipAddPathEllipse", "Ptr", path, "Float", px - 0.1 * k, "Float", py - 0.1 * k, "Float", 0.2 * k, "Float", 0.2 * k)
            else
                DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", px, "Float", py, "Float", nx, "Float", ny)
            px := nx
            py := ny
            i += 3
        } else if (op = 2) {
            x1 := cx + (d[i + 1] - 12) * k
            y1 := cy + (d[i + 2] - 12) * k
            x2 := cx + (d[i + 3] - 12) * k
            y2 := cy + (d[i + 4] - 12) * k
            x3 := cx + (d[i + 5] - 12) * k
            y3 := cy + (d[i + 6] - 12) * k
            DllCall("gdiplus\GdipAddPathBezier", "Ptr", path, "Float", px, "Float", py, "Float", x1, "Float", y1, "Float", x2, "Float", y2, "Float", x3, "Float", y3)
            px := x3
            py := y3
            i += 7
        } else {
            DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
            i += 1
        }
    }
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", 2 * k, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipSetPenStartCap", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenEndCap", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipDrawPath", "Ptr", rg, "Ptr", pen, "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

RowIcon(el, x, cy) {
    if (el.icon = "" || !IsObject(IconData(el.icon)))
        return 0
    DrawIcon(el.icon, x + 11, cy, 22, Col(0xE0, 0xFFFFFF))
return 30
}

DrawButton(x, y, w, h, text, f, fl, icon := "") {
    global rg
    FillRR(x, y, w, h, 12, Col(0x30 + 0x30 * f + 0x60 * fl, 0xFFFFFF))
    StrokeRR(x, y, w, h, 12, Col(0x90, 0xFE0002), 1.5)
    DrawText(rg, text, x, y, w, h, 17, Col(0xFF, 0xFFFFFF), 1, 1)
    if (icon != "")
        DrawIcon(icon, x + 26, y + h / 2, 24, Col(0xE0, 0xFFFFFF))
}

DrawColorChip(cx, cy, cw, ch, rgb, hv, alpha) {
    DrawChecker(cx, cy, cw, ch, 8)
    FillRR(cx, cy, cw, ch, 8, Col(Round(0xF4 * alpha / 100), rgb))
    StrokeRR(cx, cy, cw, ch, 8, Col(0xA0 + 0x5F * hv, 0xFFFFFF), 1.5 + hv)
}

DrawChecker(x, y, w, h, r) {
    global rg
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    RoundedRect(path, x, y, w, h, Min(r, w / 2, h / 2))
    DllCall("gdiplus\GdipSetClipPath", "Ptr", rg, "Ptr", path, "Int", 0)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", Col(0xFF, 0xE8E8E8), "Ptr*", b1)
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", Col(0xFF, 0x9A9A9A), "Ptr*", b2)
    DllCall("gdiplus\GdipFillRectangle", "Ptr", rg, "Ptr", b1, "Float", x, "Float", y, "Float", w, "Float", h)
    sq := 6
    rows := Ceil(h / sq)
    cols := Ceil(w / sq)
    Loop, % rows {
        ry := A_Index - 1
        Loop, % cols {
            rc := A_Index - 1
            if (Mod(ry + rc, 2) = 1)
                DllCall("gdiplus\GdipFillRectangle", "Ptr", rg, "Ptr", b2, "Float", x + rc * sq, "Float", y + ry * sq, "Float", sq, "Float", sq)
        }
    }
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", b1)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", b2)
    DllCall("gdiplus\GdipResetClip", "Ptr", rg)
}

DrawBindChip(cx, cy, cw, ch, name, hv, fl, listening) {
    global rg
    a := 0x28 + 0x28 * hv + 0x70 * fl
    if (listening)
        a := 0x70
    FillRR(cx, cy, cw, ch, 8, Col(a, 0xFFFFFF))
    StrokeRR(cx, cy, cw, ch, 8, Col(listening ? 0xFF : 0x90, 0xFE0002), 1.5)
    txt := listening ? "..." : name
    ta := (!listening && name = "None") ? 0xA0 : 0xFF
    DrawText(rg, txt, cx, cy, cw, ch, 13, Col(ta, 0xFFFFFF), 1, 1)
}

DrawCheck(bx, by, bs, argb) {
    global rg
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", 2.6, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenStartCap", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenEndCap", "Ptr", pen, "Int", 2)
    VarSetCapacity(pts, 24, 0)
    NumPut(bx + bs * 0.26, pts, 0, "Float")
    NumPut(by + bs * 0.52, pts, 4, "Float")
    NumPut(bx + bs * 0.44, pts, 8, "Float")
    NumPut(by + bs * 0.70, pts, 12, "Float")
    NumPut(bx + bs * 0.76, pts, 16, "Float")
    NumPut(by + bs * 0.32, pts, 20, "Float")
    DllCall("gdiplus\GdipDrawLines", "Ptr", rg, "Ptr", pen, "Ptr", &pts, "Int", 3)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

DrawPicker() {
    global rg, tabUI, activeTab, pickEl, pickA, pkX, pkY, PK_W, PK_H, SQ_W, SQ_H, HB_W, colMul, pkH, pkS, pkV, editField, editText
    if (pickA <= 0 || !pickEl)
        return
    el := tabUI[activeTab][pickEl]
    colMul := pickA
    c := el.color
    al := el.alpha
    hueRGB := HSVtoRGB(pkH, 1, 1)

    FillRR(pkX, pkY, PK_W, PK_H, 18, Col(0xFC, 0xFE0004))
    StrokeRR(pkX, pkY, PK_W, PK_H, 18, Col(0xB0, 0xFE0002), 2)

    sx := pkX + 16
    sy := pkY + 16
    hx := sx + SQ_W + 12

    FillRR(sx, sy, SQ_W, SQ_H, 10, Col(0xFF, hueRGB))
    GradRR(sx, sy, SQ_W, SQ_H, 10, sx, sy, sx + SQ_W, sy, Col(0xFF, 0xFFFFFF), Col(0x00, 0xFFFFFF))
    GradRR(sx, sy, SQ_W, SQ_H, 10, sx, sy, sx, sy + SQ_H, Col(0x00, 0x000000), Col(0xFF, 0x000000))
    StrokeRR(sx, sy, SQ_W, SQ_H, 10, Col(0x90, 0xFE0002), 1.5)

    GradHue(hx, sy, HB_W, SQ_H, 10)
    StrokeRR(hx, sy, HB_W, SQ_H, 10, Col(0x90, 0xFE0002), 1.5)
    hy := sy + SQ_H * pkH / 360
    FillRR(hx - 3, hy - 5, HB_W + 6, 10, 5, Col(0xFF, hueRGB))
    StrokeRR(hx - 3, hy - 5, HB_W + 6, 10, 5, Col(0xFF, 0xFFFFFF), 2.2)

    px := sx + SQ_W * pkS
    py := sy + SQ_H * (1 - pkV)
    StrokeCircle(px, py, 9.5, Col(0x70, 0x000000), 1.5)
    StrokeCircle(px, py, 7.5, Col(0xFF, 0xFFFFFF), 2.5)
    FillCircle(px, py, 6.5, Col(0xFF, c))

    ay := sy + SQ_H + 12
    aw := SQ_W + 12 + HB_W
    DrawChecker(sx, ay, aw, 16, 8)
    GradRR(sx, ay, aw, 16, 8, sx, ay, sx + aw, ay, Col(0x00, c), Col(0xFF, c))
    StrokeRR(sx, ay, aw, 16, 8, Col(0x90, 0xFE0002), 1.5)
    ax := sx + aw * al / 100
    FillRR(ax - 5, ay - 3, 10, 22, 5, Col(0xFF, c))
    StrokeRR(ax - 5, ay - 3, 10, 22, 5, Col(0xFF, 0xFFFFFF), 2.2)

    PkRect(6, fx, fy, fw, fh)
    DrawChecker(fx, fy, fw, fh, 8)
    FillRR(fx, fy, fw, fh, 8, Col(Round(255 * al / 100), c))
    StrokeRR(fx, fy, fw, fh, 8, Col(0xC0, 0xFFFFFF), 1.5)
    DrawPickField(1, "#", Format("{:06X}", c))
    DrawPickField(2, "R", (c >> 16) & 255)
    DrawPickField(3, "G", (c >> 8) & 255)
    DrawPickField(4, "B", c & 255)
    DrawPickField(5, "A", Round(al))
    colMul := 1
}

DrawPickField(n, label, txt) {
    global rg, editField, editText, blinkOn
    PkRect(n, fx, fy, fw, fh)
    act := (editField = n)
    FillRR(fx, fy, fw, fh, 8, Col(act ? 0x58 : 0x30, 0xFFFFFF))
    StrokeRR(fx, fy, fw, fh, 8, Col(act ? 0xFF : 0x90, 0xFE0002), act ? 2 : 1.5)
    DrawText(rg, label, fx + 10, fy, 20, fh, 13, Col(0xB0, 0xFFFFFF), 0, 1, 1)
    if (act)
        txt := editText . (blinkOn ? "|" : "")
    DrawText(rg, txt, fx + 28, fy, fw - 32, fh, 15, Col(0xFF, 0xFFFFFF), 0, 1)
}

SliderText(el) {
    if (el.step >= 1)
        return Round(el.value) . el.suffix
return Round(el.value, 2) . el.suffix
}

BuildSettingsTab(toggleKey, accent) {
    UIAdd(6, {type: "header", label: "OVERLAY"})
    UIAdd(6, {type: "keybind", key: "togglekey", label: "Toggle overlay key", bind: toggleKey})
    UIAdd(6, {type: "dropdown", key: "fadespeed", label: "Fade speed", items: ["Slow", "Normal", "Fast"], value: 2})
    UIAdd(6, {type: "divider"})
    UIAdd(6, {type: "header", label: "THEME"})
    UIAdd(6, {type: "color", key: "uiaccent", label: "Accent color", color: accent})
    UIAdd(6, {type: "divider"})
    UIAdd(6, {type: "button", key: "exit", label: "Exit app"})
}

UIEvent(key, value, extra) {
    global FADE_STEP, EUI_Handler
    if (key = "uiaccent") {
        SetAccent(value)
    } else if (key = "uiaccent_alpha") {
        SetAccentAlpha(value)
    } else if (key = "fadespeed") {
        FADE_STEP := [0.1, 0.2, 0.35][value]
    } else if (key = "togglekey") {
        ToggleOverlay()
    } else if (key = "exit") {
        ExitApp
    }
    if (IsObject(EUI_Handler))
        EUI_Handler.Call(key, value, extra)
}

UIAdd(n, el) {
    global tabUI
    if (!IsObject(tabUI[n]))
        tabUI[n] := []
    tabUI[n].Push(el)
}

ElemH(t) {
    if (t = "header")
        return 32
    if (t = "label")
        return 30
    if (t = "divider")
        return 22
    if (t = "toggle" || t = "color" || t = "keybind" || t = "input" || t = "dropdown")
        return 40
    if (t = "slider")
        return 58
return 48
}

LayoutTab(n) {
    global tabUI, RSIZE, TAB_W, TAB_H
    c := RSIZE / 2
    x := c - TAB_W / 2 + 28
    w := TAB_W - 56
    y := c - TAB_H / 2 + 90
    for i, el in tabUI[n] {
        t := el.type
        el.x := x
        el.y := y
        el.w := w
        el.h := ElemH(t)
        y += el.h
        el.anim := 0
        el.flash := 0
        el.bdown := 0
        el.knob := el.value ? 1 : 0
        if (el.color != "" && el.alpha = "")
            el.alpha := 100
        if (t = "input") {
            if (el.maxlen = "")
                el.maxlen := 0
            if (el.masked = "")
                el.masked := 0
            el.scroll := 0
        }
        if (t = "dropdown" && el.value = "")
            el.value := 1
        cnt := 0
        if (IsObject(el.items))
            cnt := el.items.MaxIndex()
        else if (t = "toggle" || t = "color" || t = "keybind")
            cnt := 3
        if (cnt) {
            el.sa := []
            el.sf := []
            Loop, % cnt {
                el.sa[A_Index] := 0
                el.sf[A_Index] := (t = "segment" && el.value = A_Index) ? 1 : 0
            }
        }
    }
}

ChipRect(el, which, ByRef cx, ByRef cy, ByRef cw, ByRef ch) {
    ch := 26
    cy := el.y + (el.h - ch) / 2
    colorW := (el.type = "color") ? 56 : 44
    right := el.x + el.w
    if (which = 2) {
        cw := colorW
        cx := right - cw
    } else {
        cw := 78
        cx := (el.color != "") ? right - colorW - 8 - cw : right - cw
    }
}

ChipsLeft(el) {
    left := el.x + el.w
    if (el.color != "") {
        ChipRect(el, 2, cx, cy, cw, ch)
        left := cx
    }
    if (el.bind != "") {
        ChipRect(el, 3, cx, cy, cw, ch)
        left := cx
    }
return left
}

ColorKey(el) {
return (el.type = "toggle") ? el.key . "_color" : el.key
}

TabHit(mx, my) {
    global tabUI, activeTab, RX, RY, hoverSub
    hoverSub := 0
    if (!activeTab)
        return 0
    lx := mx - RX
    ly := my - RY
    for idx, el in tabUI[activeTab] {
        t := el.type
        if (t = "header" || t = "label" || t = "divider")
            continue
        if (lx < el.x || lx > el.x + el.w || ly < el.y || ly > el.y + el.h)
            continue
        if (t = "dropdown") {
            DdRect(el, bx, by, bw, bh)
            if (lx >= bx && lx <= bx + bw && ly >= by && ly <= by + bh) {
                hoverSub := 2
                return idx
            }
            continue
        }
        if (t = "input") {
            InputRect(el, bx, by, bw, bh)
            if (lx >= bx && lx <= bx + bw && ly >= by && ly <= by + bh) {
                hoverSub := 2
                return idx
            }
            continue
        }
        if (t = "slider")
            return idx
        if (t = "color") {
            hoverSub := 2
            return idx
        }
        if (t = "keybind") {
            hoverSub := 3
            return idx
        }
        if (t = "toggle") {
            if (el.color != "") {
                ChipRect(el, 2, cx, cy, cw, ch)
                if (lx >= cx && lx <= cx + cw && ly >= cy && ly <= cy + ch) {
                    hoverSub := 2
                    return idx
                }
            }
            if (el.bind != "") {
                ChipRect(el, 3, cx, cy, cw, ch)
                if (lx >= cx && lx <= cx + cw && ly >= cy && ly <= cy + ch) {
                    hoverSub := 3
                    return idx
                }
            }
            if (lx <= ChipsLeft(el) - 6) {
                hoverSub := 1
                return idx
            }
            continue
        }
        if (t = "button") {
            if (ly >= el.y + 4 && ly <= el.y + el.h - 4)
                return idx
        } else if (t = "buttons") {
            n := el.items.MaxIndex()
            gap := 10
            iw := (el.w - gap * (n - 1)) / n
            i := Floor((lx - el.x) / (iw + gap)) + 1
            if (i > n)
                i := n
            if (lx <= el.x + (i - 1) * (iw + gap) + iw && ly >= el.y + 4 && ly <= el.y + el.h - 4) {
                hoverSub := i
                return idx
            }
        } else if (t = "segment") {
            n := el.items.MaxIndex()
            i := Floor((lx - el.x) / (el.w / n)) + 1
            if (i > n)
                i := n
            if (ly >= el.y + 4 && ly <= el.y + el.h - 4) {
                hoverSub := i
                return idx
            }
        }
    }
return 0
}

ElemPress(idx, mx) {
    global tabUI, activeTab, hoverSub, dragEl, listenEl, ddOpen, ddEl, ddHover
    el := tabUI[activeTab][idx]
    t := el.type
    if (t = "toggle") {
        if (hoverSub = 2) {
            OpenPicker(idx)
        } else if (hoverSub = 3) {
            listenEl := idx
        } else {
            el.value := !el.value
            UIEvent(el.key, el.value, "")
        }
    } else if (t = "color") {
        OpenPicker(idx)
    } else if (t = "keybind") {
        listenEl := idx
    } else if (t = "button") {
        el.flash := 1
        UIEvent(el.key, 1, el.label)
    } else if (t = "buttons") {
        el.sf[hoverSub] := 1
        UIEvent(el.key, hoverSub, el.items[hoverSub])
    } else if (t = "segment") {
        if (el.value != hoverSub) {
            el.value := hoverSub
            UIEvent(el.key, hoverSub, el.items[hoverSub])
        }
    } else if (t = "dropdown") {
        ddEl := idx
        ddOpen := idx
        ddHover := 0
    } else if (t = "input") {
        StartInput(idx)
        InputMouse(mx, false)
    } else if (t = "slider") {
        dragEl := idx
        SliderSet(el, mx)
    }
    DrawRing()
}

OpenPicker(idx) {
    global tabUI, activeTab, pickEl, pickOpen, pkX, pkY, dragCh, PK_W, PK_H, RSIZE, TAB_W, TAB_H, pkH, pkS, pkV, editField
    el := tabUI[activeTab][idx]
    ChipRect(el, 2, cx, cy, cw, ch)
    c := RSIZE / 2
    pl := c - TAB_W / 2
    pt := c - TAB_H / 2
    pb := c + TAB_H / 2
    pkX := cx + cw - PK_W
    if (pkX < pl + 10)
        pkX := pl + 10
    pkY := cy + ch + 8
    if (pkY + PK_H > pb - 10)
        pkY := cy - 8 - PK_H
    if (pkY < pt + 10)
        pkY := pt + 10
    pickEl := idx
    pickOpen := 1
    dragCh := 0
    editField := 0
    pkH := 0
    RGBtoHSV(el.color, pkH, pkS, pkV)
}

PkRect(n, ByRef fx, ByRef fy, ByRef fw, ByRef fh) {
    global pkX, pkY, PK_W, SQ_H
    row := pkY + 16 + SQ_H + 42
    fh := 28
    if (n = 6) {
        fx := pkX + 16
        fy := row
        fw := 60
    } else if (n = 1) {
        fx := pkX + 84
        fy := row
        fw := PK_W - 16 - 84
    } else {
        iw := (PK_W - 32 - 18) / 4
        fx := pkX + 16 + (n - 2) * (iw + 6)
        fy := row + 38
        fw := iw
    }
}

PickerHit(mx, my) {
    global pkX, pkY, PK_W, PK_H, RX, RY, SQ_W, SQ_H, HB_W
    lx := mx - RX
    ly := my - RY
    if (lx < pkX || lx > pkX + PK_W || ly < pkY || ly > pkY + PK_H)
        return 0
    sx := pkX + 16
    sy := pkY + 16
    hx := sx + SQ_W + 12
    if (lx >= sx && lx <= sx + SQ_W && ly >= sy && ly <= sy + SQ_H)
        return 1
    if (lx >= hx - 4 && lx <= hx + HB_W + 4 && ly >= sy - 6 && ly <= sy + SQ_H + 6)
        return 2
    ay := sy + SQ_H + 12
    if (lx >= sx - 4 && lx <= sx + SQ_W + 12 + HB_W + 4 && ly >= ay - 5 && ly <= ay + 21)
        return 8
    Loop, 5 {
        PkRect(A_Index, fx, fy, fw, fh)
        if (lx >= fx && lx <= fx + fw && ly >= fy && ly <= fy + fh)
            return A_Index + 2
    }
return 9
}

PickDrag(el, part, mx, my) {
    global RX, RY, pkX, pkY, SQ_W, SQ_H, HB_W, pkH, pkS, pkV
    lx := mx - RX
    ly := my - RY
    if (part = 8) {
        q := (lx - (pkX + 16)) / (SQ_W + 12 + HB_W)
        q := q < 0 ? 0 : (q > 1 ? 1 : q)
        a := Round(q * 100)
        if (a = el.alpha)
            return false
        el.alpha := a
        UIEvent(el.key . "_alpha", a, "")
        return true
    }
    h0 := pkH
    s0 := pkS
    v0 := pkV
    r := (ly - (pkY + 16)) / SQ_H
    r := r < 0 ? 0 : (r > 1 ? 1 : r)
    if (part = 1) {
        q := (lx - (pkX + 16)) / SQ_W
        q := q < 0 ? 0 : (q > 1 ? 1 : q)
        pkS := q
        pkV := 1 - r
    } else {
        pkH := r * 360
    }
    nc := HSVtoRGB(pkH, pkS, pkV)
    if (nc != el.color) {
        el.color := nc
        UIEvent(ColorKey(el), nc, "")
    }
return (h0 != pkH || s0 != pkS || v0 != pkV)
}

SliderSet(el, mx) {
    global RX
    lx := mx - RX
    x0 := el.x + 10
    x1 := el.x + el.w - 10
    q := (lx - x0) / (x1 - x0)
    q := q < 0 ? 0 : (q > 1 ? 1 : q)
    v := el.lo + q * (el.hi - el.lo)
    v := el.lo + Round((v - el.lo) / el.step) * el.step
    v := v > el.hi ? el.hi : v
    if (v = el.value)
        return false
    el.value := v
    UIEvent(el.key, v, "")
return true
}

BindTick() {
    global tabUI, activeTab, listenEl, needDraw, editField, inputEl
    if (listenEl) {
        name := PollKeyCapture()
        if (name = "")
            return
        el := tabUI[activeTab][listenEl]
        listenEl := 0
        if (name = "Backspace")
            name := "None"
        el.bind := name
        el.bdown := 1
        UIEvent(el.key . "_bind", name, "")
        needDraw := true
        return
    }
    if (editField || inputEl)
        return
    for n, list in tabUI {
        for i, el in list {
            b := el.bind
            if (b = "" || b = "None")
                continue
            down := GetKeyState(b, "P") ? 1 : 0
            if (down && !el.bdown) {
                if (el.type = "toggle") {
                    el.value := !el.value
                    UIEvent(el.key, el.value, "")
                } else {
                    el.flash := 1
                    UIEvent(el.key, 1, b)
                }
            }
            el.bdown := down
        }
    }
}

PollKeyCapture() {
    Loop, 254 {
        vk := A_Index
        if (vk = 1 || vk = 0x10 || vk = 0x11 || vk = 0x12 || vk = 0x1B)
            continue
        if (DllCall("GetAsyncKeyState", "Int", vk, "Short") & 0x8000) {
            name := GetKeyName(Format("vk{:x}", vk))
            if (name != "") {
                if (StrLen(name) = 1)
                    StringUpper, name, name
                return name
            }
        }
    }
return ""
}

TweenTabUI() {
    global tabUI, activeTab, hoverEl, hoverSub, EASE
    if (!activeTab)
        return false
    changed := false
    for idx, el in tabUI[activeTab] {
        t := el.type
        nv := StepTo(el.anim, (idx = hoverEl) ? 1 : 0, EASE)
        if (nv != el.anim) {
            el.anim := nv
            changed := true
        }
        if (t = "toggle") {
            nv := StepTo(el.knob, el.value ? 1 : 0, 0.3)
            if (nv != el.knob) {
                el.knob := nv
                changed := true
            }
        }
        if ((t = "button" || t = "keybind" || t = "toggle") && el.flash > 0) {
            el.flash := (el.flash * 0.8 < 0.01) ? 0 : el.flash * 0.8
            changed := true
        }
        if (IsObject(el.sa)) {
            Loop, % el.sa.MaxIndex() {
                i := A_Index
                nv := StepTo(el.sa[i], (idx = hoverEl && hoverSub = i) ? 1 : 0, EASE)
                if (nv != el.sa[i]) {
                    el.sa[i] := nv
                    changed := true
                }
                if (t = "buttons" && el.sf[i] > 0) {
                    el.sf[i] := (el.sf[i] * 0.8 < 0.01) ? 0 : el.sf[i] * 0.8
                    changed := true
                } else if (t = "segment") {
                    nv := StepTo(el.sf[i], (el.value = i) ? 1 : 0, 0.3)
                    if (nv != el.sf[i]) {
                        el.sf[i] := nv
                        changed := true
                    }
                }
            }
        }
    }
return changed
}

StepTo(v, target, rate) {
    nv := v + (target - v) * rate
    if (Abs(nv - target) < 0.005)
        nv := target
return nv
}

LerpRGB(c1, c2, t) {
    cr := Round(((c1 >> 16) & 255) + (((c2 >> 16) & 255) - ((c1 >> 16) & 255)) * t)
    cg := Round(((c1 >> 8) & 255) + (((c2 >> 8) & 255) - ((c1 >> 8) & 255)) * t)
    cb := Round((c1 & 255) + ((c2 & 255) - (c1 & 255)) * t)
return (cr << 16) | (cg << 8) | cb
}

Col(a, rgb) {
    global tabA, colMul, ACC, ACC_OUT, ACC_DEEP, ACC_DARK, ACC_A
    if (rgb = 0xFE0001) {
        rgb := ACC
        a := a * ACC_A
    } else if (rgb = 0xFE0002)
    rgb := ACC_OUT
    else if (rgb = 0xFE0003)
        rgb := ACC_DEEP
    else if (rgb = 0xFE0004)
        rgb := ACC_DARK
    v := Round(a * tabA * colMul)
    v := v > 255 ? 255 : (v < 0 ? 0 : v)
return (v << 24) | rgb
}

FillRR(x, y, w, h, r, argb) {
    global rg
    if (w <= 0 || h <= 0)
        return
    r := Min(r, w / 2, h / 2)
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    RoundedRect(path, x, y, w, h, r)
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
    DllCall("gdiplus\GdipFillPath", "Ptr", rg, "Ptr", br, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

StrokeRR(x, y, w, h, r, argb, wd) {
    global rg
    if (w <= 0 || h <= 0)
        return
    r := Min(r, w / 2, h / 2)
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    RoundedRect(path, x, y, w, h, r)
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", wd, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipDrawPath", "Ptr", rg, "Ptr", pen, "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

FillCircle(cx, cy, r, argb) {
    global rg
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
    DllCall("gdiplus\GdipFillEllipse", "Ptr", rg, "Ptr", br, "Float", cx - r, "Float", cy - r, "Float", r * 2, "Float", r * 2)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

StrokeCircle(cx, cy, r, argb, wd) {
    global rg
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", wd, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipDrawEllipse", "Ptr", rg, "Ptr", pen, "Float", cx - r, "Float", cy - r, "Float", r * 2, "Float", r * 2)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

Ln(x1, y1, x2, y2, argb, wd) {
    global rg
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", wd, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipDrawLine", "Ptr", rg, "Ptr", pen, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

GetFont(size, style := 0) {
    static fam := 0, fonts
    if (!IsObject(fonts))
        fonts := {}
    if (!fam)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", fam)
    fk := size . "_" . style
    font := fonts[fk]
    if (!font) {
        DllCall("gdiplus\GdipCreateFont", "Ptr", fam, "Float", size, "Int", style, "Int", 2, "Ptr*", font)
        fonts[fk] := font
    }
return font
}

DrawText(g, text, x, y, w, h, size, argb, hAlign := 0, vAlign := 1, style := 0) {
    font := GetFont(size, style)
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", fmt)
    DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", fmt, "Int", hAlign)
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", vAlign)
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
    VarSetCapacity(rc, 16, 0)
    NumPut(x, rc, 0, "Float")
    NumPut(y, rc, 4, "Float")
    NumPut(w, rc, 8, "Float")
    NumPut(h, rc, 12, "Float")
    DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", text, "Int", -1, "Ptr", font, "Ptr", &rc, "Ptr", fmt, "Ptr", br)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
}

RoundedRect(path, x, y, w, h, r) {
    d := r * 2
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y + h - d, "Float", d, "Float", d, "Float", 0, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y + h - d, "Float", d, "Float", d, "Float", 90, "Float", 90)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
}

RoundedSector(path, c, ri, ro, a0, a1, cr) {
    rad := 0.0174532925
    dO := ASin(cr / (ro - cr)) / rad
    dI := ASin(cr / (ri + cr)) / rad

    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", c - ro, "Float", c - ro, "Float", ro * 2, "Float", ro * 2, "Float", a0 + dO, "Float", (a1 - a0) - 2 * dO)
    Fillet(path, c, ro - cr, a1 - dO, cr, a1 - dO, 90 + dO)
    Fillet(path, c, ri + cr, a1 - dI, cr, a1 + 90, 90 - dI)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", c - ri, "Float", c - ri, "Float", ri * 2, "Float", ri * 2, "Float", a1 - dI, "Float", -((a1 - a0) - 2 * dI))
    Fillet(path, c, ri + cr, a0 + dI, cr, a0 + dI + 180, 90 - dI)
    Fillet(path, c, ro - cr, a0 + dO, cr, a0 + 270, 90 + dO)

    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
}

RoundedPentagon(path, c, R, cr) {
    rad := 0.0174532925
    dc := R - cr / Sin(54 * rad)
    Loop, 5 {
        th := -90 + (A_Index - 1) * 72
        Fillet(path, c, dc, th, cr, th - 36, 72)
    }
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
}

Fillet(path, c, d, angDeg, cr, startAng, sweep) {
    rad := 0.0174532925
    cx := c + d * Cos(angDeg * rad)
    cy := c + d * Sin(angDeg * rad)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", cx - cr, "Float", cy - cr, "Float", cr * 2, "Float", cr * 2, "Float", startAng, "Float", sweep)
}

EnableBlur(hwnd, state := 3, color := 0x01000000) {
    VarSetCapacity(accent, 16, 0)
    NumPut(state, accent, 0, "Int")
    NumPut(state = 4 ? 2 : 0, accent, 4, "Int")
    NumPut(color, accent, 8, "UInt")
    VarSetCapacity(wca, A_PtrSize = 8 ? 24 : 12, 0)
    NumPut(19, wca, 0, "Int")
    NumPut(&accent, wca, A_PtrSize, "Ptr")
    NumPut(16, wca, A_PtrSize * 2, "UInt")
    DllCall("user32\SetWindowCompositionAttribute", "Ptr", hwnd, "Ptr", &wca)
}

SetAccent(rgb) {
    global ACC, ACC_OUT, ACC_DEEP, ACC_DARK, needDraw
    ACC := rgb
    ACC_OUT := LerpRGB(rgb, 0xFFFFFF, 0.55)
    ACC_DEEP := LerpRGB(rgb, 0x000000, 0.2)
    ACC_DARK := LerpRGB(rgb, 0x000000, 0.35)
    needDraw := true
}

SetAccentAlpha(pct) {
    global ACC_A, needDraw
    ACC_A := pct / 100
    needDraw := true
}

ToggleOverlay() {
    global visible, uiTarget
    if (visible && uiTarget)
        HideOverlay()
    else
        ShowOverlay()
}

HideOverlay() {
    global visible, uiTarget
    if (!visible || !uiTarget)
        return
    CommitEdit()
    StopInput(true)
    uiTarget := 0
}

ShowOverlay() {
    global visible, uiTarget, UIHwnd
    uiTarget := 1
    if (visible)
        return
    visible := true
    WinSet, Transparent, 0, ahk_id %UIHwnd%
    Gui, UI:Show
    Gui, Ring:Show, NA
    SetTimer, RingHover, 15
}

GradRR(x, y, w, h, r, x1, y1, x2, y2, c1, c2) {
    global rg
    r := Min(r, w / 2, h / 2)
    VarSetCapacity(p1, 8, 0)
    VarSetCapacity(p2, 8, 0)
    NumPut(x1, p1, 0, "Float")
    NumPut(y1, p1, 4, "Float")
    NumPut(x2, p2, 0, "Float")
    NumPut(y2, p2, 4, "Float")
    DllCall("gdiplus\GdipCreateLineBrush", "Ptr", &p1, "Ptr", &p2, "UInt", c1, "UInt", c2, "Int", 3, "Ptr*", lb)
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    RoundedRect(path, x, y, w, h, r)
    DllCall("gdiplus\GdipFillPath", "Ptr", rg, "Ptr", lb, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", lb)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

GradHue(x, y, w, h, r) {
    global rg
    r := Min(r, w / 2, h / 2)
    VarSetCapacity(p1, 8, 0)
    VarSetCapacity(p2, 8, 0)
    NumPut(x, p1, 0, "Float")
    NumPut(y, p1, 4, "Float")
    NumPut(x, p2, 0, "Float")
    NumPut(y + h, p2, 4, "Float")
    DllCall("gdiplus\GdipCreateLineBrush", "Ptr", &p1, "Ptr", &p2, "UInt", Col(0xFF, 0xFF0000), "UInt", Col(0xFF, 0xFF0000), "Int", 3, "Ptr*", lb)
    VarSetCapacity(cols, 28, 0)
    VarSetCapacity(pos, 28, 0)
    hues := [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000]
    Loop, 7 {
        NumPut(Col(0xFF, hues[A_Index]), cols, (A_Index - 1) * 4, "UInt")
        NumPut((A_Index - 1) / 6, pos, (A_Index - 1) * 4, "Float")
    }
    DllCall("gdiplus\GdipSetLinePresetBlend", "Ptr", lb, "Ptr", &cols, "Ptr", &pos, "Int", 7)
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    RoundedRect(path, x, y, w, h, r)
    DllCall("gdiplus\GdipFillPath", "Ptr", rg, "Ptr", lb, "Ptr", path)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", lb)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

HSVtoRGB(h, s, v) {
    c := v * s
    hh := Mod(h, 360) / 60
    x := c * (1 - Abs(Mod(hh, 2) - 1))
    m := v - c
    i := Floor(hh)
    if (i = 0) {
        r := c
        g := x
        b := 0
    } else if (i = 1) {
        r := x
        g := c
        b := 0
    } else if (i = 2) {
        r := 0
        g := c
        b := x
    } else if (i = 3) {
        r := 0
        g := x
        b := c
    } else if (i = 4) {
        r := x
        g := 0
        b := c
    } else {
        r := c
        g := 0
        b := x
    }
return (Round((r + m) * 255) << 16) | (Round((g + m) * 255) << 8) | Round((b + m) * 255)
}

RGBtoHSV(c, ByRef h, ByRef s, ByRef v) {
    r := (c >> 16) & 255
    g := (c >> 8) & 255
    b := c & 255
    mxv := Max(r, g, b)
    mnv := Min(r, g, b)
    d := mxv - mnv
    v := mxv / 255
    s := (mxv = 0) ? 0 : d / mxv
    if (d = 0)
        return
    if (mxv = r) {
        h := 60 * Mod((g - b) / d, 6)
    } else if (mxv = g) {
        h := 60 * ((b - r) / d + 2)
    } else {
        h := 60 * ((r - g) / d + 4)
    }
    if (h < 0)
        h += 360
}

SetPickColor(el, nc) {
    global pkH, pkS, pkV
    if (nc = el.color)
        return
    el.color := nc
    RGBtoHSV(nc, pkH, pkS, pkV)
    UIEvent(ColorKey(el), nc, "")
}

SetPickAlpha(el, a) {
    if (a = el.alpha)
        return
    el.alpha := a
    UIEvent(el.key . "_alpha", a, "")
}

DdRect(el, ByRef bx, ByRef by, ByRef bw, ByRef bh) {
    bw := 200
    bh := 30
    bx := el.x + el.w - bw
    by := el.y + (el.h - bh) / 2
}

DdList(el, ByRef lx, ByRef ly, ByRef lw, ByRef lh) {
    global RSIZE, TAB_H
    DdRect(el, bx, by, bw, bh)
    lw := bw
    lh := el.items.MaxIndex() * 30 + 8
    lx := bx
    ly := by + bh + 4
    if (ly + lh > RSIZE / 2 + TAB_H / 2 - 10)
    ly := by - 4 - lh
    if (ly < RSIZE / 2 - TAB_H / 2 + 10)
    ly := RSIZE / 2 - TAB_H / 2 + 10
}

DdHit(mx, my) {
    global tabUI, activeTab, ddEl, RX, RY
    if (!ddEl)
        return 0
    el := tabUI[activeTab][ddEl]
    DdList(el, lx, ly, lw, lh)
    px := mx - RX
    py := my - RY
    if (px < lx + 4 || px > lx + lw - 4 || py < ly + 4 || py > ly + lh - 4)
        return 0
    i := Floor((py - ly - 4) / 30) + 1
return (i >= 1 && i <= el.items.MaxIndex()) ? i : 0
}

DrawDropdownList() {
    global rg, tabUI, activeTab, ddEl, ddA, ddHover, colMul
    if (ddA <= 0 || !ddEl)
        return
    el := tabUI[activeTab][ddEl]
    DdList(el, lx, ly, lw, lh)
    colMul := ddA
    FillRR(lx, ly, lw, lh, 12, Col(0xFC, 0xFE0004))
    StrokeRR(lx, ly, lw, lh, 12, Col(0xB0, 0xFE0002), 2)
    Loop, % el.items.MaxIndex() {
        ry := ly + 4 + (A_Index - 1) * 30
        if (A_Index = ddHover)
            FillRR(lx + 4, ry, lw - 8, 30, 8, Col(0x50, 0xFFFFFF))
        else if (A_Index = el.value)
            FillRR(lx + 4, ry, lw - 8, 30, 8, Col(0x28, 0xFFFFFF))
        DrawText(rg, el.items[A_Index], lx + 14, ry, lw - 28, 30, 16, Col(0xFF, 0xFFFFFF), 0, 1, (A_Index = el.value) ? 1 : 0)
    }
    colMul := 1
}

DrawChevron(cx, cy, up, argb) {
    global rg
    sg := up ? -1 : 1
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", 2, "Int", 2, "Ptr*", pen)
    DllCall("gdiplus\GdipSetPenStartCap", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenEndCap", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipSetPenLineJoin", "Ptr", pen, "Int", 2)
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", path)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", cx - 5, "Float", cy - 2.5 * sg, "Float", cx, "Float", cy + 2.5 * sg)
    DllCall("gdiplus\GdipAddPathLine", "Ptr", path, "Float", cx, "Float", cy + 2.5 * sg, "Float", cx + 5, "Float", cy - 2.5 * sg)
    DllCall("gdiplus\GdipDrawPath", "Ptr", rg, "Ptr", pen, "Ptr", path)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

InputRect(el, ByRef bx, ByRef by, ByRef bw, ByRef bh) {
    bw := 260
    bh := 30
    bx := el.x + el.w - bw
    by := el.y + (el.h - bh) / 2
}

InputDisplay(el) {
    s := el.value
    if (!el.masked)
        return s
    n := StrLen(s)
    s := ""
    Loop, % n
        s .= Chr(0x2022)
return s
}

FindEl(key) {
    global tabUI
    for n, list in tabUI {
        for i, el in list {
            if (el.key = key)
                return el
        }
    }
return ""
}

StartInput(idx) {
    global tabUI, activeTab, inputEl, inputOrig, inHook, blinkOn, listenEl, needDraw, inputCaret, inputAnchor, inputDrag
    CommitEdit()
    el := tabUI[activeTab][idx]
    inputEl := idx
    inputOrig := el.value
    inputCaret := StrLen(el.value)
    inputAnchor := inputCaret
    inputDrag := 0
    listenEl := 0
    blinkOn := 1
    inHook := InputHook("B", "{Enter}{Tab}")
    inHook.OnChar := Func("InputOnChar")
    inHook.OnEnd := Func("InputOnEnd")
    inHook.Start()
    needDraw := true
}

StopInput(commit := true) {
    global tabUI, activeTab, inputEl, inputOrig, inHook, needDraw, inputDrag
    if (!inputEl)
        return
    idx := inputEl
    inputEl := 0
    inputDrag := 0
    if (IsObject(inHook))
        inHook.Stop()
    inHook := ""
    el := tabUI[activeTab][idx]
    if (commit)
        UIEvent(el.key, el.value, "")
    else
        el.value := inputOrig
    needDraw := true
}

InputOnChar(ih, ch) {
    global inputEl
    if (!inputEl)
        return
    if (Ord(ch) < 32 || Ord(ch) = 127)
        return
    InputInsert(ch)
}

InputOnEnd(ih) {
    global inputEl
    if (!inputEl)
        return
    StopInput(true)
}

InputInsert(text) {
    global tabUI, activeTab, inputEl, inputCaret, inputAnchor, needDraw, blinkOn
    if (!inputEl)
        return
    el := tabUI[activeTab][inputEl]
    a := Min(inputCaret, inputAnchor)
    b := Max(inputCaret, inputAnchor)
    v := el.value
    if (el.maxlen > 0) {
        room := el.maxlen - (StrLen(v) - (b - a))
        if (room <= 0)
            return
        text := SubStr(text, 1, room)
    }
    el.value := SubStr(v, 1, a) . text . SubStr(v, b + 1)
    inputCaret := a + StrLen(text)
    inputAnchor := inputCaret
    blinkOn := 1
    needDraw := true
}

InputPaste() {
    InputInsert(RegExReplace(Clipboard, "[\r\n\t]+", " "))
}

InputWord(s, pos, dir) {
    n := StrLen(s)
    if (dir < 0) {
        while (pos > 0 && SubStr(s, pos, 1) = " ")
            pos -= 1
        while (pos > 0 && SubStr(s, pos, 1) != " ")
            pos -= 1
    } else {
        while (pos < n && SubStr(s, pos + 1, 1) != " ")
            pos += 1
        while (pos < n && SubStr(s, pos + 1, 1) = " ")
            pos += 1
    }
return pos
}

InputKey(k) {
    global tabUI, activeTab, inputEl, inputCaret, inputAnchor, needDraw, blinkOn
    if (!inputEl)
        return
    el := tabUI[activeTab][inputEl]
    s := el.value
    n := StrLen(s)
    sh := GetKeyState("Shift", "P")
    ct := GetKeyState("Ctrl", "P")
    a := Min(inputCaret, inputAnchor)
    b := Max(inputCaret, inputAnchor)
    if (k = "Left" || k = "Right" || k = "Home" || k = "End") {
        if (k = "Left")
            pos := (a != b && !sh) ? a : (ct ? InputWord(s, inputCaret, -1) : inputCaret - 1)
        else if (k = "Right")
            pos := (a != b && !sh) ? b : (ct ? InputWord(s, inputCaret, 1) : inputCaret + 1)
        else if (k = "Home")
            pos := 0
        else
            pos := n
        inputCaret := pos < 0 ? 0 : (pos > n ? n : pos)
        if (!sh)
            inputAnchor := inputCaret
    } else if (k = "Backspace" || k = "Delete") {
        if (a = b) {
            if (k = "Backspace")
                a := ct ? InputWord(s, a, -1) : a - 1
            else
                b := ct ? InputWord(s, b, 1) : b + 1
            a := a < 0 ? 0 : a
            b := b > n ? n : b
        }
        el.value := SubStr(s, 1, a) . SubStr(s, b + 1)
        inputCaret := a
        inputAnchor := a
    } else if (k = "a") {
        inputAnchor := 0
        inputCaret := n
    } else if (k = "c" || k = "x") {
        if (a != b)
            Clipboard := SubStr(s, a + 1, b - a)
        if (k = "x" && a != b) {
            el.value := SubStr(s, 1, a) . SubStr(s, b + 1)
            inputCaret := a
            inputAnchor := a
        }
    }
    blinkOn := 1
    needDraw := true
}

InputMouse(mx, dbl) {
    global tabUI, activeTab, inputEl, inputCaret, inputAnchor, inputDrag, needDraw, blinkOn, RX
    if (!inputEl)
        return
    el := tabUI[activeTab][inputEl]
    if (dbl) {
        inputAnchor := 0
        inputCaret := StrLen(el.value)
    } else {
        InputRect(el, bx, by, bw, bh)
        inputCaret := InputIndexAt(el, mx - RX - (bx + 10) + el.scroll)
        if (!GetKeyState("Shift", "P"))
            inputAnchor := inputCaret
        inputDrag := 1
    }
    blinkOn := 1
    needDraw := true
}

InputDragTo(mx) {
    global tabUI, activeTab, inputEl, inputCaret, RX
    if (!inputEl)
        return false
    el := tabUI[activeTab][inputEl]
    InputRect(el, bx, by, bw, bh)
    c := InputIndexAt(el, mx - RX - (bx + 10) + el.scroll)
    if (c = inputCaret)
        return false
    inputCaret := c
return true
}

InputIndexAt(el, px) {
    s := InputDisplay(el)
    n := StrLen(s)
    if (px <= 0 || n = 0)
        return 0
    lo := 0
    hi := n
    while (lo < hi) {
        mid := (lo + hi) // 2
        if (InputTextW(SubStr(s, 1, mid)) < px)
            lo := mid + 1
        else
            hi := mid
    }
    if (lo > 0) {
        if (px - InputTextW(SubStr(s, 1, lo - 1)) < InputTextW(SubStr(s, 1, lo)) - px)
            lo -= 1
    }
return lo
}

InputFmt() {
    static fmt := 0
    if (!fmt) {
        DllCall("gdiplus\GdipStringFormatGetGenericTypographic", "Ptr*", tf)
        if (tf)
            DllCall("gdiplus\GdipCloneStringFormat", "Ptr", tf, "Ptr*", fmt)
        if (!fmt)
            DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", fmt)
        DllCall("gdiplus\GdipSetStringFormatFlags", "Ptr", fmt, "Int", 0x7804)
    }
return fmt
}

InputTextW(s) {
    global rg
    if (s = "")
        return 0
    VarSetCapacity(rc, 16, 0)
    NumPut(100000, rc, 8, "Float")
    NumPut(100000, rc, 12, "Float")
    VarSetCapacity(bb, 16, 0)
    DllCall("gdiplus\GdipMeasureString", "Ptr", rg, "WStr", s, "Int", -1, "Ptr", GetFont(15), "Ptr", &rc, "Ptr", InputFmt(), "Ptr", &bb, "Ptr", 0, "Ptr", 0)
return NumGet(bb, 8, "Float")
}

InputLineH() {
    static lh := 0
    global rg
    if (!lh) {
        VarSetCapacity(rc, 16, 0)
        NumPut(100000, rc, 8, "Float")
        NumPut(100000, rc, 12, "Float")
        VarSetCapacity(bb, 16, 0)
        DllCall("gdiplus\GdipMeasureString", "Ptr", rg, "WStr", "Ag", "Int", -1, "Ptr", GetFont(15), "Ptr", &rc, "Ptr", InputFmt(), "Ptr", &bb, "Ptr", 0, "Ptr", 0)
        lh := NumGet(bb, 12, "Float")
    }
return lh
}

InputDrawStr(s, x, by, bh, argb) {
    global rg
    lh := InputLineH()
    VarSetCapacity(rc, 16, 0)
    NumPut(x, rc, 0, "Float")
    NumPut(by + (bh - lh) / 2, rc, 4, "Float")
    NumPut(100000, rc, 8, "Float")
    NumPut(lh + 4, rc, 12, "Float")
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", br)
    DllCall("gdiplus\GdipDrawString", "Ptr", rg, "WStr", s, "Int", -1, "Ptr", GetFont(15), "Ptr", &rc, "Ptr", InputFmt(), "Ptr", br)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

DrawInputText(el, act, bx, by, bw, bh) {
    global rg, inputCaret, inputAnchor, blinkOn
    s := InputDisplay(el)
    vis := bw - 20
    if (s = "" && !act) {
        DrawText(rg, "Click to type...", bx + 10, by, vis, bh, 15, Col(0x70, 0xFFFFFF), 0, 1)
        return
    }
    sc := 0
    if (act) {
        sc := el.scroll
        caretX := InputTextW(SubStr(s, 1, inputCaret))
        if (caretX - sc > vis)
            sc := caretX - vis
        if (caretX - sc < 0)
            sc := caretX
        if (InputTextW(s) - sc < vis)
            sc := InputTextW(s) - vis
        sc := sc < 0 ? 0 : sc
    }
    el.scroll := sc
    x0 := bx + 10 - sc
    DllCall("gdiplus\GdipSetClipRect", "Ptr", rg, "Float", bx + 8, "Float", by + 2, "Float", bw - 16, "Float", bh - 4, "Int", 0)
    if (act && inputCaret != inputAnchor) {
        a := Min(inputCaret, inputAnchor)
        b := Max(inputCaret, inputAnchor)
        xa := x0 + InputTextW(SubStr(s, 1, a))
        xb := x0 + InputTextW(SubStr(s, 1, b))
        FillRR(xa, by + 5, xb - xa, bh - 10, 3, Col(0xB0, 0x4DA6FF))
    }
    if (s != "")
        InputDrawStr(s, x0, by, bh, Col(0xFF, 0xFFFFFF))
    if (act && blinkOn)
        FillRR(x0 + InputTextW(SubStr(s, 1, inputCaret)) - 0.75, by + 6, 1.5, bh - 12, 0.75, Col(0xFF, 0xFFFFFF))
    DllCall("gdiplus\GdipResetClip", "Ptr", rg)
}

StartEdit(n) {
    global tabUI, activeTab, pickEl, editField, editText, editFresh, editOrig, editOrigA, blinkOn, listenEl
    if (!pickEl)
        return
    c := tabUI[activeTab][pickEl].color
    editOrig := c
    editOrigA := tabUI[activeTab][pickEl].alpha
    if (n = 1)
        editText := Format("{:06X}", c)
    else if (n = 2)
        editText := (c >> 16) & 255
    else if (n = 3)
        editText := (c >> 8) & 255
    else if (n = 4)
        editText := c & 255
    else
        editText := Round(editOrigA)
    editField := n
    editFresh := 1
    blinkOn := 1
    listenEl := 0
}

ApplyEdit(commit) {
    global tabUI, activeTab, pickEl, editField, editText, needDraw
    if (!editField || !pickEl)
        return
    el := tabUI[activeTab][pickEl]
    c := el.color
    if (editField = 5) {
        if (editText = "")
            return
        a := editText + 0
        a := a > 100 ? 100 : a
        SetPickAlpha(el, a)
        needDraw := true
        return
    }
    if (editField = 1) {
        t := editText
        if (commit && StrLen(t) = 3)
            t := SubStr(t, 1, 1) . SubStr(t, 1, 1) . SubStr(t, 2, 1) . SubStr(t, 2, 1) . SubStr(t, 3, 1) . SubStr(t, 3, 1)
        if (StrLen(t) != 6)
            return
        nc := ("0x" . t) + 0
    } else {
        if (editText = "")
            return
        v := editText + 0
        v := v > 255 ? 255 : v
        cr := (c >> 16) & 255
        cg := (c >> 8) & 255
        cb := c & 255
        if (editField = 2)
            cr := v
        else if (editField = 3)
            cg := v
        else
            cb := v
        nc := (cr << 16) | (cg << 8) | cb
    }
    SetPickColor(el, nc)
    needDraw := true
}

CommitEdit() {
    global editField, needDraw
    if (!editField)
        return
    ApplyEdit(true)
    editField := 0
    needDraw := true
}

CancelEdit() {
    global tabUI, activeTab, pickEl, editField, editOrig, editOrigA, needDraw
    if (!editField)
        return
    if (pickEl) {
        SetPickColor(tabUI[activeTab][pickEl], editOrig)
        SetPickAlpha(tabUI[activeTab][pickEl], editOrigA)
    }
    editField := 0
    needDraw := true
}

EditNext() {
    global editField
    if (!editField)
        return
    n := Mod(editField, 5) + 1
    CommitEdit()
    StartEdit(n)
}

EditKey(k) {
    global editField, editText, editFresh
    if (!editField)
        return
    if (editField != 1 && !RegExMatch(k, "^\d$"))
        return
    if (editFresh) {
        editText := ""
        editFresh := 0
    }
    maxLen := (editField = 1) ? 6 : 3
    if (StrLen(editText) >= maxLen)
        return
    StringUpper, k, k
    editText := editText . k
    ApplyEdit(false)
}

EditBack() {
    global editField, editText, editFresh
    if (!editField)
        return
    if (editFresh) {
        editText := ""
        editFresh := 0
    } else {
        editText := SubStr(editText, 1, -1)
    }
    ApplyEdit(false)
}

EditPaste() {
    global editField, editText, editFresh
    if (!editField)
        return
    t := RegExReplace(Trim(Clipboard), "^#")
    if (editField = 1) {
        if (!RegExMatch(t, "^[0-9A-Fa-f]{6}$"))
            return
    } else if (!RegExMatch(t, "^\d{1,3}$")) {
        return
    }
    StringUpper, t, t
    editText := t
    editFresh := 0
    ApplyEdit(false)
}

LucideIcons() {
    b1 := "
    (LTrim
    sliders-horizontal=M 10 5 L 3 5 M 12 19 L 3 19 M 14 3 L 14 7 M 16 17 L 16 21 M 21 12 L 12 12 M 21 19 L 16 19 M 21 5 L 14 5 M 8 10 L 8 14 M 8 12 L 3 12
    mouse-pointer-click=M 14 4.1 L 12 6 M 5.1 8 L 2.2 7.2 M 6 12 L 4.1 14 M 7.2 2.2 L 8 5.1 M 9.04 9.69 C 9 9.6 8.99 9.5 9.01 9.4 C 9.03 9.3 9.07 9.21 9.14 9.14 C 9.21 9.07 9.3 9.03 9.4 9.01 C 9.5 8.99 9.6 9 9.69 9.04 L 20.69 13.54 C 20.77 13.57 20.84 13.62 20.89 13.69 C 20.94 13.75 20.98 13.83 20.99 13.91 C 21.01 14 21 14.08 20.97 14.16 C 20.95 14.24 20.9 14.31 20.84 14.37 C 20.77 14.43 20.7 14.47 20.62 14.49 L 16.27 15.53 C 16.09 15.57 15.92 15.66 15.79 15.79 C 15.66 15.92 15.57 16.09 15.53 16.27 L 14.49 20.62 C 14.47 20.7 14.43 20.77 14.37 20.84 C 14.31 20.9 14.24 20.95 14.16 20.97 C 14.08 21 14 21.01 13.91 20.99 C 13.83 20.98 13.75 20.94 13.69 20.89 C 13.62 20.84 13.57 20.77 13.54 20.69 Z
    palette=M 12 22 C 9.89 22 7.83 21.33 6.12 20.09 C 4.41 18.85 3.14 17.1 2.49 15.09 C 1.84 13.08 1.84 10.92 2.49 8.91 C 3.14 6.9 4.41 5.15 6.12 3.91 C 7.83 2.67 9.89 2 12 2 C 13.76 2 15.48 2.42 17 3.21 C 18.52 4 19.78 5.13 20.66 6.5 C 21.54 7.87 22 9.42 22 11 C 22 11.88 21.77 12.74 21.33 13.5 C 20.89 14.26 20.26 14.89 19.5 15.33 C 18.74 15.77 17.88 16 17 16 L 14.75 16 C 14.43 16 14.11 16.09 13.83 16.26 C 13.55 16.43 13.33 16.68 13.18 16.97 C 13.04 17.26 12.98 17.58 13.01 17.91 C 13.04 18.23 13.16 18.54 13.35 18.8 L 13.65 19.2 C 13.84 19.46 13.96 19.77 13.99 20.09 C 14.02 20.42 13.96 20.74 13.82 21.03 C 13.67 21.32 13.45 21.57 13.17 21.74 C 12.89 21.91 12.57 22 12.25 22 Z M 14 6.5 C 14 6.59 13.98 6.67 13.93 6.75 C 13.89 6.83 13.83 6.89 13.75 6.93 C 13.67 6.98 13.59 7 13.5 7 C 13.41 7 13.33 6.98 13.25 6.93 C 13.17 6.89 13.11 6.83 13.07 6.75 C 13.02 6.67 13 6.59 13 6.5 C 13 6.41 13.02 6.33 13.07 6.25 C 13.11 6.17 13.17 6.11 13.25 6.07 C 13.33 6.02 13.41 6 13.5 6 C 13.59 6 13.67 6.02 13.75 6.07 C 13.83 6.11 13.89 6.17 13.93 6.25 C 13.98 6.33 14 6.41 14 6.5 Z M 18 10.5 C 18 10.59 17.98 10.67 17.93 10.75 C 17.89 10.83 17.83 10.89 17.75 10.93 C 17.67 10.98 17.59 11 17.5 11 C 17.41 11 17.33 10.98 17.25 10.93 C 17.17 10.89 17.11 10.83 17.07 10.75 C 17.02 10.67 17 10.59 17 10.5 C 17 10.41 17.02 10.33 17.07 10.25 C 17.11 10.17 17.17 10.11 17.25 10.07 C 17.33 10.02 17.41 10 17.5 10 C 17.59 10 17.67 10.02 17.75 10.07 C 17.83 10.11 17.89 10.17 17.93 10.25 C 17.98 10.33 18 10.41 18 10.5 Z M 7 12.5 C 7 12.59 6.98 12.67 6.93 12.75 C 6.89 12.83 6.83 12.89 6.75 12.93 C 6.67 12.98 6.59 13 6.5 13 C 6.41 13 6.33 12.98 6.25 12.93 C 6.17 12.89 6.11 12.83 6.07 12.75 C 6.02 12.67 6 12.59 6 12.5 C 6 12.41 6.02 12.33 6.07 12.25 C 6.11 12.17 6.17 12.11 6.25 12.07 C 6.33 12.02 6.41 12 6.5 12 C 6.59 12 6.67 12.02 6.75 12.07 C 6.83 12.11 6.89 12.17 6.93 12.25 C 6.98 12.33 7 12.41 7 12.5 Z M 9 7.5 C 9 7.59 8.98 7.67 8.93 7.75 C 8.89 7.83 8.83 7.89 8.75 7.93 C 8.67 7.98 8.59 8 8.5 8 C 8.41 8 8.33 7.98 8.25 7.93 C 8.17 7.89 8.11 7.83 8.07 7.75 C 8.02 7.67 8 7.59 8 7.5 C 8 7.41 8.02 7.33 8.07 7.25 C 8.11 7.17 8.17 7.11 8.25 7.07 C 8.33 7.02 8.41 7 8.5 7 C 8.59 7 8.67 7.02 8.75 7.07 C 8.83 7.11 8.89 7.17 8.93 7.25 C 8.98 7.33 9 7.41 9 7.5 Z
    monitor=M 4 3 L 20 3 C 20.35 3 20.7 3.09 21 3.27 C 21.3 3.44 21.56 3.7 21.73 4 C 21.91 4.3 22 4.65 22 5 L 22 15 C 22 15.35 21.91 15.7 21.73 16 C 21.56 16.3 21.3 16.56 21 16.73 C 20.7 16.91 20.35 17 20 17 L 4 17 C 3.65 17 3.3 16.91 3 16.73 C 2.7 16.56 2.44 16.3 2.27 16 C 2.09 15.7 2 15.35 2 15 L 2 5 C 2 4.65 2.09 4.3 2.27 4 C 2.44 3.7 2.7 3.44 3 3.27 C 3.3 3.09 3.65 3 4 3 Z M 8 21 L 16 21 M 12 17 L 12 21
    info=M 22 12 C 22 13.76 21.54 15.48 20.66 17 C 19.78 18.52 18.52 19.78 17 20.66 C 15.48 21.54 13.76 22 12 22 C 10.24 22 8.52 21.54 7 20.66 C 5.48 19.78 4.22 18.52 3.34 17 C 2.46 15.48 2 13.76 2 12 C 2 10.24 2.46 8.52 3.34 7 C 4.22 5.48 5.48 4.22 7 3.34 C 8.52 2.46 10.24 2 12 2 C 13.76 2 15.48 2.46 17 3.34 C 18.52 4.22 19.78 5.48 20.66 7 C 21.54 8.52 22 10.24 22 12 Z M 12 16 L 12 12 M 12 8 L 12.01 8
    )"
    b2 := "
    (LTrim
    settings=M 9.67 4.14 C 9.71 3.67 9.9 3.24 10.19 2.88 C 10.48 2.52 10.88 2.25 11.32 2.12 C 11.76 1.98 12.24 1.98 12.68 2.12 C 13.13 2.25 13.52 2.52 13.81 2.88 C 14.11 3.24 14.29 3.67 14.33 4.14 C 14.36 4.51 14.49 4.87 14.69 5.19 C 14.89 5.51 15.17 5.77 15.49 5.96 C 15.82 6.14 16.18 6.25 16.56 6.27 C 16.93 6.28 17.31 6.21 17.65 6.05 C 18.07 5.86 18.54 5.8 19 5.87 C 19.45 5.95 19.88 6.16 20.22 6.47 C 20.55 6.79 20.79 7.2 20.9 7.65 C 21 8.1 20.97 8.57 20.81 9.01 C 20.64 9.44 20.36 9.81 19.98 10.08 C 19.67 10.3 19.42 10.59 19.25 10.92 C 19.07 11.25 18.98 11.62 18.98 12 C 18.98 12.38 19.07 12.75 19.25 13.08 C 19.42 13.41 19.67 13.7 19.98 13.91 C 20.36 14.18 20.64 14.56 20.81 14.99 C 20.97 15.43 21 15.9 20.9 16.35 C 20.79 16.8 20.55 17.21 20.22 17.53 C 19.88 17.84 19.45 18.05 19 18.13 C 18.54 18.2 18.07 18.14 17.65 17.95 C 17.31 17.79 16.93 17.71 16.56 17.73 C 16.18 17.75 15.82 17.85 15.49 18.04 C 15.17 18.23 14.89 18.49 14.69 18.81 C 14.49 19.13 14.36 19.49 14.33 19.86 C 14.29 20.32 14.11 20.76 13.81 21.12 C 13.52 21.48 13.13 21.75 12.68 21.88 C 12.24 22.02 11.76 22.02 11.32 21.88 C 10.88 21.75 10.48 21.48 10.19 21.12 C 9.9 20.76 9.71 20.32 9.67 19.86 C 9.64 19.49 9.52 19.13 9.31 18.81 C 9.11 18.49 8.83 18.23 8.51 18.04 C 8.18 17.85 7.82 17.75 7.44 17.73 C 7.07 17.71 6.69 17.79 6.35 17.95 C 5.93 18.14 5.46 18.2 5 18.13 C 4.55 18.05 4.12 17.84 3.78 17.53 C 3.45 17.21 3.21 16.8 3.1 16.35 C 3 15.9 3.03 15.43 3.19 14.99 C 3.36 14.56 3.64 14.18 4.02 13.91 C 4.33 13.7 4.58 13.41 4.75 13.08 C 4.93 12.75 5.02 12.38 5.02 12 C 5.02 11.62 4.93 11.25 4.75 10.92 C 4.58 10.59 4.33 10.3 4.02 10.08 C 3.65 9.81 3.36 9.44 3.19 9.01 C 3.03 8.57 3 8.1 3.11 7.65 C 3.21 7.2 3.45 6.79 3.79 6.48 C 4.12 6.16 4.55 5.95 5 5.87 C 5.46 5.8 5.93 5.86 6.35 6.05 C 6.69 6.21 7.06 6.28 7.44 6.27 C 7.82 6.25 8.18 6.14 8.51 5.96 C 8.83 5.77 9.11 5.51 9.31 5.19 C 9.51 4.87 9.64 4.51 9.67 4.14 M 15 12 C 15 12.53 14.86 13.04 14.6 13.5 C 14.33 13.96 13.96 14.33 13.5 14.6 C 13.04 14.86 12.53 15 12 15 C 11.47 15 10.96 14.86 10.5 14.6 C 10.04 14.33 9.67 13.96 9.4 13.5 C 9.14 13.04 9 12.53 9 12 C 9 11.47 9.14 10.96 9.4 10.5 C 9.67 10.04 10.04 9.67 10.5 9.4 C 10.96 9.14 11.47 9 12 9 C 12.53 9 13.04 9.14 13.5 9.4 C 13.96 9.67 14.33 10.04 14.6 10.5 C 14.86 10.96 15 11.47 15 12 Z
    power=M 12 2 L 12 12 M 18.4 6.6 C 19.66 7.86 20.51 9.46 20.86 11.2 C 21.21 12.94 21.03 14.75 20.35 16.39 C 19.68 18.04 18.53 19.44 17.05 20.43 C 15.58 21.43 13.84 21.96 12.06 21.96 C 10.29 21.97 8.55 21.45 7.06 20.47 C 5.58 19.48 4.42 18.09 3.74 16.45 C 3.05 14.81 2.86 13 3.2 11.26 C 3.54 9.51 4.38 7.9 5.63 6.64
    volume-2=M 11 4.7 C 11 4.56 10.96 4.43 10.88 4.31 C 10.8 4.2 10.69 4.1 10.56 4.05 C 10.44 4 10.29 3.98 10.16 4.01 C 10.02 4.04 9.9 4.11 9.8 4.2 L 6.41 7.59 C 6.28 7.72 6.13 7.82 5.96 7.89 C 5.78 7.96 5.6 8 5.42 8 L 3 8 C 2.82 8 2.65 8.05 2.5 8.13 C 2.35 8.22 2.22 8.35 2.13 8.5 C 2.05 8.65 2 8.82 2 9 L 2 15 C 2 15.18 2.05 15.35 2.13 15.5 C 2.22 15.65 2.35 15.78 2.5 15.87 C 2.65 15.95 2.82 16 3 16 L 5.42 16 C 5.6 16 5.78 16.04 5.96 16.11 C 6.13 16.18 6.28 16.28 6.41 16.41 L 9.8 19.8 C 9.89 19.9 10.02 19.96 10.16 19.99 C 10.29 20.02 10.44 20 10.56 19.95 C 10.69 19.9 10.8 19.81 10.88 19.69 C 10.96 19.57 11 19.44 11 19.3 Z M 16 9 C 16.43 9.57 16.73 10.23 16.89 10.94 C 17.04 11.64 17.04 12.36 16.89 13.06 C 16.73 13.77 16.43 14.43 16 15 M 19.36 18.36 C 20.48 17.25 21.28 15.86 21.69 14.33 C 22.1 12.8 22.1 11.2 21.69 9.67 C 21.28 8.14 20.48 6.75 19.36 5.64
    crosshair=M 22 12 C 22 13.76 21.54 15.48 20.66 17 C 19.78 18.52 18.52 19.78 17 20.66 C 15.48 21.54 13.76 22 12 22 C 10.24 22 8.52 21.54 7 20.66 C 5.48 19.78 4.22 18.52 3.34 17 C 2.46 15.48 2 13.76 2 12 C 2 10.24 2.46 8.52 3.34 7 C 4.22 5.48 5.48 4.22 7 3.34 C 8.52 2.46 10.24 2 12 2 C 13.76 2 15.48 2.46 17 3.34 C 18.52 4.22 19.78 5.48 20.66 7 C 21.54 8.52 22 10.24 22 12 Z M 22 12 L 18 12 M 6 12 L 2 12 M 12 6 L 12 2 M 12 22 L 12 18
    rocket=M 12 15 L 12 20 C 12 20 15.03 19.45 16 18 C 17.08 16.38 16 13 16 13 M 4.5 16.5 C 3 17.76 2.5 21.5 2.5 21.5 C 2.5 21.5 6.24 21 7.5 19.5 C 8.21 18.66 8.2 17.37 7.41 16.59 C 7.15 16.34 6.84 16.17 6.5 16.07 C 6.15 15.97 5.79 15.96 5.44 16.04 C 5.1 16.11 4.77 16.27 4.5 16.5 M 9 12 C 9.53 10.62 10.2 9.3 11 8.05 C 12.17 6.19 13.79 4.65 15.71 3.59 C 17.64 2.54 19.8 1.99 22 2 C 22 4.72 21.22 9.5 16 13 C 14.74 13.8 13.4 14.47 12 15 Z M 9 12 L 4 12 C 4 12 4.55 8.97 6 8 C 7.62 6.92 11 8.05 11 8.05
    eye=M 2.06 12.35 C 2.02 12.24 2 12.12 2 12 C 2 11.88 2.02 11.76 2.06 11.65 C 2.87 9.68 4.25 8 6.02 6.82 C 7.79 5.63 9.87 5 12 5 C 14.13 5 16.21 5.63 17.98 6.82 C 19.75 8 21.13 9.68 21.94 11.65 C 21.98 11.76 22 11.88 22 12 C 22 12.12 21.98 12.24 21.94 12.35 C 21.13 14.32 19.75 16 17.98 17.18 C 16.21 18.37 14.13 19 12 19 C 9.87 19 7.79 18.37 6.02 17.18 C 4.25 16 2.87 14.32 2.06 12.35 M 15 12 C 15 12.53 14.86 13.04 14.6 13.5 C 14.33 13.96 13.96 14.33 13.5 14.6 C 13.04 14.86 12.53 15 12 15 C 11.47 15 10.96 14.86 10.5 14.6 C 10.04 14.33 9.67 13.96 9.4 13.5 C 9.14 13.04 9 12.53 9 12 C 9 11.47 9.14 10.96 9.4 10.5 C 9.67 10.04 10.04 9.67 10.5 9.4 C 10.96 9.14 11.47 9 12 9 C 12.53 9 13.04 9.14 13.5 9.4 C 13.96 9.67 14.33 10.04 14.6 10.5 C 14.86 10.96 15 11.47 15 12 Z
    eye-off=M 10.73 5.08 C 12.28 4.89 13.85 5.05 15.33 5.53 C 16.81 6.01 18.16 6.8 19.3 7.86 C 20.45 8.92 21.35 10.21 21.94 11.65 C 21.98 11.76 22 11.88 22 12 C 22 12.12 21.98 12.24 21.94 12.35 C 21.57 13.24 21.08 14.08 20.49 14.84 M 14.08 14.16 C 13.63 14.59 13.06 14.88 12.44 14.97 C 11.82 15.06 11.19 14.95 10.63 14.67 C 10.07 14.38 9.62 13.93 9.33 13.37 C 9.05 12.81 8.94 12.18 9.03 11.56 C 9.12 10.94 9.41 10.37 9.84 9.92 M 17.48 17.5 C 15.71 18.55 13.67 19.07 11.61 18.99 C 9.55 18.92 7.55 18.25 5.86 17.07 C 4.17 15.89 2.85 14.25 2.06 12.35 C 2.02 12.24 2 12.12 2 12 C 2 11.88 2.02 11.76 2.06 11.65 C 2.5 10.58 3.11 9.59 3.87 8.72 C 4.62 7.85 5.51 7.1 6.51 6.51 M 2 2 L 22 22
    )"
    b3 := "
    (LTrim
    play=M 5 5 C 5 4.65 5.09 4.3 5.27 4 C 5.45 3.69 5.7 3.44 6 3.27 C 6.31 3.09 6.65 3 7.01 3 C 7.36 3 7.7 3.09 8.01 3.27 L 20 10.27 C 20.31 10.45 20.56 10.7 20.73 11 C 20.91 11.3 21 11.65 21 12 C 21 12.35 20.91 12.69 20.74 13 C 20.56 13.3 20.31 13.55 20.01 13.73 L 8.01 20.73 C 7.7 20.91 7.36 21 7.01 21 C 6.65 21 6.31 20.91 6 20.73 C 5.7 20.56 5.45 20.31 5.27 20 C 5.09 19.7 5 19.35 5 19 Z
    keyboard=M 10 8 L 10.01 8 M 12 12 L 12.01 12 M 14 8 L 14.01 8 M 16 12 L 16.01 12 M 18 8 L 18.01 8 M 6 8 L 6.01 8 M 7 16 L 17 16 M 8 12 L 8.01 12 M 4 4 L 20 4 C 20.35 4 20.7 4.09 21 4.27 C 21.3 4.44 21.56 4.7 21.73 5 C 21.91 5.3 22 5.65 22 6 L 22 18 C 22 18.35 21.91 18.7 21.73 19 C 21.56 19.3 21.3 19.56 21 19.73 C 20.7 19.91 20.35 20 20 20 L 4 20 C 3.65 20 3.3 19.91 3 19.73 C 2.7 19.56 2.44 19.3 2.27 19 C 2.09 18.7 2 18.35 2 18 L 2 6 C 2 5.65 2.09 5.3 2.27 5 C 2.44 4.7 2.7 4.44 3 4.27 C 3.3 4.09 3.65 4 4 4 Z
    brush=M 11 10 L 14 13 M 6.5 21 C 7.19 21 7.87 20.79 8.44 20.41 C 9.02 20.03 9.47 19.48 9.73 18.84 C 10 18.2 10.07 17.5 9.93 16.82 C 9.8 16.14 9.46 15.51 8.97 15.03 C 8.49 14.54 7.86 14.2 7.18 14.07 C 6.5 13.93 5.8 14 5.16 14.27 C 4.52 14.53 3.97 14.98 3.59 15.56 C 3.21 16.13 3 16.81 3 17.5 C 3 17.83 2.94 18.16 2.82 18.46 C 2.7 18.77 2.52 19.05 2.29 19.29 C 2.15 19.43 2.06 19.61 2.02 19.8 C 1.98 20 2 20.2 2.07 20.38 C 2.15 20.57 2.28 20.72 2.44 20.83 C 2.61 20.94 2.8 21 3 21 Z M 9.97 17.03 L 21.38 5.62 C 21.69 5.31 21.9 4.9 21.97 4.46 C 22.04 4.01 21.97 3.56 21.77 3.16 C 21.56 2.76 21.24 2.44 20.84 2.23 C 20.44 2.03 19.99 1.96 19.54 2.03 C 19.1 2.1 18.69 2.31 18.38 2.62 L 6.97 14.03
    sparkles=M 11.02 2.81 C 11.05 2.63 11.14 2.46 11.26 2.32 C 11.39 2.19 11.55 2.09 11.73 2.04 C 11.91 1.98 12.09 1.98 12.27 2.04 C 12.45 2.09 12.61 2.19 12.74 2.32 C 12.86 2.46 12.95 2.63 12.98 2.81 L 14.03 8.37 C 14.11 8.77 14.3 9.13 14.59 9.41 C 14.87 9.7 15.23 9.89 15.63 9.97 L 21.19 11.02 C 21.37 11.05 21.54 11.14 21.68 11.26 C 21.81 11.39 21.91 11.55 21.96 11.73 C 22.02 11.91 22.02 12.09 21.96 12.27 C 21.91 12.45 21.81 12.61 21.68 12.74 C 21.54 12.86 21.37 12.95 21.19 12.98 L 15.63 14.03 C 15.23 14.11 14.87 14.3 14.59 14.59 C 14.3 14.87 14.11 15.23 14.03 15.63 L 12.98 21.19 C 12.95 21.37 12.86 21.54 12.74 21.68 C 12.61 21.81 12.45 21.91 12.27 21.96 C 12.09 22.02 11.91 22.02 11.73 21.96 C 11.55 21.91 11.39 21.81 11.26 21.68 C 11.14 21.54 11.05 21.37 11.02 21.19 L 9.97 15.63 C 9.89 15.23 9.7 14.87 9.41 14.59 C 9.13 14.3 8.77 14.11 8.37 14.03 L 2.81 12.98 C 2.63 12.95 2.46 12.86 2.32 12.74 C 2.19 12.61 2.09 12.45 2.04 12.27 C 1.98 12.09 1.98 11.91 2.04 11.73 C 2.09 11.55 2.19 11.39 2.32 11.26 C 2.46 11.14 2.63 11.05 2.81 11.02 L 8.37 9.97 C 8.77 9.89 9.13 9.7 9.41 9.41 C 9.7 9.13 9.89 8.77 9.97 8.37 Z M 20 2 L 20 6 M 22 4 L 18 4 M 6 20 C 6 20.35 5.91 20.7 5.73 21 C 5.56 21.3 5.3 21.56 5 21.73 C 4.7 21.91 4.35 22 4 22 C 3.65 22 3.3 21.91 3 21.73 C 2.7 21.56 2.44 21.3 2.27 21 C 2.09 20.7 2 20.35 2 20 C 2 19.65 2.09 19.3 2.27 19 C 2.44 18.7 2.7 18.44 3 18.27 C 3.3 18.09 3.65 18 4 18 C 4.35 18 4.7 18.09 5 18.27 C 5.3 18.44 5.56 18.7 5.73 19 C 5.91 19.3 6 19.65 6 20 Z
    sun=M 16 12 C 16 12.7 15.82 13.39 15.46 14 C 15.11 14.61 14.61 15.11 14 15.46 C 13.39 15.82 12.7 16 12 16 C 11.3 16 10.61 15.82 10 15.46 C 9.39 15.11 8.89 14.61 8.54 14 C 8.18 13.39 8 12.7 8 12 C 8 11.3 8.18 10.61 8.54 10 C 8.89 9.39 9.39 8.89 10 8.54 C 10.61 8.18 11.3 8 12 8 C 12.7 8 13.39 8.18 14 8.54 C 14.61 8.89 15.11 9.39 15.46 10 C 15.82 10.61 16 11.3 16 12 Z M 12 2 L 12 4 M 12 20 L 12 22 M 4.93 4.93 L 6.34 6.34 M 17.66 17.66 L 19.07 19.07 M 2 12 L 4 12 M 20 12 L 22 12 M 6.34 17.66 L 4.93 19.07 M 19.07 4.93 L 17.66 6.34
    tag=M 12.59 2.59 C 12.4 2.4 12.18 2.25 11.94 2.15 C 11.69 2.05 11.43 2 11.17 2 L 4 2 C 3.65 2 3.3 2.09 3 2.27 C 2.7 2.44 2.44 2.7 2.27 3 C 2.09 3.3 2 3.65 2 4 L 2 11.17 C 2 11.43 2.05 11.69 2.15 11.94 C 2.25 12.18 2.4 12.4 2.59 12.59 L 11.29 21.29 C 11.59 21.59 11.96 21.8 12.37 21.91 C 12.78 22.02 13.22 22.02 13.63 21.91 C 14.04 21.8 14.41 21.59 14.71 21.29 L 21.29 14.71 C 21.59 14.41 21.8 14.04 21.91 13.63 C 22.02 13.22 22.02 12.78 21.91 12.37 C 21.8 11.96 21.59 11.59 21.29 11.29 Z M 8 7.5 C 8 7.59 7.98 7.67 7.93 7.75 C 7.89 7.83 7.83 7.89 7.75 7.93 C 7.67 7.98 7.59 8 7.5 8 C 7.41 8 7.33 7.98 7.25 7.93 C 7.17 7.89 7.11 7.83 7.07 7.75 C 7.02 7.67 7 7.59 7 7.5 C 7 7.41 7.02 7.33 7.07 7.25 C 7.11 7.17 7.17 7.11 7.25 7.07 C 7.33 7.02 7.41 7 7.5 7 C 7.59 7 7.67 7.02 7.75 7.07 C 7.83 7.11 7.89 7.17 7.93 7.25 C 7.98 7.33 8 7.41 8 7.5 Z
    scaling=M 12 3 L 5 3 C 4.65 3 4.3 3.09 4 3.27 C 3.7 3.44 3.44 3.7 3.27 4 C 3.09 4.3 3 4.65 3 5 L 3 19 C 3 19.35 3.09 19.7 3.27 20 C 3.44 20.3 3.7 20.56 4 20.73 C 4.3 20.91 4.65 21 5 21 L 19 21 C 19.35 21 19.7 20.91 20 20.73 C 20.3 20.56 20.56 20.3 20.73 20 C 20.91 19.7 21 19.35 21 19 L 21 12 M 14 15 L 9 15 L 9 10 M 16 3 L 21 3 L 21 8 M 21 3 L 9 15
    menu=M 4 5 L 20 5 M 4 12 L 20 12 M 4 19 L 20 19
    pencil=M 21.17 6.81 C 21.59 6.39 21.87 5.85 21.97 5.26 C 22.06 4.67 21.96 4.07 21.69 3.54 C 21.42 3.01 20.99 2.58 20.46 2.31 C 19.93 2.04 19.33 1.94 18.74 2.03 C 18.15 2.13 17.61 2.4 17.19 2.83 L 3.84 16.17 C 3.61 16.41 3.44 16.69 3.34 17 L 2.02 21.36 C 2 21.44 1.99 21.53 2.02 21.62 C 2.04 21.71 2.08 21.79 2.15 21.85 C 2.21 21.92 2.29 21.96 2.38 21.98 C 2.47 22.01 2.56 22 2.64 21.98 L 7 20.66 C 7.31 20.56 7.6 20.39 7.83 20.16 Z M 15 5 L 19 9
    lock=M 5 11 L 19 11 C 19.35 11 19.7 11.09 20 11.27 C 20.3 11.44 20.56 11.7 20.73 12 C 20.91 12.3 21 12.65 21 13 L 21 20 C 21 20.35 20.91 20.7 20.73 21 C 20.56 21.3 20.3 21.56 20 21.73 C 19.7 21.91 19.35 22 19 22 L 5 22 C 4.65 22 4.3 21.91 4 21.73 C 3.7 21.56 3.44 21.3 3.27 21 C 3.09 20.7 3 20.35 3 20 L 3 13 C 3 12.65 3.09 12.3 3.27 12 C 3.44 11.7 3.7 11.44 4 11.27 C 4.3 11.09 4.65 11 5 11 Z M 7 11 L 7 7 C 7 5.94 7.33 4.92 7.95 4.06 C 8.58 3.21 9.45 2.57 10.45 2.24 C 11.46 1.92 12.54 1.92 13.55 2.24 C 14.55 2.57 15.42 3.21 16.05 4.06 C 16.67 4.92 17 5.94 17 7 L 17 11
    )"
    b4 := "
    (LTrim
    refresh-cw=M 3 12 C 3 10.42 3.42 8.87 4.21 7.5 C 5 6.13 6.13 5 7.5 4.21 C 8.87 3.42 10.42 3 12 3 C 13.25 3 14.48 3.25 15.64 3.72 C 16.79 4.19 17.84 4.87 18.74 5.74 L 21 8 M 21 3 L 21 8 L 16 8 M 21 12 C 21 13.58 20.58 15.13 19.79 16.5 C 19 17.87 17.87 19 16.5 19.79 C 15.13 20.58 13.58 21 12 21 C 10.75 21 9.52 20.75 8.36 20.28 C 7.21 19.81 6.16 19.13 5.26 18.26 L 3 16 M 8 16 L 3 16 L 3 21
    rotate-ccw=M 3 12 C 3 13.78 3.53 15.52 4.52 17 C 5.51 18.48 6.91 19.63 8.56 20.31 C 10.2 21 12.01 21.17 13.76 20.83 C 15.5 20.48 17.11 19.62 18.36 18.36 C 19.62 17.11 20.48 15.5 20.83 13.76 C 21.17 12.01 21 10.2 20.31 8.56 C 19.63 6.91 18.48 5.51 17 4.52 C 15.52 3.53 13.78 3 12 3 C 10.75 3 9.52 3.25 8.36 3.72 C 7.21 4.19 6.16 4.87 5.26 5.74 L 3 8 M 3 3 L 3 8 L 8 8
    log-out=M 16 17 L 21 12 L 16 7 M 21 12 L 9 12 M 9 21 L 5 21 C 4.65 21 4.3 20.91 4 20.73 C 3.7 20.56 3.44 20.3 3.27 20 C 3.09 19.7 3 19.35 3 19 L 3 5 C 3 4.65 3.09 4.3 3.27 4 C 3.44 3.7 3.7 3.44 4 3.27 C 4.3 3.09 4.65 3 5 3 L 9 3
    )"
return [b1, b2, b3, b4]
}

#If (editField)
*0::
*1::
*2::
*3::
*4::
*5::
*6::
*7::
*8::
*9::
*Numpad0::
*Numpad1::
*Numpad2::
*Numpad3::
*Numpad4::
*Numpad5::
*Numpad6::
*Numpad7::
*Numpad8::
*Numpad9::
*a::
*b::
*c::
*d::
*e::
*f::
    EditKey(SubStr(A_ThisHotkey, 0))
return
*Backspace::
    EditBack()
return
*Enter::
*NumpadEnter::
    CommitEdit()
return
*Tab::
    EditNext()
return
^v::
    EditPaste()
return
#If

#If (inputEl)
*Left::
*Right::
*Home::
*End::
*Delete::
*Backspace::
    InputKey(SubStr(A_ThisHotkey, 2))
return
^a::
^c::
^x::
    InputKey(SubStr(A_ThisHotkey, 2))
return
^v::
    InputPaste()
return
#If
