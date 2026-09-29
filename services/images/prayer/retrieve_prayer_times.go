package main

import (
	"encoding/json"
	"net/http"
	"fmt"
	"io"
)

type PrayerTimes struct {
	Fajr    string `json:"Fajr"`
	Dhuhr   string `json:"Dhuhr"`
	Asr     string `json:"Asr"`
	Maghrib string `json:"Maghrib"`
	Isha    string `json:"Isha"`
}

type SimplifiedPrayerResponse struct {
	Data struct {
		Timings PrayerTimes `json:"timings"`
	} `json:"data"`
}

func retrievePrayerTimes() (PrayerTimes, error) {
	url := "http://api.aladhan.com/v1/timings?latitude=48.8566&longitude=2.3522&method=2"
	resp, err := http.Get(url)
	if err != nil {
		return PrayerTimes{}, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return PrayerTimes{}, fmt.Errorf("received status code %d", resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return PrayerTimes{}, err
	}
	var prayerResponse SimplifiedPrayerResponse
	err = json.Unmarshal(body, &prayerResponse)
	if err != nil {
		return PrayerTimes{}, err
	}
	return prayerResponse.Data.Timings, nil
}