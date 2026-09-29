package main

import (
	"encoding/json"
	"time"
	"net/http"
)

type PrayerActionInput struct {
	State	map[string]string	`json:"state"`
	Prayer string `json:"prayer"`
}

func prayerAction(w http.ResponseWriter, r *http.Request) {
	var req PrayerActionInput
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	currentTime := time.Now().In(parisLocation)
	prayerTimes, err := retrievePrayerTimes()
	if err != nil {
		http.Error(w, "Failed to get prayer times", http.StatusInternalServerError)
		return
	}
	prayerMap := map[string]string{
		"Fajr":    prayerTimes.Fajr,
		"Dhuhr":   prayerTimes.Dhuhr,
		"Asr":     prayerTimes.Asr,
		"Maghrib": prayerTimes.Maghrib,
		"Isha":    prayerTimes.Isha,
	}
	prayerTimeStr, exists := prayerMap[req.Prayer]
	if !exists {
		http.Error(w, "Invalid prayer specified", http.StatusBadRequest)
		return
	}
	prayerTime, err := time.Parse("15:04", prayerTimeStr)
	if err != nil {
		http.Error(w, "Failed to parse prayer time", http.StatusInternalServerError)
		return
	}
	prayerTime = time.Date(currentTime.Year(), currentTime.Month(), currentTime.Day(), prayerTime.Hour(), prayerTime.Minute(), 0, 0, currentTime.Location())
	if currentTime.After(prayerTime) {
		if triggeredAt, ok := req.State[req.Prayer]; !ok || triggeredAt != currentTime.Format("02-01-2006") {
			req.State[req.Prayer] = currentTime.Format("02-01-2006")
			json.NewEncoder(w).Encode(map[string]interface{}{
				"triggered": true,
				"state":     req.State,
			})
			return
		}
	}
	json.NewEncoder(w).Encode(map[string]interface{}{
		"triggered": false,
		"state":     req.State,
	})
}
