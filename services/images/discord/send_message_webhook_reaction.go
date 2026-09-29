package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type SendMessageWebhookReactionInput struct {
    WebhookUrl     string `json:"webhook_url"`
    Content string `json:"content"`
}

func sendMessageWebhookReaction(w http.ResponseWriter, r *http.Request) {
    fmt.Println(w, r)
    var input SendMessageWebhookReactionInput
    err := json.NewDecoder(r.Body).Decode(&input)
    if err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }
    discordPayload := map[string]string{
        "content": input.Content,
    }
    discordPayloadBytes, err := json.Marshal(discordPayload)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    req, err := http.NewRequest("POST", input.WebhookUrl, bytes.NewBuffer(discordPayloadBytes))
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    req.Header.Set("Content-Type", "application/json")
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()
    body, err := io.ReadAll(resp.Body)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(resp.StatusCode)
    w.Write(body)
}
