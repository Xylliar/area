package main

import (
	"encoding/json"
	"net/http"
	"strings"
)

func sendMessage(w http.ResponseWriter, r *http.Request) {
	var req MessageRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	to_id := getIdfromPseudo(w, req.Broadcaster, req.Token)
	sender_id := getIdUser(req.Token, w)
	sendMessageBody := SendMessageBody{
		BroadcasterID: to_id,
		SenderID:      sender_id,
		Message:       req.Message,
	}
	jsonBody, err := json.Marshal(sendMessageBody)
	if err != nil {
		http.Error(w, "error marshall body", http.StatusInternalServerError)
		return
	}
	req_get, err := http.NewRequest("POST", sendMsgUrl, strings.NewReader(string(jsonBody)))
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	apiKey := "Bearer "
	apiKey += req.Token
	req_get.Header.Set("Authorization", apiKey)
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
		http.Error(w, "error from Twitch API", resp.StatusCode)
		return
	}
}

func sendAnnouncement(w http.ResponseWriter, r *http.Request) {
	var req SendAnnouncementRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	sendAnnouncementBody := SendAnnouncementBody{
		Message:       req.Message,
	}
	jsonBody, err := json.Marshal(sendAnnouncementBody)
	id := getIdUser(req.Token, w)
	url := sendAnnouncementUrl + id + "&moderator_id=" +id
	req_get, err := http.NewRequest("POST", url, strings.NewReader(string(jsonBody)))
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	apiKey := "Bearer "
	apiKey += req.Token
	req_get.Header.Set("Authorization", apiKey)
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

func sendWhisper(w http.ResponseWriter, r *http.Request) {
	var req WhisperRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	sendAnnouncementBody := SendAnnouncementBody{
		Message:       req.Message,
	}
	jsonBody, err := json.Marshal(sendAnnouncementBody)
	id := getIdUser(req.Token, w)
	to_id := getIdfromPseudo(w, req.User, req.Token)
	url := whisperUrl + id + "&to_user_id=" + to_id
	req_get, err := http.NewRequest("POST", url, strings.NewReader(string(jsonBody)))
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return
	}
	apiKey := "Bearer "
	apiKey += req.Token
	req_get.Header.Set("Authorization", apiKey)
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
