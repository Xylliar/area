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

type CreateBranchActionInput struct {
	AppletId string `json:"applet_id"`
	State	map[string]string	`json:"state"`
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
}

type CreateBranchActionOutput struct {
	Branch string `json:"branch"`
	MasterBranch string `json:"master_branch"`
	Description string `json:"description"`
	PusherType string `json:"pusher_type"`
}

func createCreateBranchActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input CreateBranchActionInput
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
	callback, ok := callbackURL(w, "/github/create_branch_action/callback/"+action_input.AppletId)
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
		Events: []string{"create"},
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

func deleteCreateBranchActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input CreateBranchActionInput
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

func createBranchActionCallback(w http.ResponseWriter, r *http.Request) {
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
	createBranchEvent, ok := event.(*github.CreateEvent)
	if !ok {
		http.Error(w, "Received unexpected event type", http.StatusBadRequest)
		return
	}
	branch := createBranchEvent.GetRef()
	masterBranch := createBranchEvent.GetMasterBranch()
	description := createBranchEvent.GetDescription()
	pusherType := createBranchEvent.GetPusherType()
	output := CreateBranchActionOutput{
		Branch: branch,
		MasterBranch: masterBranch,
		Description: description,
		PusherType: pusherType,
	}
	triggerReactions(appletId, output)
}
