package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
)

type Show struct {
	Total int `json:"total"`
	Name string `json:"name"`
	Items []struct {
		Show Show `json:"show"`
	} `json:"items"`
}

type HandleRequestShow struct {
	Token string `json:"token"`
	State map[string]int `json:"state"`
}

type HandleResponseShow struct {
	Triggered bool   `json:"triggered"`
	State     map[string]int `json:"state"`
	Shows     string `json:"shows"`
}

func getShowsData(token string) (int, string, error) {
	url := spotifyUrl + "shows"

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

	var show Show
	err = json.NewDecoder(resp.Body).Decode(&show)
	if err != nil {
		return 0, "", err
	}

	var showTitles []string
	for _, item := range show.Items {
		showTitles = append(showTitles, item.Show.Name)
	}

	showTitlesString := strings.Join(showTitles, " ")

	return show.Total, showTitlesString, nil
}

func ProcessShowResponse(request HandleRequestShow) (HandleResponseShow, error) {
	showCount, showTitlesString, err := getShowsData(request.Token)
	if err != nil {
		return HandleResponseShow{}, err
	}

	response := HandleResponseShow{
		State: make(map[string]int),
		Triggered: false,
		Shows: showTitlesString,
	}

	if len(request.State) == 0 {
		response.State["showCount"] = showCount
	} else {
		currentCount := request.State["showCount"]
		if showCount > currentCount {
			response.Triggered = true
		}
		response.State["showCount"] = showCount
	}

	return response, nil
}

func checkShowsHandler(w http.ResponseWriter, r *http.Request) {
	var request HandleRequestShow
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	response, err := ProcessShowResponse(request)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
