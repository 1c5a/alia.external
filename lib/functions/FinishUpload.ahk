FinishUpload() {
    global appDir, uploadBusy, uploadBody
    FileRead, resp, %appDir%\webhook_resp.txt
    FileRead, cerr, %appDir%\webhook_curlerr.txt
    CleanShotCache()
    uploadBusy := false
    cerr := Trim(cerr)
    if (cerr != "")
        err := "curl: " SubStr(cerr, 1, 200)
    else if (InStr(resp, """code""") || InStr(resp, """message"""))
        err := "Discord: " SubStr(resp, 1, 200)
    else
        err := ""
    if (err = "") {
        Tip("Info sent to webhook")
        return
    }
    Tip("Webhook failed: " err, 8000)
    errLog := appDir "\webhook_error.txt"
    FileDelete, %errLog%
    FileAppend, % err "`n`nPayload:`n" uploadBody, %errLog%, UTF-8
}

; multipart/form-data: payload_json + the screenshot as files[0] (referenced by the embed as attachment://shot.png)
