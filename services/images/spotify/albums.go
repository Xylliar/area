package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type Album struct {
	Total int `json:"total"`
	Name string `json:"name"`
	Items []struct {
		Album Album `json:"album"`
	} `json:"items"`
}

type HandleRequestAlbum struct {
	Token string         `json:"token"`
	State map[string]int `json:"state"`
}

type HandleResponseAlbum struct {
	Triggered bool           `json:"triggered"`
	State     map[string]int `json:"state"`
	Albums    string         `json:"albums"`
}

func getAlbumsData(token string) (int, string, error) {
	url := spotifyUrl + "albums"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return 0, "", err
	}

	req.Header.Set("Authorization", "Bearer " + token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return 0, "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return 0, "", fmt.Errorf("failed to get data: %s", resp.Status)
	}

	var album Album
	err = json.NewDecoder(resp.Body).Decode(&album)
	if err != nil {
		return 0, "", err
	}

	var albumTitles []string
	for _, item := range album.Items {
		albumTitles = append(albumTitles, item.Album.Name)
	}

	albumTitlesString := strings.Join(albumTitles, " ")

	return album.Total, albumTitlesString, nil
}

func ProcessAlbumsResponse(request HandleRequestAlbum) (HandleResponseAlbum, error) {
	albumCount, albumTitlesString, err := getAlbumsData(request.Token)
	if err != nil {
		return HandleResponseAlbum{}, err
	}

	response := HandleResponseAlbum{
		State:     make(map[string]int),
		Triggered: false,
		Albums:    albumTitlesString,
	}

	if len(request.State) == 0 {
		response.State["albumCount"] = albumCount
	} else {
		currentCount := request.State["albumCount"]
		if albumCount > currentCount {
			response.Triggered = true
		}
		response.State["albumCount"] = albumCount
	}

	return response, nil
}

func checkAlbumsHandler(w http.ResponseWriter, r *http.Request) {
	var request HandleRequestAlbum
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	response, err := ProcessAlbumsResponse(request)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
