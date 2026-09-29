# Service Documentation - Spotify API Provider

## Links

- [Actions](#actions)
 - [Check for New Podcasts](#check-for-new-podcasts)
  - [Check for New Albums](#check-for-new-albums)

- [Reactions](#reactions)
  - [Play Next Track](#play-next-track)
  - [Play Previous Track](#play-previous-track)
  - [Pause Playback](#pause-playback)
  - [Start Playback](#start-playback)
  - [Repeat Track](#repeat-track)
  - [Toggle Shuffle](#toggle-shuffle)
  - [Add Item to Queue](#add-item-to-queue)

- [Health Check](#health-check)
  - [Health Check](#health-check-1)

## Actions

### Check for New Podcasts
- **Type**: Action
- **Endpoint**: `POST /spotify/check-new-podcasts`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
  - `state`: A map of the previous state for comparison (optional).
- **Returns**: JSON response indicating new podcasts if detected.
- **Description**: Checks for new podcast shows in the user’s subscriptions.

### Check for New Albums
- **Type**: Action
- **Endpoint**: `POST /spotify/check-new-albums`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
  - `state`: A map of the previous state for comparison (optional).
- **Returns**: JSON response indicating new albums if detected.
- **Description**: Checks for new album releases in the user’s followed artists.


## Reactions

### Play Next Track
- **Type**: Reaction
- **Endpoint**: `POST /spotify/nextplay`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Skips to the next track in the currently active playback.

### Play Previous Track
- **Type**: Reaction
- **Endpoint**: `POST /spotify/previousplay`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Returns to the previous track in the currently active playback.

### Play Playback
- **Type** Reaction
- **Endpoint**: `PUT /spotify/play`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Plays the playback on the current active device.

### Pause Playback
- **Type**: Reaction
- **Endpoint**: `PUT /spotify/pause`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Pauses the playback on the current active device.

### Start Playback
- **Type**: Reaction
- **Endpoint**: `PUT /spotify/start`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Starts playback from the beginning on the active device.

### Repeat Track
- **Type**: Reaction
- **Endpoint**: `PUT /spotify/repeat`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Sets the current playback to repeat the currently playing track.

### Toggle Shuffle
- **Type**: Reaction
- **Endpoint**: `PUT /spotify/shuffle`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
- **Returns**: JSON response indicating success or failure.
- **Description**: Toggles shuffle mode for the current playback.

### Add Item to Queue
- **Type**: Reaction
- **Endpoint**: `POST /spotify/add`
- **Parameters**:
  - `token`: The OAuth2 token for the Spotify API.
  - `uri`: The Spotify URI of the item to add to the playback queue.
- **Returns**: JSON response indicating success or failure.
- **Description**: Adds a track to the end of the current playback queue.

## Health Check

### Health Check
- **Type**: Action
- **Endpoint**: `GET /spotify/health`
- **Returns**: JSON response with `{"status": "ok"}`.
- **Description**: Checks if the service is up and running.
