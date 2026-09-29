package main

import (
    "context"
    "encoding/json"
    "fmt"
    "net/http"

    "golang.org/x/oauth2"
    "google.golang.org/api/calendar/v3"
    "google.golang.org/api/option"
)

type HandleRequest struct {
    Token string         `json:"token"`
    State map[string]int `json:"state"`
}

type HandleResponse struct {
    Triggered bool           `json:"triggered"`
    State     map[string]int `json:"state"`
}

func subscribeCalendarHandler(w http.ResponseWriter, r *http.Request) {
    var payload HandleRequest
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

    eventCount, err := getTotalEventsCount(srv)
    if err != nil {
        http.Error(w, "Unable to count events: "+err.Error(), http.StatusInternalServerError)
        return
    }

	response := HandleResponse{
		State:     make(map[string]int),
		Triggered: false,
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

func getTotalEventsCount(srv *calendar.Service) (int, error) {
    events, err := srv.Events.List("primary").Do()
    if err != nil {
        return 0, err
    }
    return len(events.Items), nil
}

func getClient(accessToken string) (*http.Client, error) {
    token := &oauth2.Token{AccessToken: accessToken}
    tokenSource := oauth2.StaticTokenSource(token)
    client := oauth2.NewClient(context.Background(), tokenSource)
    return client, nil
}
