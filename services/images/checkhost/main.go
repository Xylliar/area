package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

const (
	checkHostBaseURL = "https://check-host.net"
	checkPingPath   = "/check-ping"
	checkTCPPath    = "/check-tcp"
	checkResultPath = "/check-result"
)

type CheckHostResponse struct {
	OK        int                 `json:"ok"`
	RequestID string             `json:"request_id"`
	Nodes     map[string][]string `json:"nodes"`
}

type PingResultResponse map[string][][]PingAttempt

type PingAttempt interface{}

type TCPResultResponse map[string][]TCPResult

type TCPResult struct {
	Time    float64 `json:"time,omitempty"`
	Address string  `json:"address,omitempty"`
	Error   string  `json:"error,omitempty"`
}

type TriggerRequest struct {
    Host        string  `json:"host"`
    MaxPingTime float64 `json:"max_ping_time,omitempty"`
    MaxTCPTime  float64 `json:"max_tcp_time,omitempty"`
}

func getHostStatus(host string, w http.ResponseWriter) (float64, error) {
	url := fmt.Sprintf("%s%s?host=%s&max_nodes=1", checkHostBaseURL, checkPingPath, host)
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		http.Error(w, "error with request", http.StatusInternalServerError)
		return 0, err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, "error executing request", http.StatusInternalServerError)
		return 0, err
	}
	defer resp.Body.Close()
	var initResult CheckHostResponse
	if err := json.NewDecoder(resp.Body).Decode(&initResult); err != nil {
		http.Error(w, "Invalid response from check service", http.StatusInternalServerError)
		return 0, err
	}

	time.Sleep(2 * time.Second)
	checkURL := fmt.Sprintf("%s%s/%s", checkHostBaseURL, checkResultPath, initResult.RequestID)
	req, _ = http.NewRequest("GET", checkURL, nil)
	req.Header.Set("Accept", "application/json")
	resp, err = client.Do(req)
	if err != nil {
		http.Error(w, "error getting results", http.StatusInternalServerError)
		return 0, err
	}
	defer resp.Body.Close()
	var pingResult PingResultResponse
	if err := json.NewDecoder(resp.Body).Decode(&pingResult); err != nil {
		return 0, err
	}

	for _, attempts := range pingResult {
		if len(attempts) == 0 {
			continue
		}
        for _, attempt := range attempts[0] {
			pingAttempt, ok := attempt.([]interface{})
			if !ok || len(pingAttempt) < 2 {
				continue
			}
			status, ok1 := pingAttempt[0].(string)
			pingTime, ok2 := pingAttempt[1].(float64)
			if ok1 && ok2 && status == "OK" {
				return pingTime, nil
			}
		}
	}
	return 0, fmt.Errorf("host unreachable")
}

func pingHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    if r.Method != http.MethodPost {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }

    var req TriggerRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    pingTime, err := getHostStatus(req.Host, w)
    if err != nil {
        response := map[string]interface{}{
            "triggered": true,
            "message":  fmt.Sprintf("Host unreachable: %v", err),
        }
        json.NewEncoder(w).Encode(response)
        return
    }

    triggered := false
    message := "Host reachable"

    if req.MaxPingTime > 0 && pingTime > req.MaxPingTime {
        triggered = true
        message = fmt.Sprintf("Ping time %.3fs exceeds threshold %.3fs", pingTime, req.MaxPingTime)
    }

    response := map[string]interface{}{
        "triggered": triggered,
        "message":  message,
        "ping_time": pingTime,
    }
    if err := json.NewEncoder(w).Encode(response); err != nil {
        log.Printf("Error encoding response: %v", err)
    }
}

func getTCPStatus(host string, w http.ResponseWriter) (*TCPResult, error) {
	url := fmt.Sprintf("%s%s?host=%s&max_nodes=1", checkHostBaseURL, checkTCPPath, host)
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var initResult CheckHostResponse
	if err := json.NewDecoder(resp.Body).Decode(&initResult); err != nil {
		return nil, err
	}

	time.Sleep(2 * time.Second)
	checkURL := fmt.Sprintf("%s%s/%s", checkHostBaseURL, checkResultPath, initResult.RequestID)
	req, _ = http.NewRequest("GET", checkURL, nil)
	req.Header.Set("Accept", "application/json")
	resp, err = client.Do(req)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()
	var tcpResult TCPResultResponse
	if err := json.NewDecoder(resp.Body).Decode(&tcpResult); err != nil {
		return nil, err
	}
	for _, results := range tcpResult {
		if len(results) > 0 {
			return &results[0], nil
		}
	}
	return nil, fmt.Errorf("TCP check failed")
}

func tcpHandler(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    if r.Method != http.MethodPost {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }
    
    var req TriggerRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    result, err := getTCPStatus(req.Host, w)
    if err != nil {
        response := map[string]interface{}{
            "triggered": true,
            "message":  fmt.Sprintf("Connection failed: %v", err),
        }
        json.NewEncoder(w).Encode(response)
        return
    }

    if result == nil {
        response := map[string]interface{}{
            "triggered": true,
            "message":  "Connection failed: No response from server",
        }
        json.NewEncoder(w).Encode(response)
        return
    }

    if result.Error != "" {
        response := map[string]interface{}{
            "triggered": true,
            "message":  fmt.Sprintf("Connection failed: %s", result.Error),
        }
        json.NewEncoder(w).Encode(response)
        return
    }

    triggered := false
    message := "Connection successful"

    if req.MaxTCPTime > 0 && result.Time > req.MaxTCPTime {
        triggered = true
        message = fmt.Sprintf("TCP connection time %.3fs exceeds threshold %.3fs", result.Time, req.MaxTCPTime)
    }

    response := map[string]interface{}{
        "triggered": triggered,
        "message":  message,
        "tcp_time": result.Time,
        "address":  result.Address,
    }
    if err := json.NewEncoder(w).Encode(response); err != nil {
        log.Printf("Error encoding response: %v", err)
    }
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/checkhost/ping", pingHandler)
	http.HandleFunc("/checkhost/tcp", tcpHandler)
	http.HandleFunc("/checkhost/health", healthHandler)
	log.Println("Server starting on :8000...")
	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatal(err)
	}
}
