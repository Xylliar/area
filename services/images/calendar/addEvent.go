package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"google.golang.org/api/calendar/v3"
	"google.golang.org/api/option"
)

type AddEvent struct {
    Token string `json:"token"`
    Description string `json:"description"`
	StartTime string `json:"time-UTC"`
}

func addEventHandler(w http.ResponseWriter, r *http.Request) {
    var payload AddEvent
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" || payload.Description == "" {
        http.Error(w, "Missing required fields: token or description", http.StatusBadRequest)
        return
    }

	loc := time.FixedZone("Europe/Paris", 3600)
	if err != nil {
		http.Error(w, "Unable to load location: "+err.Error(), http.StatusInternalServerError)
		return
	}

	startTime, err := time.ParseInLocation(time.RFC3339, payload.StartTime, loc)
	if err != nil {
		http.Error(w, "Unable to parse start time: "+err.Error(), http.StatusInternalServerError)
		return
	}

    ctx := context.Background()
    client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, "Unable to create client: "+err.Error(), http.StatusInternalServerError)
        return
    }

    srv, err := calendar.NewService(ctx, option.WithHTTPClient(client))
    if err != nil {
        http.Error(w, "Unable to retrieve Calendar client: "+err.Error(), http.StatusInternalServerError)
        return
    }

    event := &calendar.Event{
        Summary: payload.Description,
        Start: &calendar.EventDateTime{DateTime: startTime.Format(time.RFC3339)},
        End: &calendar.EventDateTime{DateTime: startTime.Add(time.Hour).Format(time.RFC3339)},
    }

    _, err = srv.Events.Insert("primary", event).Do()
    if err != nil {
        http.Error(w, "Unable to add event: "+err.Error(), http.StatusInternalServerError)
        return
    }
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
}
