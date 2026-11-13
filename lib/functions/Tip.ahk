Tip(msg, ms := 2500) {
    ToolTip, %msg%
    SetTimer, HideTip, % -ms
}

