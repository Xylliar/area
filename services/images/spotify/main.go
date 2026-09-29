package main

import (
	"fmt"
	"net/http"
)

var spotifyUrl = "https://api.spotify.com/v1/me/"

type SpotifyUser struct {
	Token        string `json:"token"`
	RefreshToken string `json:"refresh_token"`
	Uri 		 string `json:"uri"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
	http.HandleFunc("/spotify/nextplay", PlayNext)
	http.HandleFunc("/spotify/previousplay", PlayPrevious)
	http.HandleFunc("/spotify/pause", Pause)
    http.HandleFunc("/spotify/play", Play)
	http.HandleFunc("/spotify/start", Start)
    http.HandleFunc("/spotify/repeat", Repeat)
    http.HandleFunc("/spotify/shuffle", TogglePlaybackSuffle)
    http.HandleFunc("/spotify/add", AddItemToQueue)

    http.HandleFunc("/spotify/check-new-podcasts", checkShowsHandler)
	http.HandleFunc("/spotify/check-new-albums", checkAlbumsHandler)
	http.HandleFunc("/spotify/check-new-playlists", checkPlaylistsHandler)
	http.HandleFunc("/spotify/check-new-audiobooks", checkAudiobooksHandler)

	http.HandleFunc("/spotify/health", healthHandler)

	http.ListenAndServe(":8000", nil)
}
