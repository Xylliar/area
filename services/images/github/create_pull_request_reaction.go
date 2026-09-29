package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"github.com/google/go-github/v66/github"
	"golang.org/x/oauth2"
)

type CreatePullRequestReactionInput struct {
	Token     string `json:"token"`
	Owner     string `json:"owner"`
	Repo      string `json:"repository"`
	Title     string `json:"title"`
	Body      string `json:"body"`
	Base      string `json:"base"`
	Head      string `json:"head"`
}

func createPullRequestReaction(w http.ResponseWriter, r *http.Request) {
	var input CreatePullRequestReactionInput
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: input.Token},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)
	pullRequest := &github.NewPullRequest{
		Title: &input.Title,
		Body:  &input.Body,
		Base:  &input.Base,
		Head:  &input.Head,
	}
	_, _, err = client.PullRequests.Create(ctx, input.Owner, input.Repo, pullRequest)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating pull request: %s", err.Error()), http.StatusBadRequest)
		return
	}
}
