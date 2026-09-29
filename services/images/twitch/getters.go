package main

import (
	"encoding/json"
	"io"
	"strconv"
	"net/http"
)

var followUrl = "https://api.twitch.tv/helix/channels/followers?broadcaster_id="
var clipsUrl = "https://api.twitch.tv/helix/clips?broadcaster_id="
var blocksUrl = "https://api.twitch.tv/helix/users/blocks?broadcaster_id="

type FollowRequest struct {
	NewFollowers string			`json:"new_followers"`
	Token 		string 			`json:"token"`
	State     map[string]string `json:"state"`
}

type ClipsRequest struct {
	NewClips string				`json:"new_clips"`
	Token 		string 			`json:"token"`
	State     map[string]string `json:"state"`
}

type BlockRequest struct {
	NewBlocks string			`json:"new_blocks"`
	Token 		string 			`json:"token"`
	State     map[string]string `json:"state"`
}

type DataBody struct {
	Total 	int						`json:"total"`
	Users 	[]UserData				`json:"data"`
}

type ClipsBody struct {
	Clip 	[]ClipData				`json:"data"`
}

type ClipData struct {
	Url 		string `json:"url"`
}

type UserData struct {
	UserId 		string `json:"user_id"`
	UserName 	string `json:"user_name"`
	UserLogin 	string `json:"user_login"`
	DisplayName string `json:"display_name"`
}

func getFollowers(w http.ResponseWriter, r *http.Request) {
	var req FollowRequest
	var follow_body DataBody

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	id := getIdUser(req.Token, w)
	url := followUrl + id
	req_get, err := http.NewRequest("GET", url, nil)
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
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "error with json body read", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &follow_body)
	if err != nil {
		http.Error(w, "error with json data", http.StatusInternalServerError)
		return
	}
	if (req.State["total"] == "") {
		req.State["total"] = strconv.Itoa(follow_body.Total)
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	last_total, err := strconv.Atoi(req.State["total"])
	new_follows := ""
	if (last_total < follow_body.Total) {
		new_follows += follow_body.Users[0].UserName
		for i := 1; i < (follow_body.Total - last_total); i++ {
			new_follows += ", " + follow_body.Users[i].UserName
		}
		req.State["total"] = strconv.Itoa(follow_body.Total)
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": true,
			"state":     req.State,
			"new_followers": new_follows,
		})
		return
	}
	req.State["total"] = strconv.Itoa(follow_body.Total)
	json.NewEncoder(w).Encode(map[string]interface{} {
		"triggered": false,
		"state":     req.State,
	})
	return
}

func getClips(w http.ResponseWriter, r *http.Request) {
	var req ClipsRequest
	var clip_body ClipsBody

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	id := getIdUser(req.Token, w)
	url := clipsUrl + id
	req_get, err := http.NewRequest("GET", url, nil)
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
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "error with json body read", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &clip_body)
	if err != nil {
		http.Error(w, "error with json data", http.StatusInternalServerError)
		return
	}
	if (req.State["total"] == "") {
		req.State["total"] = strconv.Itoa(len(clip_body.Clip))
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	nb_clips, err := strconv.Atoi(req.State["total"])
	if err != nil {
		http.Error(w, "error with json data", http.StatusInternalServerError)
		return
	}
	new_clips := ""
	if (nb_clips < len(clip_body.Clip)) {
		new_clips += clip_body.Clip[0].Url
		for i := 1; i < len(clip_body.Clip) - nb_clips; i++ {
			new_clips += ", " + clip_body.Clip[i].Url
		}
		req.State["total"] = strconv.Itoa(len(clip_body.Clip))
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": true,
			"state":     req.State,
			"new_clips": new_clips,
		})
		return
	}
	req.State["total"] = strconv.Itoa(len(clip_body.Clip))
	json.NewEncoder(w).Encode(map[string]interface{} {
		"triggered": false,
		"state":     req.State,
	})
	return
}

func getBlocks(w http.ResponseWriter, r *http.Request) {
	var req BlockRequest
	var block_body DataBody

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	id := getIdUser(req.Token, w)
	url := blocksUrl + id
	req_get, err := http.NewRequest("GET", url, nil)
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
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "error with json body read", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &block_body)
	if err != nil {
		http.Error(w, "error with json data", http.StatusInternalServerError)
		return
	}
	if (req.State["total"] == "") {
		req.State["total"] = strconv.Itoa(len(block_body.Users))
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	nb_blocks, err := strconv.Atoi(req.State["total"])
	if err != nil {
		http.Error(w, "error with json data", http.StatusInternalServerError)
		return
	}
	new_blocks := ""
	if (nb_blocks < len(block_body.Users)) {
		new_blocks += block_body.Users[0].DisplayName
		for i := 1; i < len(block_body.Users) - nb_blocks; i++ {
			new_blocks += ", " + block_body.Users[i].DisplayName
		}
		req.State["total"] = strconv.Itoa(len(block_body.Users))
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": true,
			"state":     req.State,
			"new_blocks": new_blocks,
		})
		return
	}
	req.State["total"] = strconv.Itoa(len(block_body.Users))
	json.NewEncoder(w).Encode(map[string]interface{} {
		"triggered": false,
		"state":     req.State,
	})
	return
}
