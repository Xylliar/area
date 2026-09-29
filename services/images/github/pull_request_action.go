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

type PullRequestActionInput struct {
	AppletId string `json:"applet_id"`
	State	map[string]string	`json:"state"`
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
}

type PullRequestActionOutput struct {
	Action string `json:"action"`
	Title string `json:"title"`
	Body string `json:"body"`
	PullRequestState string `json:"pull_request_state"`
	User string `json:"user"`
	Reviewers string `json:"reviewers"`
	Assignees string `json:"assignees"`
	Labels string `json:"labels"`
	Create_at string `json:"create_at"`
	Update_at string `json:"update_at"`
	Closed_at string `json:"closed_at"`
	Merged_at string `json:"merged_at"`	
}

func createPullRequestActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input PullRequestActionInput
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
	callback, ok := callbackURL(w, "/github/pull_request_action/callback/"+action_input.AppletId)
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
		Events: []string{"pull_request"},
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

func deletePullRequestActionWebhook(w http.ResponseWriter, r *http.Request) {
	var action_input PullRequestActionInput
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

func pullRequestActionCallback(w http.ResponseWriter, r *http.Request) {
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
	pullRequestEvent, ok := event.(*github.PullRequestEvent)
	if !ok {
		http.Error(w, "Received unexpected event type", http.StatusBadRequest)
		return
	}
	action := pullRequestEvent.GetAction()
	title := pullRequestEvent.GetPullRequest().GetTitle()
	body := pullRequestEvent.GetPullRequest().GetBody()
	pullRequestState := pullRequestEvent.GetPullRequest().GetState()
	user := pullRequestEvent.GetPullRequest().GetUser().GetLogin()
	reviewers := pullRequestEvent.GetPullRequest().RequestedReviewers
	reviewers_str := ""
	for _, reviewer := range reviewers {
		reviewers_str += reviewer.GetLogin() + ", "
	}
	if len(reviewers_str) > 0 {
		reviewers_str = reviewers_str[:len(reviewers_str)-2]
	}
	assignees := pullRequestEvent.GetPullRequest().Assignees
	assignees_str := ""
	for _, assignee := range assignees {
		assignees_str += assignee.GetLogin() + ", "
	}
	if len(assignees_str) > 0 {
		assignees_str = assignees_str[:len(assignees_str)-2]
	}
	labels := pullRequestEvent.GetPullRequest().Labels
	labels_str := ""
	for _, label := range labels {
		labels_str += label.GetName() + ", "
	}
	if len(labels_str) > 0 {
		labels_str = labels_str[:len(labels_str)-2]
	}
	create_at := pullRequestEvent.GetPullRequest().GetCreatedAt().String()
	update_at := pullRequestEvent.GetPullRequest().GetUpdatedAt().String()
	closed_at := pullRequestEvent.GetPullRequest().GetClosedAt().String()
	merged_at := pullRequestEvent.GetPullRequest().GetMergedAt().String()
	output := PullRequestActionOutput{
		Action: action,
		Title: title,
		Body: body,
		PullRequestState: pullRequestState,
		User: user,
		Reviewers: reviewers_str,
		Assignees: assignees_str,
		Labels: labels_str,
		Create_at: create_at,
		Update_at: update_at,
		Closed_at: closed_at,
		Merged_at: merged_at,
	}
	triggerReactions(appletId, output)
}
