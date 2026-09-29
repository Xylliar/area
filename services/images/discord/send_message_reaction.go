package main

import (
    "encoding/json"
    "fmt"
    "net/http"
	"github.com/bwmarrin/discordgo"
)

type SendMessageReactionInput struct {
	Token	string `json:"token"`
	ChannelID	string `json:"channel_id"`
	Content string `json:"content"`
}

func sendMessageReaction(w http.ResponseWriter, r *http.Request) {
	var input SendMessageReactionInput
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	discord, err := discordgo.New("Bearer " + input.Token)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating Discord session: %s", err.Error()), http.StatusBadRequest)
		return
	}
	_, err = discord.ChannelMessageSend(input.ChannelID, input.Content)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error sending message: %s", err.Error()), http.StatusBadRequest)
		return
	}
}
