package main

import (
	"encoding/json"
	"time"
	"net/http"
)

type NextPrayerActionInput struct {
	State map[string]string `json:"state"`
}

func nextPrayerAction(w http.ResponseWriter, r *http.Request) {
	var req NextPrayerActionInput
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
	prayerOrder := []string{"Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"}
	triggeredPrayers := make(map[string]bool)
	var lastTriggeredPrayer string
	for _, prayer := range prayerOrder {
		var prayerTimeStr string
		switch prayer {
		case "Fajr":
			prayerTimeStr = prayerTimes.Fajr
		case "Dhuhr":
			prayerTimeStr = prayerTimes.Dhuhr
		case "Asr":
			prayerTimeStr = prayerTimes.Asr
		case "Maghrib":
			prayerTimeStr = prayerTimes.Maghrib
		case "Isha":
			prayerTimeStr = prayerTimes.Isha
		}
		prayerTime, err := time.Parse("15:04", prayerTimeStr)
		if err != nil {
			http.Error(w, "Failed to parse prayer time", http.StatusInternalServerError)
			return
		}
		prayerTime = time.Date(currentTime.Year(), currentTime.Month(), currentTime.Day(), prayerTime.Hour(), prayerTime.Minute(), 0, 0, currentTime.Location())
		if currentTime.After(prayerTime) {
			if triggeredAt, ok := req.State[prayer]; !ok || triggeredAt != currentTime.Format("02-01-2006") {
				req.State[prayer] = currentTime.Format("02-01-2006")
				triggeredPrayers[prayer] = true
				lastTriggeredPrayer = prayer
			}
		}
	}
	if len(triggeredPrayers) > 0 {
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": true,
			"state":     req.State,
			"prayer":    lastTriggeredPrayer,
		})
	} else {
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": false,
			"state":     req.State,
		})
	}
}
