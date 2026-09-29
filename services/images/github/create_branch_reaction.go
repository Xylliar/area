package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"github.com/google/go-github/v66/github"
	"golang.org/x/oauth2"
)

type CreateBranchReactionInput struct {
	Token       string `json:"token"`
	Owner       string `json:"owner"`
	Repo        string `json:"repository"`
	NewBranch   string `json:"new_branch"`
	BaseBranch  string `json:"base_branch"`
}

func createBranchReaction(w http.ResponseWriter, r *http.Request) {
	var input CreateBranchReactionInput
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
	baseBranchRef, _, err := client.Git.GetRef(ctx, input.Owner, input.Repo, "refs/heads/"+input.BaseBranch)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting base branch: %s", err.Error()), http.StatusBadRequest)
		return
	}
	newBranchRef := &github.Reference{
		Ref:    github.String("refs/heads/" + input.NewBranch),
		Object: &github.GitObject{SHA: baseBranchRef.Object.SHA},
	}
	_, _, err = client.Git.CreateRef(ctx, input.Owner, input.Repo, newBranchRef)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error creating branch: %s", err.Error()), http.StatusBadRequest)
		return
	}
}
