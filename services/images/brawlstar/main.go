package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
)

var brawlstarUrl = "https://api.brawlstars.com/v1/"

type TriggerRequest struct {
	PlayerTag string            `json:"playertag"`
	State     map[string]string `json:"state"`
	NewTrophies string			`json:"new_trophies"`
}

type EventRequest struct {
	NewMap string             `json:"new_maps"`
	State  map[int]Event `json:"state"`
}

type Player struct {
	Tag           string `json:"tag"`
	Name          string `json:"name"`
	Trophies      int    `json:"trophies"`
	HighestTrophies int    `json:"highestTrophies"`
}

type Event struct {
    EventData struct {
        Mode string `json:"mode"`
        Map  string `json:"map"`
    } `json:"event"`
}

func getBodyRequest(url string, w http.ResponseWriter) ([]byte, error) {
	req_get, err := http.NewRequest("GET", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return nil, nil
	}
	apiKey := os.Getenv("API_KEY")
	if apiKey == "" {
		http.Error(w, "brawlstar key not set", http.StatusInternalServerError)
		return nil, nil
	}
	req_get.Header.Set("Authorization", "Bearer "+apiKey)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return nil, nil
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from Brawlstars API", resp.StatusCode)
		return nil, nil
	}
	return io.ReadAll(resp.Body)
}

func checkTrophies(w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var player Player
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	url := brawlstarUrl + "players/%23" + strings.TrimPrefix(req.PlayerTag, "#")
	body, err := getBodyRequest(url, w)
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &player)
	if err != nil {
		http.Error(w, "error with json", http.StatusInternalServerError)
		return
	}
	if req.State["trophies"] == "" {
		req.State["trophies"] = strconv.Itoa(player.HighestTrophies)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	currentTrophies, err := strconv.Atoi(req.State["trophies"])
	if err != nil {
		http.Error(w, "Invalid trophies value in state", http.StatusBadRequest)
		return
	}
	if currentTrophies < player.HighestTrophies {
		req.State["trophies"] = strconv.Itoa(player.HighestTrophies)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"new_trophies": strconv.Itoa(player.HighestTrophies),
			"triggered": true,
			"state":     req.State,
		})
		return
	} else {
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": false,
			"state":     req.State,
		})
		return
	}
}

func checkMap(w http.ResponseWriter, r *http.Request) {
	var req EventRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	url := brawlstarUrl + "events/rotation"
	body, err := getBodyRequest(url, w);
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return
	}
	var events []Event
	err = json.Unmarshal(body, &events)
	if err != nil {
		http.Error(w, "error with json: "+err.Error(), http.StatusInternalServerError)
		return
	}
	if len(req.State) == 0 {
		for i, event := range events {
			req.State[i] = Event{
				EventData: struct {
					Mode string `json:"mode"`
					Map  string `json:"map"`
				}{
					Mode: event.EventData.Mode,
					Map:  event.EventData.Map,
				},
			}
		}
	}
	mapChanged := ""
	for i, event := range events {
		if req.State[i].EventData.Map != event.EventData.Map {
			tmp := req.State[i]
			tmp.EventData.Map = event.EventData.Map
			tmp.EventData.Mode = event.EventData.Mode
			req.State[i] = tmp
			mapChanged += "(" + event.EventData.Map + ", " + event.EventData.Mode + ") "
		}
	}
	if mapChanged != "" {
		req.NewMap = mapChanged
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": true,
			"new_maps":  mapChanged,
			"state":     req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{}{
		"triggered": false,
		"state":     req.State,
	})
	return
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/brawlstar/health", healthHandler)
	http.HandleFunc("/brawlstar/check_trophies", checkTrophies)
	http.HandleFunc("/brawlstar/check_map", checkMap)
	http.ListenAndServe(":8000", nil)
}
