package main

import (
    "context"
    "encoding/base64"
    "fmt"
    "log"
    "net/http"
    "encoding/json"
    "strings"

    "golang.org/x/oauth2"
    "google.golang.org/api/gmail/v1"
    "google.golang.org/api/option"
)

type GmailUser struct {
    Token string `json:"token"`
	SendEmail string `json:"Email"`
	Subject string `json:"subject"`
	Body string `json:"body"`
}

func sendSelfMailHandler(w http.ResponseWriter, r *http.Request) {
    var payload GmailUser
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" || payload.Subject == "" || payload.Body == "" {
        http.Error(w, "Missing required fields: token, email, subject, body", http.StatusBadRequest)
        return
    }

    ctx := context.Background()

    client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, "Unable to create client: "+err.Error(), http.StatusInternalServerError)
        return
    }

    srv, err := gmail.NewService(ctx, option.WithHTTPClient(client))
    if err != nil {
        http.Error(w, "Unable to retrieve Gmail client: "+err.Error(), http.StatusInternalServerError)
        return
    }

    userEmail, err := getUserEmail(srv)
    if err != nil {
        http.Error(w, "Unable to get user email: "+err.Error(), http.StatusInternalServerError)
        return
    }

    var message gmail.Message
    emailContent := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n%s", userEmail, userEmail, payload.Subject, payload.Body)
    message.Raw = base64.URLEncoding.EncodeToString([]byte(emailContent))
    message.Raw = strings.ReplaceAll(message.Raw, "/", "_")
    message.Raw = strings.ReplaceAll(message.Raw, "+", "-")
    message.Raw = strings.ReplaceAll(message.Raw, "=", "")

    _, err = srv.Users.Messages.Send("me", &message).Do()
    if err != nil {
        http.Error(w, "Unable to send email: "+err.Error(), http.StatusInternalServerError)
        return
    }

    fmt.Fprintln(w, "Email sent successfully!")
}

func sendEmailHandler(w http.ResponseWriter, r *http.Request) {
	var payload GmailUser
	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
		return
	}

	if payload.Token == "" || payload.SendEmail == "" || payload.Subject == "" || payload.Body == "" {
		http.Error(w, "Missing required fields: token, email, subject, body", http.StatusBadRequest)
		return
	}

	ctx := context.Background()

	client, err := getClient(payload.Token)
	if err != nil {
		http.Error(w, "Unable to create client: "+err.Error(), http.StatusInternalServerError)
		return
	}

	srv, err := gmail.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		http.Error(w, "Unable to retrieve Gmail client: "+err.Error(), http.StatusInternalServerError)
		return
	}

	userEmail, err := getUserEmail(srv)
    if err != nil {
        http.Error(w, "Unable to get user email: "+err.Error(), http.StatusInternalServerError)
        return
    }

	var message gmail.Message
	emailContent := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n%s", userEmail, payload.SendEmail, payload.Subject, payload.Body)
	message.Raw = base64.URLEncoding.EncodeToString([]byte(emailContent))
	message.Raw = strings.ReplaceAll(message.Raw, "/", "_")
	message.Raw = strings.ReplaceAll(message.Raw, "+", "-")
	message.Raw = strings.ReplaceAll(message.Raw, "=", "")

	_, err = srv.Users.Messages.Send("me", &message).Do()
	if err != nil {
		http.Error(w, "Unable to send email: "+err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Fprintln(w, "Email sent successfully!")
}

func getUserEmail(srv *gmail.Service) (string, error) {
    profile, err := srv.Users.GetProfile("me").Do()
    if err != nil {
        return "", err
    }
    return profile.EmailAddress, nil
}

func getClient(accessToken string) (*http.Client, error) {
    token := &oauth2.Token{AccessToken: accessToken}
    tokenSource := oauth2.StaticTokenSource(token)
    client := oauth2.NewClient(context.Background(), tokenSource)
    return client, nil
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/gmail/send-selfmail", sendSelfMailHandler)
	http.HandleFunc("/gmail/send-email", sendEmailHandler)
	http.HandleFunc("/gmail/health", healthHandler)

    log.Println("Server starting on :8000...")
    err := http.ListenAndServe(":8000", nil)
    if err != nil {
        log.Fatalf("Error starting server: %s", err)
    }
}
