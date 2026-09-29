package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"github.com/google/go-github/v66/github"
	"golang.org/x/oauth2"
)

type CreateFileReactionInput struct {
	Token string `json:"token"`
	Owner string `json:"owner"`
	Repo  string `json:"repository"`
	Branch string `json:"branch"`
	Message string `json:"message"`
	Filepath string `json:"filepath"`
	Content  string `json:"content"`
}

func createFileReaction(w http.ResponseWriter, r *http.Request) {
	var action_input CreateFileReactionInput
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
	fileRequest := &github.RepositoryContentFileOptions{
		Message: github.String(action_input.Message),
		Content: []byte(action_input.Content),
		Branch:  github.String(action_input.Branch),
	}
	_, _, err = client.Repositories.CreateFile(ctx, action_input.Owner, action_input.Repo, action_input.Filepath, fileRequest)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating file: %s", err.Error()), http.StatusBadRequest)
		return
	}
}
