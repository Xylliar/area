package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"golang.org/x/oauth2"
)

func getClient(accessToken string) (*http.Client, error) {
    token := &oauth2.Token{AccessToken: accessToken}
	tokenSource := oauth2.StaticTokenSource(token)
	client := oauth2.NewClient(context.Background(), tokenSource)
    return client, nil
}

func PlayNext(w http.ResponseWriter, r *http.Request) {
	var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

	req, err := http.NewRequest("POST", spotifyUrl + "player/next", nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer " + payload.Token)
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		log.Println(resp)
		http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func PlayPrevious(w http.ResponseWriter, r *http.Request) {
	var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

	req, err := http.NewRequest("POST", spotifyUrl + "player/previous", nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer " + payload.Token)
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		log.Println(resp)
		http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func Pause(w http.ResponseWriter, r *http.Request) {
	var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

	req, err := http.NewRequest("PUT", spotifyUrl + "player/pause", nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer " + payload.Token)
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		log.Println(resp)
		http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func Play(w http.ResponseWriter, r *http.Request) {
	var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

	deviceID, err := getDeviceID(payload.Token)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	req, err := http.NewRequest("PUT", fmt.Sprintf(spotifyUrl + "player/play?=device_id=%s", deviceID), nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer " + payload.Token)
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		log.Println(resp)
		http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func Start(w http.ResponseWriter, r *http.Request) {
	var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

	deviceID, err := getDeviceID(payload.Token)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnauthorized)
		return
	}

	req, err := http.NewRequest("PUT", fmt.Sprintf(spotifyUrl + "player/seek?position_ms=0&device_id=%s", deviceID), nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header.Set("Authorization", "Bearer " + payload.Token)
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		log.Println(resp)
		http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
		return
	}
    Play(w, r)
	w.WriteHeader(http.StatusNoContent)
}

func Repeat(w http.ResponseWriter, r *http.Request) {
    var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

    req, err := http.NewRequest("PUT", spotifyUrl + "player/repeat?state=track", nil)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    req.Header.Set("Authorization", "Bearer " + payload.Token)
    resp, err := client.Do(req)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusNoContent {
        log.Println(resp)
        http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
        return
    }

    w.WriteHeader(http.StatusNoContent)
}

func TogglePlaybackSuffle(w http.ResponseWriter, r *http.Request) {
    var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" {
        http.Error(w, "Missing required fields: token ", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

    req, err := http.NewRequest("PUT", spotifyUrl + "player/shuffle?state=true", nil)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    req.Header.Set("Authorization", "Bearer " + payload.Token)
    resp, err := client.Do(req)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusNoContent {
        log.Println(resp)
        http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), http.StatusForbidden)
        return
    }

    w.WriteHeader(http.StatusNoContent)
}

func AddItemToQueue(w http.ResponseWriter, r *http.Request) {
    var payload SpotifyUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" || payload.Uri == "" {
        http.Error(w, "Missing required fields: token and uri", http.StatusBadRequest)
        return
    }
	
	client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

    req, err := http.NewRequest("POST", fmt.Sprintf(spotifyUrl + "player/queue?uri=%s", payload.Uri), nil)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    req.Header.Set("Authorization", "Bearer " + payload.Token)
    resp, err := client.Do(req)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    defer resp.Body.Close()
    if resp.StatusCode != http.StatusOK{
        http.Error(w, fmt.Sprintf("access forbidden: %v", resp.Status), resp.StatusCode)
        return
    }

    w.WriteHeader(http.StatusNoContent)
}
