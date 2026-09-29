package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"github.com/google/go-github/v66/github"
	"golang.org/x/oauth2"
	"strconv"
	"github.com/gorilla/mux"
)

type PushActionInput struct {
	AppletId string `json:"applet_id"`
	State	map[string]string	`json:"state"`
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
}

type PushActionOutput struct {
	PusherName     string `json:"pusher_name"`
	PusherEmail    string `json:"pusher_email"`
	CommitsDetails string `json:"commits_details"`
}

func createPushActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input PushActionInput
	err := json.NewDecoder(r.Body).Decode(&action_input)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: action_input.Token},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)
	callback, ok := callbackURL(w, "/github/push_action/callback/"+action_input.AppletId)
	if !ok {
		return
	}
	hookConfig := &github.HookConfig{
		URL:         github.String(callback),
		ContentType: github.String("json"),
	}
	hook := &github.Hook{
		Name:   github.String("web"),
		Active: github.Bool(true),
		Events: []string{"push"},
		Config: hookConfig,
	}
	createdHook, _, err := client.Repositories.CreateHook(ctx, action_input.Owner, action_input.Repo, hook)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating webhook: %s", err.Error()), http.StatusBadRequest)
		return
	}
	state := make(map[string]string)
	state["webhook_id"] = strconv.FormatInt(*createdHook.ID, 10)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"state":	state,
	})
}

func deletePushActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input PushActionInput
	err := json.NewDecoder(r.Body).Decode(&action_input)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	if _, exists := action_input.State["webhook_id"]; !exists {
		http.Error(w, "No webhook ID in state", http.StatusBadRequest)
		return
	}
	webhookID, err := strconv.ParseInt(action_input.State["webhook_id"], 10, 64)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error parsing webhook ID: %s", err.Error()), http.StatusBadRequest)
		return
	}
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: action_input.Token},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)
	_, err = client.Repositories.DeleteHook(ctx, action_input.Owner, action_input.Repo, webhookID)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error deleting webhook: %s", err.Error()), http.StatusBadRequest)
	}
}

func pushActionCallback(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	appletId := vars["applet_id"]
	payload, err := github.ValidatePayload(r, nil)
	if err != nil {
		http.Error(w, "Invalid payload", http.StatusBadRequest)
		return
	}
	event, err := github.ParseWebHook(github.WebHookType(r), payload)
	if err != nil {
		http.Error(w, "Could not parse webhook", http.StatusBadRequest)
		return
	}
	pushEvent, ok := event.(*github.PushEvent)
	if !ok {
		http.Error(w, "Received unexpected event type", http.StatusBadRequest)
		return
	}
	pusherName := pushEvent.GetPusher().GetName()
	pusherEmail := pushEvent.GetPusher().GetEmail()
	commitsDetails := "Commits:\n\n"
	for _, commit := range pushEvent.Commits {
		authorName := commit.GetAuthor().GetName()
		authorEmail := commit.GetAuthor().GetEmail()
		commitsDetails += fmt.Sprintf("Commit ID: %s\n", commit.GetID())
		commitsDetails += fmt.Sprintf("Commit Message: %s\n", commit.GetMessage())
		commitsDetails += fmt.Sprintf("Author: %s (%s)\n\n", authorName, authorEmail)
	}
	output := PushActionOutput{
		PusherName:     pusherName,
		PusherEmail:    pusherEmail,
		CommitsDetails: commitsDetails,
	}
	triggerReactions(appletId, output)
}
