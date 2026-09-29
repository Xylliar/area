package main

import (
	"net/http"
    "fmt"
	"time"
	_ "time/tzdata"
)

// Prayer timings are fetched for Paris, so they are compared with the Paris wall clock.
var parisLocation, _ = time.LoadLocation("Europe/Paris")


func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/prayer/health", healthHandler)
    http.HandleFunc("/prayer/prayer_action", prayerAction)
    http.HandleFunc("/prayer/next_prayer_action", nextPrayerAction)
    http.ListenAndServe(":8000", nil)
}