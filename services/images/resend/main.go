package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

const resendAPIURL = "https://api.resend.com/emails"

type EmailRequest struct {
	From    string `json:"from"`
	To      string `json:"to"`
	Subject string `json:"subject"`
	Html    string `json:"html"`
}

type TriggerRequest struct {
	To      string            `json:"to"`
	Subject string            `json:"subject"`
	Body    string            `json:"body"`
}

func sendEmail(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req TriggerRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	apiKey := os.Getenv("API_KEY")
	if apiKey == "" {
		http.Error(w, "Resend API key not set", http.StatusInternalServerError)
		return
	}

	from := os.Getenv("RESEND_FROM")
	if from == "" {
		from = "AREA <onboarding@resend.dev>"
	}

	email := EmailRequest{
		From:    from,
		To:      req.To,
		Subject: req.Subject,
		Html:    req.Body,
	}

	jsonData, err := json.Marshal(email)
	if err != nil {
		http.Error(w, "Error creating email request", http.StatusInternalServerError)
		return
	}

	client := &http.Client{}
	request, err := http.NewRequest("POST", resendAPIURL, bytes.NewBuffer(jsonData))
	if err != nil {
		http.Error(w, "Error creating request", http.StatusInternalServerError)
		return
	}

	request.Header.Set("Authorization", "Bearer "+apiKey)
	request.Header.Set("Content-Type", "application/json")

	resp, err := client.Do(request)
	if err != nil {
		http.Error(w, "Error sending email", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		http.Error(w, "Failed to send email", resp.StatusCode)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"message": "Email sent successfully",
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/resend/send", sendEmail)
	http.HandleFunc("/resend/health", healthHandler)
	log.Println("Server starting on :8000...")
	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatal(err)
	}
}