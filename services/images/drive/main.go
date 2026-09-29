package main

import (
    "bytes"
    "encoding/json"
    "fmt"
    "io"
    "log"
    "net/http"

    "google.golang.org/api/drive/v3"
    "google.golang.org/api/option"
    "golang.org/x/oauth2"
    "context"
)

type GoogleDrivePayload struct {
    Token    string `json:"token"`
    Content  string `json:"content"`
    FileName string `json:"filename"`
}

func getClient(accessToken string) (*http.Client, error) {
    tok := &oauth2.Token{
        AccessToken: accessToken,
    }

    config := &oauth2.Config{
        Scopes: []string{drive.DriveFileScope},
    }
    return config.Client(context.Background(), tok), nil
}

func findOrCreateFile(srv *drive.Service, fileName string) (*drive.File, error) {
    query := fmt.Sprintf("name='%s' and trashed=false", fileName)
    fileList, err := srv.Files.List().Q(query).Fields("files(id, name)").Do()
    if err != nil {
        return nil, fmt.Errorf("failed to list files: %v", err)
    }

    if len(fileList.Files) > 0 {
        log.Printf("File '%s' found with ID: %s", fileName, fileList.Files[0].Id)
        return fileList.Files[0], nil
    }

    file := &drive.File{
        Name: fileName,
    }
    createdFile, err := srv.Files.Create(file).Do()
    if err != nil {
        return nil, fmt.Errorf("failed to create file: %v", err)
    }

    log.Printf("File '%s' created with ID: %s", fileName, createdFile.Id)
    return createdFile, nil
}

func appendToFile(srv *drive.Service, fileId string, content string) error {
    resp, err := srv.Files.Get(fileId).Download()
    if err != nil {
        return fmt.Errorf("failed to download file: %v", err)
    }
    defer resp.Body.Close()

    existingContent, err := io.ReadAll(resp.Body)
    if err != nil {
        return fmt.Errorf("failed to read existing content: %v", err)
    }

    newContent := string(existingContent) + content
    log.Printf("Appending content to file ID %s", fileId)

    updateReq := &drive.File{}
    updatedFile, err := srv.Files.Update(fileId, updateReq).Media(bytes.NewBufferString(newContent)).Do()
    if err != nil {
        return fmt.Errorf("failed to update file: %v", err)
    }

    log.Printf("File ID %s updated successfully", updatedFile.Id)
    return nil
}

func postGoogleDriveHandler(w http.ResponseWriter, r *http.Request) {
    var payload GoogleDrivePayload
    err := json.NewDecoder(r.Body).Decode(&payload)
    if err != nil {
        http.Error(w, fmt.Sprintf("Invalid request payload: %v", err), http.StatusBadRequest)
        return
    }

    if payload.Token == "" || payload.FileName == "" {
        http.Error(w, "Missing required fields: token and filename", http.StatusBadRequest)
        return
    }

    client, err := getClient(payload.Token)
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to get client: %v", err), http.StatusInternalServerError)
        return
    }

    srv, err := drive.NewService(r.Context(), option.WithHTTPClient(client))
    if err != nil {
        http.Error(w, fmt.Sprintf("Failed to create Drive service: %v", err), http.StatusInternalServerError)
        return
    }

    file, err := findOrCreateFile(srv, payload.FileName)
    if err != nil {
        http.Error(w, fmt.Sprintf("Error finding or creating file: %v", err), http.StatusInternalServerError)
        return
    }

    err = appendToFile(srv, file.Id, payload.Content)
    if err != nil {
        http.Error(w, fmt.Sprintf("Error appending to file: %v", err), http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status": "success"}`))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, `{"status": "ok"}`)
}

func main() {
    http.HandleFunc("/google/drive/save", postGoogleDriveHandler)
    http.HandleFunc("/google/drive/health", healthHandler)

    log.Println("Server starting on :8000...")
    err := http.ListenAndServe(":8000", nil)
    if err != nil {
        log.Fatalf("Error starting server: %s", err)
    }
}
