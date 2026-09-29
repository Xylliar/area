package main

import (
	"encoding/json"
	"net/http"
    "fmt"
    "strconv"
)

type PlayerStats struct {
    ChessRapid struct {
        Last struct {
            Rating int `json:"rating"`
        } `json:"last"`
    } `json:"chess_rapid"`
    ChessBullet struct {
        Last struct {
            Rating int `json:"rating"`
        } `json:"last"`
    } `json:"chess_bullet"`
}

type TriggerRequest struct {
    PlayerName string            `json:"playername"`
    Gamemode   string            `json:"gamemode"`
    State      map[string]string `json:"state"`
}

func fetchPlayerStats(playerName string) (*PlayerStats, error) {
    url := fmt.Sprintf("https://api.chess.com/pub/player/%s/stats", playerName)

    request, err := http.NewRequest("GET", url, nil)
    if err != nil {
        return nil, fmt.Errorf("erreur lors de la requête: %v", err)
    }
    // Chess.com rejects the default Go user agent with a 403.
    request.Header.Set("User-Agent", "area-chess-tracker/1.0")
    resp, err := http.DefaultClient.Do(request)
    if err != nil {
        return nil, fmt.Errorf("erreur lors de la requête: %v", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("erreur: statut de réponse %s", resp.Status)
    }

    var stats PlayerStats
    if err := json.NewDecoder(resp.Body).Decode(&stats); err != nil {
        return nil, fmt.Errorf("erreur lors du décodage JSON: %v", err)
    }

    return &stats, nil
}

func handlePlayerStats(w http.ResponseWriter, r *http.Request) {
    var req TriggerRequest

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request payload", http.StatusBadRequest)
        return
    }

    stats, err := fetchPlayerStats(req.PlayerName)
    if err != nil {
        http.Error(w, fmt.Sprintf("Erreur: %v", err), http.StatusInternalServerError)
        return
    }

    var currentRating int
    switch req.Gamemode {
    case "chess_rapid":
        currentRating = stats.ChessRapid.Last.Rating
    case "chess_bullet":
        currentRating = stats.ChessBullet.Last.Rating
    default:
        http.Error(w, "Invalid gamemode", http.StatusBadRequest)
        return
    }

    previousRating := 0
    if storedRating, exists := req.State["Rating"]; exists {
        previousRating, err = strconv.Atoi(storedRating)
        if err != nil {
            http.Error(w, "Invalid stored rating value", http.StatusBadRequest)
            return
        }
    }

    req.State["Rating"] = strconv.Itoa(currentRating)
    
    if currentRating > previousRating {
        json.NewEncoder(w).Encode(map[string]interface{}{
            "triggered": true,
            "state":     req.State,
        })
        return
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
    http.HandleFunc("/chess-tracker/get-stats", handlePlayerStats)
    http.HandleFunc("/chess-tracker/health", healthHandler)
    http.ListenAndServe(":8000", nil)
}
