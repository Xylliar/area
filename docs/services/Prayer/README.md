### Prayer Provider Documentation

#### Actions

##### Prayer Action
- **Type**: Action
- **Endpoint**: `POST /prayer/prayer_action`
- **Parameters**:
  - `state`: A map containing the state of the action.
  - `prayer`: The name of the prayer to check for.
- **Returns**: JSON response with the following fields:
  - `triggered`: A boolean indicating whether the specified prayer has occurred.
  - `state`: The updated state of the action.
- **Description**: This action checks whether the specified prayer has occurred for the current day. If the prayer has occurred and has not been triggered before, it returns `triggered: true` and updates the state. Otherwise, it returns `triggered: false`.

##### Next Prayer Action
- **Type**: Action
- **Endpoint**: `POST /prayer/next_prayer_action`
- **Parameters**:
  - `state`: A map containing the state of the action.
- **Returns**: JSON response with the following fields:
  - `triggered`: A boolean indicating whether any prayers have occurred since the last time the action was triggered.
  - `state`: The updated state of the action.
  - `prayer`: (Optional) The name of the next prayer that has occurred.
- **Description**: This action checks for the next prayer that has occurred since the last time the action was triggered. It returns `triggered: true` and the name of the next prayer if a prayer has occurred. Otherwise, it returns `triggered: false`.

#### Other Endpoints

##### Health Check
- **Type**: Endpoint
- **Endpoint**: `GET /prayer/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint is used for health checks to determine the status of the service.