### Service Documentation - Time

## Links

- [Actions](#actions)
  - [Check Trigger](#check-trigger)
- [Health Check](#health-check)

### Actions

#### Check Trigger
- **Type**: Action
- **Endpoint**: `POST /time/check_trigger`
- **Parameters**:
  - `hour`: The time of day to wait for, formatted `HH:MM` (Europe/Paris time).
  - `state`: The state of the action, holding the moment of the last trigger.
- **Returns**: JSON response with:
  - `triggered`: Whether the given time was reached since the last trigger.
  - `state`: The updated state of the action.
- **Description**: Triggers once a day, as soon as the given time of day is reached.

#### Health Check
- **Type**: Endpoint
- **Endpoint**: `GET /time/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Time service.
