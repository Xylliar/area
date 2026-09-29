package main

import (
	"os"
	"encoding/json"
	"net/http"
	"github.com/twilio/twilio-go"
	twilioApi "github.com/twilio/twilio-go/rest/api/v2010"
)

type SendSmsReactionInput struct {
	PhoneNumber string `json:"phone_number"`
	Content     string `json:"content"`
}

func sendSmsReaction(w http.ResponseWriter, r *http.Request) {
	var input SendSmsReactionInput
	err := json.NewDecoder(r.Body).Decode(&input)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	accountSid := os.Getenv("TWILIO_ACCOUNT_SID")
	authToken := os.Getenv("API_KEY")
	fromNumber := os.Getenv("TWILIO_PHONE_NUMBER")
	if accountSid == "" || authToken == "" || fromNumber == "" {
		http.Error(w, "Twilio is not configured: set TWILIO_ACCOUNT_SID, API_KEY and TWILIO_PHONE_NUMBER", http.StatusServiceUnavailable)
		return
	}
	client := twilio.NewRestClientWithParams(twilio.ClientParams{
		Username: accountSid,
		Password: authToken,
	})
	params := &twilioApi.CreateMessageParams{}
	params.SetTo(input.PhoneNumber)
	params.SetFrom(fromNumber)
	params.SetBody(input.Content)
	_, err = client.Api.CreateMessage(params)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
