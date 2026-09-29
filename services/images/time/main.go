package main

import (
	"encoding/json"
	"net/http"
	"time"
	_ "time/tzdata"
    "fmt"
)

type TriggerRequest struct {
    Hour  string            `json:"hour"`
    State map[string]string `json:"state"`
}

func getWorldTime() (time.Time, error) {
    location, err := time.LoadLocation("Europe/Paris")
    if err != nil {
        return time.Time{}, err
    }
    return time.Now().In(location), nil
}

func checkTrigger(w http.ResponseWriter, r *http.Request) {
    var req TriggerRequest
    err := json.NewDecoder(r.Body).Decode(&req)
    if err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    currentTime, err := getWorldTime()
    if err != nil {
        http.Error(w, "Failed to get current time", http.StatusInternalServerError)
        return
    }

    inputTime, err := time.Parse("15:04", req.Hour)
    if err != nil {
        http.Error(w, "Invalid hour format", http.StatusBadRequest)
        return
    }
    inputTime = time.Date(currentTime.Year(), currentTime.Month(), currentTime.Day(), inputTime.Hour(), inputTime.Minute(), 0, 0, currentTime.Location())

    if currentTime.Before(inputTime) {
        req.State = make(map[string]string)
        json.NewEncoder(w).Encode(map[string]interface{}{
            "triggered": false,
            "state":     req.State,
        })
        return
    }
    if inputTime.Before(currentTime) {
        if len(req.State) == 0 {
            req.State = map[string]string{
                "triggered_at": currentTime.Format("02-01 15:04"),
            }
            json.NewEncoder(w).Encode(map[string]interface{}{
                "triggered": true,
                "state":     req.State,
            })
            return
        }
        if triggeredAt, ok := req.State["triggered_at"]; ok {
            if triggeredAt >= inputTime.Format("02-01 15:04") {
                json.NewEncoder(w).Encode(map[string]interface{}{
                    "triggered": false,
                    "state":     req.State,
                })
                return
            }
            if triggeredAt != currentTime.Format("02-01 15:04") {
                req.State = map[string]string{
                    "triggered_at": currentTime.Format("02-01 15:04"),
                }
                json.NewEncoder(w).Encode(map[string]interface{}{
                    "triggered": true,
                    "state":     req.State,
                })
                return
            }
        }
    }
    json.NewEncoder(w).Encode(map[string]interface{}{
        "triggered": false,
        "state":     req.State,
    })
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/time/check_trigger", checkTrigger)
    http.HandleFunc("/time/health", healthHandler)
    http.ListenAndServe(":8000", nil)
}