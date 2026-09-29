package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

type Playlist struct {
	Total int `json:"total"`
}

type HandleRequestPlaylist struct {
	Token string         `json:"token"`
	State map[string]int `json:"state"`
}

type HandleResponsePlaylist struct {
	Triggered bool           `json:"triggered"`
	State     map[string]int `json:"state"`
}

func getPlaylistsData(token string) (int, error) {
	url := spotifyUrl + "playlists"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return 0, err
	}

	req.Header.Set("Authorization", "Bearer " + token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return 0, fmt.Errorf("failed to get data: %s", resp.Status)
	}

	var playlist Playlist
	err = json.NewDecoder(resp.Body).Decode(&playlist)
	if err != nil {
		return 0, err
	}

	return playlist.Total, nil
}

func ProcessPlaylistsResponse(request HandleRequestPlaylist) (HandleResponsePlaylist, error) {
	playlistCount, err := getPlaylistsData(request.Token)
	if err != nil {
		return HandleResponsePlaylist{}, err
	}

	response := HandleResponsePlaylist{
		State:     make(map[string]int),
		Triggered: false,
	}

	if len(request.State) == 0 {
		response.State["playlistCount"] = playlistCount
	} else {
		currentCount := request.State["playlistCount"]
		if playlistCount > currentCount {
			response.Triggered = true
		}
		response.State["playlistCount"] = playlistCount
	}

	return response, nil
}

func checkPlaylistsHandler(w http.ResponseWriter, r *http.Request) {
	var request HandleRequestPlaylist
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	response, err := ProcessPlaylistsResponse(request)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
