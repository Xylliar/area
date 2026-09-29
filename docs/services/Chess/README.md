### Service Documentation - Chess Tracker

## Links

- [Actions](#actions)
  - [Get Player Stats](#get-player-stats)

- [Health Check](#health-check)

### Actions

#### Get Player Stats
- **Type**: Action
- **Endpoint**: `POST /chess-tracker/get-stats`
- **Parameters**:
  - `playername`: The name of the player to fetch stats for.
  - `gamemode`: The game mode to check the rating for (e.g., `chess_rapid`, `chess_bullet`).
  - `rating`: The rating value to compare against the player's current rating.
- **Returns**: JSON response with the status of the operation and the updated state.
- **Description**: This action fetches the player's stats from the Chess.com API and compares the current rating with the provided rating value. If the current rating is higher, it updates the state and returns a triggered status.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /chess-tracker/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Chess Tracker service.
