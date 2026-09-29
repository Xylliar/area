package main

import (
    "encoding/json"
    "fmt"
    "net/http"
	"github.com/bwmarrin/discordgo"
)

type DisconnectVoiceChannelReactionInput struct {
	Token	string `json:"token"`
	ChannelID	string `json:"channel_id"`
}

func disconnectVoiceChannelReaction(w http.ResponseWriter, r *http.Request) {
	var input DisconnectVoiceChannelReactionInput
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
	voiceChannel, err := discord.Channel(input.ChannelID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting voice channel: %s", err.Error()), http.StatusBadRequest)
		return
	}
	for _, member := range voiceChannel.Members {
		err = discord.GuildMemberMove(voiceChannel.GuildID, member.UserID, nil)
		if err != nil {
			http.Error(w, fmt.Sprintf("Error disconnecting member: %s", err.Error()), http.StatusBadRequest)
			return
		}
	}
}
