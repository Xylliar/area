package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

// Must be the client id of the Twitch application that issued the user tokens (same as the server's TWITCH_CLIENT_ID).
var twitchClientID = os.Getenv("TWITCH_CLIENT_ID")

var sendMsgUrl = "https://api.twitch.tv/helix/chat/messages"
var sendAnnouncementUrl = "https://api.twitch.tv/helix/chat/announcements?broadcaster_id="
var createClipUrl = "https://api.twitch.tv/helix/clips?broadcaster_id="
var banUrl = "https://api.twitch.tv/helix/moderation/bans?broadcaster_id="
var addModeratorUrl = "https://api.twitch.tv/helix/moderation/moderators?broadcaster_id="
var vipUrl = "https://api.twitch.tv/helix/channels/vips?broadcaster_id="
var blockUrl = "https://api.twitch.tv/helix/users/blocks?target_user_id="
var whisperUrl = "https://api.twitch.tv/helix/whispers?from_user_id="

type MessageRequest struct {
	Token		   	string			`json:"token"`
	Message 		string 			`json:"message"`
	Broadcaster string           `json:"broadcaster"`
}

type SendAnnouncementRequest struct {
	Token		   	string			`json:"token"`
	Message 		string 			`json:"message"`
}

type SendAnnouncementBody struct {
	Message 		string 			`json:"message"`
}

type BanRequest struct {
	Token		   	string			`json:"token"`
	User 			string          `json:"user"`
}

type WhisperRequest struct {
	Token		   	string			`json:"token"`
	User 			string          `json:"user"`
	Message 		string			`json:"message"`
}

type BanUserBody struct {
	Data struct {
		UserId 	string `json:"user_id"`
	} `json:"data"`
}

type SendMessageBody struct {
	BroadcasterID string `json:"broadcaster_id"`
	SenderID      string `json:"sender_id"`
	Message       string `json:"message"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func createClip(w http.ResponseWriter, r *http.Request) {
	var req MessageRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	id := getIdfromPseudo(w, req.Broadcaster, req.Token)
	req_get, err := http.NewRequest("POST", createClipUrl + id, nil)
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
	if resp.StatusCode != 202 {
		http.Error(w, "error from twitch API", resp.StatusCode)
		return
	}
}

func main() {
	http.HandleFunc("/twitch/send_message", sendMessage)
	http.HandleFunc("/twitch/send_announcement", sendAnnouncement)
	http.HandleFunc("/twitch/create_clip", createClip)
	http.HandleFunc("/twitch/ban_user", banUser)
	http.HandleFunc("/twitch/unban_user", unbanUser)
	http.HandleFunc("/twitch/add_moderator", addModerator)
	http.HandleFunc("/twitch/rm_moderator", removeModerator)
	http.HandleFunc("/twitch/add_vip", addVip)
	http.HandleFunc("/twitch/rm_vip", rmVip)
	http.HandleFunc("/twitch/block_user", blockUser)
	http.HandleFunc("/twitch/unblock_user", unblockUser)
	http.HandleFunc("/twitch/send_whisper", sendWhisper)
	http.HandleFunc("/twitch/health", healthHandler)

	http.HandleFunc("/twitch/get_followers", getFollowers)
	http.HandleFunc("/twitch/get_clips", getClips)
	http.HandleFunc("/twitch/get_blocks", getBlocks)
	http.ListenAndServe(":8000", nil)
}
