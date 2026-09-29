package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "strings"

    "google.golang.org/api/calendar/v3"
    "google.golang.org/api/option"
)

type HandleRequestEvent struct {
    Token   string         `json:"token"`
    State   map[string]int `json:"state"`
    Keyword string         `json:"keyword"`
}

type HandleResponseEvent struct {
    Triggered bool           `json:"triggered"`
    State     map[string]int `json:"state"`
    NameEvents string       `json:"NameEvents"`
}

func subscribeCalendarNameHandler(w http.ResponseWriter, r *http.Request) {
    var payload HandleRequestEvent
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token", http.StatusBadRequest)
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

    eventCount, nameEvents, err := getTotalEventsNameCount(srv, payload.Keyword)
    if err != nil {
        http.Error(w, "Unable to count events: "+err.Error(), http.StatusInternalServerError)
        return
    }

    response := HandleResponseEvent{
        State:     make(map[string]int),
        Triggered: false,
        NameEvents: nameEvents,
    }

    if eventCount > payload.State["eventCount"] {
        response.Triggered = true
        response.State["eventCount"] = eventCount
    } else {
        response.State["eventCount"] = eventCount
        response.Triggered = false
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func getTotalEventsNameCount(srv *calendar.Service, keyword string) (int, string, error) {
    events, err := srv.Events.List("primary").Do()
    if err != nil {
        return 0, "", err
    }

    var matchedEvents string
    var count int
    for _, event := range events.Items {
        if strings.Contains(event.Summary, keyword) || 
           strings.Contains(event.Description, keyword) || 
           strings.Contains(event.Location, keyword) {
            matchedEvents += event.Summary + ", "
            count++
        }
    }
    return count, matchedEvents, nil
}
