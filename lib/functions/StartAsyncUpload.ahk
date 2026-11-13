StartAsyncUpload(url, json, file) {
    global appDir, uploadBusy, uploadPid, uploadStart, uploadBody
    curl := A_WinDir "\System32\curl.exe"
    if !FileExist(curl)
        return false
    cacheDir := appDir "\cache"
    jf := cacheDir "\payload.json"
    FileDelete, %jf%
    fo := FileOpen(jf, "w", "UTF-8-RAW")
    if !fo
        return false
    fo.Write(json)
    fo.Close()
    respF := appDir "\webhook_resp.txt"
    errF := appDir "\webhook_curlerr.txt"
    FileDelete, %respF%
    FileDelete, %errF%
    q := """"
    cmd := q curl q " -s -S --max-time 60 --stderr " q errF q " -o " q respF q
    cmd .= " -F " q "payload_json=<" jf ";type=application/json" q
    cmd .= " -F " q "files[0]=@" file ";filename=shot.jpg;type=image/jpeg" q
    cmd .= " " q url q
    pid := 0
    Run, % cmd, , Hide UseErrorLevel, pid
    if (ErrorLevel = "ERROR" || !pid)
        return false
    uploadPid := pid
    uploadStart := A_TickCount
    uploadBody := json
    uploadBusy := true
    SetTimer, UploadWatch, 300
    return true
}

