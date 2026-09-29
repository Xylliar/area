package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"golang.org/x/oauth2"
)

func getDeviceID(accessToken string) (string, error) {

	token := &oauth2.Token{AccessToken: accessToken}
	tokenSource := oauth2.StaticTokenSource(token)
	client := oauth2.NewClient(context.Background(), tokenSource)

	req, err := http.NewRequest("GET", spotifyUrl + "player/devices", nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("Authorization", "Bearer " + accessToken)
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Println(resp)
		return "", fmt.Errorf("access forbidden: %v", resp.Status)
	}

	var result struct {
		Devices []struct {
			ID string `json:"id"`
		} `json:"devices"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

	if len(result.Devices) == 0 {
		return "", fmt.Errorf("no devices found")
	}

	return result.Devices[0].ID, nil
}
