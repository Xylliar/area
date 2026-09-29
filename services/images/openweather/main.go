//
// EPITECH PROJECT, 2024
// area
// File description:
// main
//

package main

import (
	"encoding/json"
	"fmt"
	"time"
	"net/http"
	"io"
	"strings"
	"os"
)

type TriggerRequest struct {
	Condition		string 		`json:"condition"`
	Description 	string 		`json:"description"`
	CityName string            `json:"city_name"`
	State     map[string]string `json:"state"`
}

type WeatherData struct {
	Main 	string `json:"main"`
	Desc 	string `json:"description"`
}

type MeteoData struct {
	Weather []WeatherData 				`json:"weather"`
	Sys struct{
		Sunrise	int	`json:"sunrise"`
		Sunset	int	`json:"sunset"`
	} `json:"sys"`
}

type GeoData struct {
	Lat          string  `json:"lat"`
	Lon          string  `json:"lon"`
}

type GeoDataArray struct {
	Data []GeoData `json:"data"`
}

var dataGeoUrl = "https://nominatim.openstreetmap.org/search?format=json&limit=1&q="

func getBodyRequest(url string, w http.ResponseWriter) ([]byte, error) {
	req_get, err := http.NewRequest("GET", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return nil, nil
	}
	// Nominatim rejects the default Go user agent with a 403.
	req_get.Header.Set("User-Agent", "area-openweather/1.0")
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return nil, nil
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from Meteo Concept API", resp.StatusCode)
		return nil, nil
	}
	return io.ReadAll(resp.Body)
}

func getWeatherInfo(req TriggerRequest,w http.ResponseWriter) []byte {
	var geodataArray []GeoData

	url := dataGeoUrl + req.CityName
	body, err := getBodyRequest(url, w)
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return nil
	}
	err = json.Unmarshal(body, &geodataArray)
	if err != nil {
		http.Error(w, "error with json geo data", http.StatusInternalServerError)
		return nil
	}
	if len(geodataArray) == 0 {
		http.Error(w, "no geo data found", http.StatusNotFound)
		return nil
	}
	geodata := geodataArray[0]
	urlWeather := "https://api.openweathermap.org/data/2.5/weather?" + "lon=" + geodata.Lon + "&lat=" + geodata.Lat + "&appid=" + os.Getenv("WEATHER_API")
	body, err = getBodyRequest(urlWeather, w)
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return nil
	}
	return body
}

func checkWeather(w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var weatherdata MeteoData

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	body := getWeatherInfo(req, w)
	err = json.Unmarshal(body, &weatherdata)
	if err != nil {
		http.Error(w, "error with json weather data", http.StatusInternalServerError)
		return
	}
	if (strings.Contains(req.State["weather"], strings.ToLower(req.Condition))) {
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	if (strings.Contains(strings.ToLower(req.Condition), strings.ToLower(weatherdata.Weather[0].Main))) {
		req.State["weather"] = strings.ToLower(weatherdata.Weather[0].Main)
		json.NewEncoder(w).Encode(map[string]interface{} {
			"description": weatherdata.Weather[0].Desc,
			"triggered": true,
			"state":     req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{}{
		"triggered": false,
		"state":     req.State,
	})
}

func checkSunrise (w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var weatherdata MeteoData

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	body := getWeatherInfo(req, w)
	err = json.Unmarshal(body, &weatherdata)
	if err != nil {
		http.Error(w, "error with json weather data", http.StatusInternalServerError)
		return
	}
	timenow := time.Now().Unix()
	if (req.State["sunset"] == "" && req.State["sunrise"] == "") {
		if (timenow >= int64(weatherdata.Sys.Sunrise) && timenow < int64(weatherdata.Sys.Sunset)) {
			req.State["sunset"] = "false"
			req.State["sunrise"] = "true"
		} else {
			req.State["sunset"] = "true"
			req.State["sunrise"] = "false"
		}
	}
	if (timenow > int64(weatherdata.Sys.Sunrise) && req.State["sunset"] == "true" && req.State["sunrise"] == "false") {
		req.State["sunset"] = "false"
		req.State["sunrise"] = "true"
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": true,
			"state":     req.State,
		})
		return
	} else if (timenow > int64(weatherdata.Sys.Sunset) && req.State["sunset"] == "false" && req.State["sunrise"] == "true") {
		req.State["sunset"] = "true"
		req.State["sunrise"] = "false"
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": false,
			"state":     req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{} {
		"triggered": false,
		"state":     req.State,
	})
}

func checkSunset (w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var weatherdata MeteoData

	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	body := getWeatherInfo(req, w)
	err = json.Unmarshal(body, &weatherdata)
	if err != nil {
		http.Error(w, "error with json weather data", http.StatusInternalServerError)
		return
	}
	timenow := time.Now().Unix()
	if (req.State["sunset"] == "" && req.State["sunrise"] == "") {
		if (timenow >= int64(weatherdata.Sys.Sunrise) && timenow < int64(weatherdata.Sys.Sunset)) {
			req.State["sunset"] = "false"
			req.State["sunrise"] = "true"
		} else {
			req.State["sunset"] = "true"
			req.State["sunrise"] = "false"
		}
	}
	if (timenow > int64(weatherdata.Sys.Sunrise) && req.State["sunset"] == "true" && req.State["sunrise"] == "false") {
		req.State["sunset"] = "false"
		req.State["sunrise"] = "true"
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": false,
			"state":     req.State,
		})
		return
	} else if (timenow > int64(weatherdata.Sys.Sunset) && req.State["sunset"] == "false" && req.State["sunrise"] == "true") {
		req.State["sunset"] = "true"
		req.State["sunrise"] = "false"
		json.NewEncoder(w).Encode(map[string]interface{} {
			"triggered": true,
			"state":     req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{} {
		"triggered": false,
		"state":     req.State,
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/openweather/check_weather", checkWeather)
	http.HandleFunc("/openweather/check_sunrise", checkSunrise)
	http.HandleFunc("/openweather/check_sunset", checkSunset)
	http.HandleFunc("/openweather/health", healthHandler)
	http.ListenAndServe(":8000", nil)
}
