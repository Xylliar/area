package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "github.com/bwmarrin/discordgo"
)

type KickReactionInput struct {
    Token    string `json:"token"`
    UserID   string `json:"user_id"`
    GuildID  string `json:"guild_id"`
}

func kickReaction(w http.ResponseWriter, r *http.Request) {
    var input KickReactionInput
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
    err = discord.GuildMemberDelete(input.GuildID, input.UserID)
    if err != nil {
        http.Error(w, fmt.Sprintf("Error kicking user: %s", err.Error()), http.StatusBadRequest)
        return
    }
}
