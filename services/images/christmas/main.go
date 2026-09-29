package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "time"
)

func isChristmas() bool {
    now := time.Now()
    return now.Month() == time.December && now.Day() == 25
}

func getDaysUntilChristmas() int {
    now := time.Now()
    currentYear := now.Year()
    christmas := time.Date(currentYear, time.December, 25, 0, 0, 0, 0, time.Local)

    if now.After(christmas) {
        christmas = time.Date(currentYear+1, time.December, 25, 0, 0, 0, 0, time.Local)
    }

    days := int(christmas.Sub(now).Hours() / 24)
    return days
}

func christmasHandler(w http.ResponseWriter, r *http.Request) {
    days := getDaysUntilChristmas()
    isXmas := isChristmas()

    json.NewEncoder(w).Encode(map[string]interface{}{
        "triggered": isXmas,
        "days":     days,
    })
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/christmas/health", healthHandler)
    http.HandleFunc("/christmas/days", christmasHandler)
    fmt.Println("Server running on :8000")
    http.ListenAndServe(":8000", nil)
}