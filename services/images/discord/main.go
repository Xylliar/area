package main

import (
    "fmt"
    "net/http"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/discord/health", healthHandler)
    http.HandleFunc("/discord/new_messages_action", newMessagesAction)
    http.HandleFunc("/discord/send_message_webhook_reaction", sendMessageWebhookReaction)
    http.HandleFunc("/discord/send_message_reaction", sendMessageReaction)
    http.HandleFunc("/discord/disconnect_voice_channel_reaction", disconnectVoiceChannelReaction)
    http.HandleFunc("/discord/add_role_reaction", addRoleReaction)
    http.HandleFunc("/discord/kick_reaction", kickReaction)

    err := http.ListenAndServe(":8000", nil)
    if err != nil {
        fmt.Printf("Error starting server: %s\n", err)
    }
}
