package main

import (
    "encoding/json"
    "fmt"
    "net/http"
    "github.com/bwmarrin/discordgo"
)

type AddRoleReactionInput struct {
    Token   string `json:"token"`
    GuildID string `json:"guild_id"`
    UserID  string `json:"user_id"`
    RoleID  string `json:"role_id"`
}

func addRoleReaction(w http.ResponseWriter, r *http.Request) {
    var input AddRoleReactionInput
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
    err = discord.GuildMemberRoleAdd(input.GuildID, input.UserID, input.RoleID)
    if err != nil {
        http.Error(w, fmt.Sprintf("Error adding role to user: %s", err.Error()), http.StatusBadRequest)
        return
    }
}
