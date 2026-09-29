package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type Audiobook struct {
	Total int `json:"total"`
	Name  string `json:"name"`
	Items []struct {
		Audiobook Audiobook `json:"audiobook"`
	} `json:"items"`
}

type HandleRequestAudiobook struct {
	Token string         `json:"token"`
	State map[string]int `json:"state"`
}

type HandleResponseAudiobook struct {
	Triggered bool           `json:"triggered"`
	State     map[string]int `json:"state"`
	Audiobooks string        `json:"audiobooks"`
}

func getAudiobooksData(token string) (int, string, error) {
	url := spotifyUrl + "audiobooks"

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

	var audiobook Audiobook
	err = json.NewDecoder(resp.Body).Decode(&audiobook)
	if err != nil {
		return 0, "", err
	}

	var audiobookTitles []string
	for _, item := range audiobook.Items {
		audiobookTitles = append(audiobookTitles, item.Audiobook.Name)
	}

	audiobookTitlesString := strings.Join(audiobookTitles, " ")

	return audiobook.Total, audiobookTitlesString, nil
}

func ProcessAudiobooksResponse(request HandleRequestAudiobook) (HandleResponseAudiobook, error) {
	audiobookCount, audiobookTitlesString, err := getAudiobooksData(request.Token)
	if err != nil {
		return HandleResponseAudiobook{}, err
	}

	response := HandleResponseAudiobook{
		State:     make(map[string]int),
		Triggered: false,
		Audiobooks: audiobookTitlesString,
	}

	if len(request.State) == 0 {
		response.State["audiobookCount"] = audiobookCount
	} else {
		currentCount := request.State["audiobookCount"]
		if audiobookCount > currentCount {
			response.Triggered = true
		}
		response.State["audiobookCount"] = audiobookCount
	}

	return response, nil
}

func checkAudiobooksHandler(w http.ResponseWriter, r *http.Request) {
	var request HandleRequestAudiobook
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	response, err := ProcessAudiobooksResponse(request)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
