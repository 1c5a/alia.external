PostWebhook(url, body, ByRef err) {
    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        http.SetTimeouts(5000, 5000, 10000, 15000)
        http.Send(ToUtf8Array(body))
        if (http.Status < 200 || http.Status >= 300) {
            err := "HTTP " http.Status " " SubStr(http.ResponseText, 1, 200)
            return false
        }
        return true
    } catch e {
        err := e.Message
        return false
    }
}

