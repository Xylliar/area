package main

import (
    "fmt"
    "log"
    "net/http"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/calendar/check-new-event", subscribeCalendarHandler)
	http.HandleFunc("/calendar/check-new-event-name", subscribeCalendarNameHandler)

    http.HandleFunc("/calendar/add-event", addEventHandler)

	http.HandleFunc("/calendar/health", healthHandler)

    log.Println("Server starting on :8000...")
    err := http.ListenAndServe(":8000", nil)
    if err != nil {
        log.Fatalf("Error starting server: %s", err)
    }
}
