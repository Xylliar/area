package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"github.com/google/go-github/v66/github"
	"golang.org/x/oauth2"
)

type CreateIssueReactionInput struct {
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
	Title string `json:"title"`
	Body  string `json:"body"`
}

func createIssueReaction(w http.ResponseWriter, r *http.Request) {
	var action_input CreateIssueReactionInput
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

	issueRequest := &github.IssueRequest{
		Title: &action_input.Title,
		Body:  &action_input.Body,
	}
	_, _, err = client.Issues.Create(ctx, action_input.Owner, action_input.Repo, issueRequest)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating issue: %s", err.Error()), http.StatusBadRequest)
		return
	}
}
