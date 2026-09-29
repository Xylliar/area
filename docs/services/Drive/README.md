### Service Documentation - Google Drive Provider

## Links

- [Actions](#actions)
  - [Save Content to Google Drive](#save-content-to-google-drive)
  - [Health Check](#health-check)

- [Reactions](#reactions)
  - TODO

### Actions

#### Save Content to Google Drive
- **Type**: Action
- **Endpoint**: `POST /google/drive/save`
- **Parameters**:
  - `token`: The OAuth2 token for Google Drive API.
  - `content`: The content to be saved to the file.
  - `filename`: The name of the file to save the content to.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint saves the provided content to a specified file in Google Drive. If the file does not exist, it will be created.
- **Google Drive API Endpoint**: `POST https://www.googleapis.com/upload/drive/v3/files?uploadType=media`

### Reactions