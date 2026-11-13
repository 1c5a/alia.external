FetchText(url, ByRef err) {
    try {
        http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", url, false)
        http.SetRequestHeader("User-Agent", "Mozilla/5.0 (offsets fetcher)")
        http.SetTimeouts(5000, 5000, 10000, 15000)
        http.Send()
        if (http.Status != 200) {
            err := "HTTP " http.Status
            return ""
        }
        return http.ResponseText
    } catch e {
        err := e.Message
        return ""
    }
}

