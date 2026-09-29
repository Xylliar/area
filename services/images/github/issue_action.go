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

type IssueActionInput struct {
	AppletId string `json:"applet_id"`
	State	map[string]string	`json:"state"`
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
}

type IssueActionOutput struct {
	Action string `json:"action"`
	Id string `json:"id"`
	Number string `json:"number"`
	Title string `json:"title"`
	Body string `json:"body"`
	IssueState string `json:"issue_state"`
	User string `json:"user"`
	Labels string `json:"labels"`
	Assignees string `json:"assignees"`
	Create_at string `json:"create_at"`
	Update_at string `json:"update_at"`
}

func createIssueActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input IssueActionInput
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
	callback, ok := callbackURL(w, "/github/issue_action/callback/"+action_input.AppletId)
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
		Events: []string{"issues"},
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

func deleteIssueActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input IssueActionInput
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

func issueActionCallback(w http.ResponseWriter, r *http.Request) {
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
	issueEvent, ok := event.(*github.IssuesEvent)
	if !ok {
		http.Error(w, "Received unexpected event type", http.StatusBadRequest)
		return
	}
	action := issueEvent.GetAction()
	id := issueEvent.GetIssue().GetID()
	number := issueEvent.GetIssue().GetNumber()
	title := issueEvent.GetIssue().GetTitle()
	body := issueEvent.GetIssue().GetBody()
	issueState := issueEvent.GetIssue().GetState()
	user := issueEvent.GetIssue().GetUser().GetLogin()
	labels := issueEvent.GetIssue().Labels
	labels_str := ""
	for _, label := range labels {
		labels_str += label.GetName() + ", "
	}
	if len(labels_str) > 0 {
		labels_str = labels_str[:len(labels_str)-2]
	}
	assignees := issueEvent.GetIssue().Assignees
	assignees_str := ""
	for _, assignee := range assignees {
		assignees_str += assignee.GetLogin() + ", "
	}
	if len(assignees_str) > 0 {
		assignees_str = assignees_str[:len(assignees_str)-2]
	}
	create_at := issueEvent.GetIssue().GetCreatedAt().String()
	update_at := issueEvent.GetIssue().GetUpdatedAt().String()
	output := IssueActionOutput{
		Action: action,
		Id: strconv.FormatInt(id, 10),
		Number: strconv.Itoa(number),
		Title: title,
		Body: body,
		IssueState: issueState,
		User: user,
		Labels: labels_str,
		Assignees: assignees_str,
		Create_at: create_at,
		Update_at: update_at,
	}
	triggerReactions(appletId, output)
}
