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
	"io"
	"net/http"
	"strconv"
)

var crypoUrlBitcoin = "https://api.binance.com/api/v3/avgPrice?symbol="

type TriggerRequest struct {
	Symbol				string `json:"symbol"`
	Pourcentage			string  `json:"pourcentage"`
	State     			map[string]string `json:"state"`
}

type AvgPrice struct {
	Price 				string `json:"price"`
}

func getBodyRequest(url string, w http.ResponseWriter) ([]byte, error) {
	req_get, err := http.NewRequest("GET", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return nil, nil
	}
	client := &http.Client{}
	resp, err := client.Do(req_get)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return nil, nil
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		http.Error(w, "error from binance API", resp.StatusCode)
		return nil, nil
	}
	return io.ReadAll(resp.Body)
}

func checkPriceIncrease(w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var avgprice AvgPrice
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	url := crypoUrlBitcoin + req.Symbol + "USDT"
	body, err := getBodyRequest(url, w);
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &avgprice)
	if err != nil {
		http.Error(w, "error with json", http.StatusInternalServerError)
		return
	}
	if req.State["price"] == "" {
		req.State["price"] = avgprice.Price
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": 	false,
			"state":     	req.State,
		})
		return
	}
	y2, err1 := strconv.ParseFloat(req.State["price"], 64)
	y1, err2 := strconv.ParseFloat(avgprice.Price, 64)
	pourcentage, err3 := strconv.ParseFloat(req.Pourcentage, 64)
	increase := ((y1 - y2) / y1) * 100.0
	if (err1 != nil || err2 != nil ||err3 != nil) {
		http.Error(w, "error with arguments", http.StatusInternalServerError)
		return
	}
	if (increase > pourcentage) {
		req.State["price"] = avgprice.Price
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": true,
			"price": 	avgprice.Price,
			"state":  	req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{}{
		"triggered": false,
		"state":     req.State,
	})
}

func checkPriceDecrease(w http.ResponseWriter, r *http.Request) {
	var req TriggerRequest
	var avgprice AvgPrice
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}
	url := crypoUrlBitcoin + req.Symbol + "USDT"
	body, err := getBodyRequest(url, w);
	if err != nil {
		http.Error(w, "error response", http.StatusInternalServerError)
		return
	}
	err = json.Unmarshal(body, &avgprice)
	if err != nil {
		http.Error(w, "error with json", http.StatusInternalServerError)
		return
	}
	if req.State["price"] == "" {
		req.State["price"] = avgprice.Price
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": 	false,
			"state":     	req.State,
		})
		return
	}
	y2, err1 := strconv.ParseFloat(req.State["price"], 64)
	y1, err2 := strconv.ParseFloat(avgprice.Price, 64)
	pourcentage, err3 := strconv.ParseFloat(req.Pourcentage, 64)
	increase := ((y2 - y1) / y1) * 100.0
	if (err1 != nil || err2 != nil ||err3 != nil) {
		http.Error(w, "error with arguments", http.StatusInternalServerError)
		return
	}
	if (increase > pourcentage) {
		req.State["price"] = avgprice.Price
		json.NewEncoder(w).Encode(map[string]interface{}{
			"triggered": true,
			"price": 	avgprice.Price,
			"state":  	req.State,
		})
		return
	}
	json.NewEncoder(w).Encode(map[string]interface{}{
		"triggered": false,
		"state":     req.State,
	})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/binance/checkIncrease", checkPriceIncrease)
	http.HandleFunc("/binance/checkDecrease", checkPriceDecrease)
	http.HandleFunc("/binance/health", healthHandler)
	http.ListenAndServe(":8000", nil)
}
