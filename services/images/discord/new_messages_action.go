package main

import (
    "encoding/json"
    "fmt"
    "net/http"
	"github.com/bwmarrin/discordgo"
)

type NewMessagesActionInput struct {
	Token	string `json:"token"`
	State	map[string]string	`json:"state"`
	ChannelID	string `json:"channel_id"`
}

type NewMessagesActionOutputFalse struct {
	Triggered	bool `json:"triggered"`
	State	map[string]string	`json:"state"`
}

type NewMessagesActionOutputTrue struct {
	Triggered	bool `json:"triggered"`
	State	map[string]string	`json:"state"`
	Messages	string `json:"messages"`
}

func newMessagesAction(w http.ResponseWriter, r *http.Request) {
	var input NewMessagesActionInput
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
	messages, err := discord.ChannelMessages(input.ChannelID, 100, "", "", "")
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting messages: %s", err.Error()), http.StatusBadRequest)
		return
	}
	lastMessageID, exists := input.State["last_message_id"]
	if !exists {
		if len(messages) == 0 {
			output := NewMessagesActionOutputFalse{
				Triggered: false,
				State: input.State,
			}
			json.NewEncoder(w).Encode(output)
			return
		}
		lastMessageID = messages[0].ID
		input.State["last_message_id"] = lastMessageID
	}
	if messages[0].ID != lastMessageID {
		var newMessages string
		input.State["last_message_id"] = messages[0].ID
		for _, message := range messages {
			if exists && message.ID == lastMessageID {
				break
			}
			newMessages += fmt.Sprintf("%s: %s\n", message.Author.Username, message.Content)
		}
		output := NewMessagesActionOutputTrue{
			Triggered: true,
			State: input.State,
			Messages: newMessages,
		}
		json.NewEncoder(w).Encode(output)
		return
	}
	output := NewMessagesActionOutputFalse{
		Triggered: false,
		State: input.State,
	}
	json.NewEncoder(w).Encode(output)
}
