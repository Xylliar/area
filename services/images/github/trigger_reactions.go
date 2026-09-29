package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
)

var serverURL = envOr("SERVER_URL", "http://server:8080")

// Public base URL at which GitHub can reach this service (a tunnel when running locally).
var webhookBaseURL = os.Getenv("GITHUB_WEBHOOK_URL")

func envOr(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func callbackURL(w http.ResponseWriter, path string) (string, bool) {
	if webhookBaseURL == "" {
		http.Error(w, "GITHUB_WEBHOOK_URL is not set: GitHub needs a public URL to deliver webhooks to this service", http.StatusServiceUnavailable)
		return "", false
	}
	return strings.TrimRight(webhookBaseURL, "/") + path, true
}

func triggerReactions(applet_id string, payload interface{}) {
	url := strings.TrimRight(serverURL, "/") + "/applets/trigger_reactions/" + applet_id
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		fmt.Printf("Error marshalling payload: %s\n", err.Error())
		return
	}
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonPayload))
	if err != nil {
		fmt.Printf("Error creating request: %s\n", err.Error())
		return
	}
	req.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("Error sending request: %s\n", err.Error())
		return
	}
	defer resp.Body.Close()
}
