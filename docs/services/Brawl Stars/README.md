### Service Documentation - Brawl Stars Provider

## Links

- [Actions](#actions)
  - [Check if highest trophies reached](#check-if-highest-trophies-reached)
  - [Check new maps](#check-new-maps)
  - [Health Check](#health-check)

### Actions

#### Check if highest trophies reached
- **Type**: Action
- **Endpoint**: `POST /brawlstar/check_trophies`
- **Parameters**:
  - `playertag`: The player tag to check the trophies for.
  - `state`: The current state of the player's trophies.
- **Returns**: JSON response indicating whether the highest trophies have been reached and the updated state.
- **Description**: This action checks if the player has reached the highest trophies. If the highest trophies have been reached, it updates the state and triggers a reaction.
- **Brawl Stars API Endpoint**: `https://api.brawlstars.com/v1/events/players/`

#### Check new maps
- **Type**: Action
- **Endpoint**: `POST /brawlstar/check_map`
- **Parameters**:
  - `new_maps`: The new maps to check.
  - `state`: The current state of the maps.
- **Returns**: JSON response indicating whether there are new maps and the updated state.
- **Description**: This action checks if there are new maps in the rotation. If there are new maps, it updates the state and triggers a reaction.
- **Brawl Stars API Endpoint**: `https://api.brawlstars.com/v1/events/rotation`

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /brawlstar/health`
- **Parameters**: None
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Brawl Stars provider service.
