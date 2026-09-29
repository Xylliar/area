package main

import (
	"net/http"
	"encoding/json"
	"io"
)

var userUrl = "https://api.twitch.tv/helix/users"

type GetUserBody struct {
	User []Users 				`json:"data"`
}

type Users struct {
	Id 	string `json:"id"`
}

func getIdfromPseudo (w http.ResponseWriter, broadcaster string, token string) string {
	var usersdata GetUserBody
	req_get, err := http.NewRequest("GET", userUrl + "?login=" + broadcaster, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return err.Error()
	}
	req_get.Header.Set("Authorization", "Bearer " + token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return "error"
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch api", resp.StatusCode)
		return "error"
	}
	body, err := io.ReadAll(resp.Body)
	err = json.Unmarshal(body, &usersdata)
	return usersdata.User[0].Id
}

func getIdUser (token string, w http.ResponseWriter) string {
	var usersdata GetUserBody
	req_get, err := http.NewRequest("GET", userUrl, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return err.Error()
	}
	req_get.Header.Set("Authorization", "Bearer " + token)
	req_get.Header.Set("Client-Id", twitchClientID)
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return "error"
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return "error"
	}
	body, err := io.ReadAll(resp.Body)
	err = json.Unmarshal(body, &usersdata)
	return usersdata.User[0].Id
}
