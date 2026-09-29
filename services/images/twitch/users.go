package main

import (
	"encoding/json"
	"net/http"
	"strings"
)

func banUser(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	banBody := BanUserBody{
		Data: struct {
			UserId string `json:"user_id"`
		}{
			UserId: user_id,
		},
	}
	jsonBody, err := json.Marshal(banBody)
	id := getIdUser(req.Token, w)
	url := banUrl + id + "&moderator_id=" + id
	req_get, err := http.NewRequest("POST", url, strings.NewReader(string(jsonBody)))
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	req_get.Header.Set("Content-Type", "application/json")
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func unbanUser(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	id := getIdUser(req.Token, w)
	url := banUrl + id + "&moderator_id=" + id + "&user_id=" + user_id
	req_get, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func addModerator(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	id := getIdUser(req.Token, w)
	url := addModeratorUrl + id + "&user_id=" + user_id
	req_get, err := http.NewRequest("POST", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func removeModerator(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	id := getIdUser(req.Token, w)
	url := addModeratorUrl + id + "&user_id=" + user_id
	req_get, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func addVip(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	id := getIdUser(req.Token, w)
	url := vipUrl + id + "&user_id=" + user_id
	req_get, err := http.NewRequest("POST", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func rmVip(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	id := getIdUser(req.Token, w)
	url := vipUrl + id + "&user_id=" + user_id
	req_get, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func blockUser(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	url := blockUrl + user_id
	req_get, err := http.NewRequest("PUT", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func unblockUser(w http.ResponseWriter, r *http.Request) {
	var req BanRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	user_id := getIdfromPseudo(w, req.User, req.Token)
	url := blockUrl + user_id
	req_get, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	req_get.Header.Set("Authorization", "Bearer " + req.Token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error sending request", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}
