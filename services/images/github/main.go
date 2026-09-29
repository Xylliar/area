package main

import (
	"fmt"
	"net/http"
	"github.com/gorilla/mux"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	r := mux.NewRouter()
	r.HandleFunc("/github/push_action/callback/{applet_id}", pushActionCallback)
	r.HandleFunc("/github/issue_action/callback/{applet_id}", issueActionCallback)
	r.HandleFunc("/github/pull_request_action/callback/{applet_id}", pullRequestActionCallback)
	r.HandleFunc("/github/create_branch_action/callback/{applet_id}", createBranchActionCallback)
	http.HandleFunc("/github/push_action/create_webhook", createPushActionWebhook)
	http.HandleFunc("/github/push_action/delete_webhook", deletePushActionWebhook)
	http.HandleFunc("/github/issue_action/create_webhook", createIssueActionWebhook)
	http.HandleFunc("/github/issue_action/delete_webhook", deleteIssueActionWebhook)
	http.HandleFunc("/github/pull_request_action/create_webhook", createPullRequestActionWebhook)
	http.HandleFunc("/github/pull_request_action/delete_webhook", deletePullRequestActionWebhook)
	http.HandleFunc("/github/create_branch_action/create_webhook", createCreateBranchActionWebhook)
	http.HandleFunc("/github/create_branch_action/delete_webhook", deleteCreateBranchActionWebhook)
	http.HandleFunc("/github/create_issue_reaction", createIssueReaction)
	http.HandleFunc("/github/create_file_reaction", createFileReaction)
	http.HandleFunc("/github/create_pull_request_reaction", createPullRequestReaction)
	http.HandleFunc("/github/create_branch_reaction", createBranchReaction)
	http.HandleFunc("/github/health", healthHandler)
	http.Handle("/", r)
	http.ListenAndServe(":8000", nil)
}
