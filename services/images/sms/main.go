package main

import (
	"net/http"
    "fmt"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/sms/health", healthHandler)
    http.HandleFunc("/sms/send_sms_reaction", sendSmsReaction)
    http.ListenAndServe(":8000", nil)
}
