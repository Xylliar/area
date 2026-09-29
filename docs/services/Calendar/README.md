### Service Documentation - Calendar Tracker

## Links

- [Actions](#actions)
  - [Subscribe Calendar](#subscribe-calendar)
  - [Subscribe Calendar Name](#subscribe-calendar-name)

- [Reactions](#reactions)
  - [Add Event](#add-event)

- [Health Check](#health-check)

### Actions

#### Subscribe Calendar
- **Type**: Action
- **Endpoint**: `POST /calendar/check-new-event`
- **Parameters**:
  - `token`: The OAuth2 access token.
  - `state`: The current state of the calendar events.
- **Returns**: JSON response with the status of the operation and the updated state.
- **Description**: This action checks for new events in the user's calendar and updates the state if new events are found.

#### Subscribe Calendar Name
- **Type**: Action
- **Endpoint**: `POST /calendar/check-new-event-name`
- **Parameters**:
  - `token`: The OAuth2 access token.
  - `state`: The current state of the calendar events.
  - `keyword`: The keyword to search for in the event titles, descriptions, or locations.
- **Returns**: JSON response with the status of the operation, the updated state, and the names of the matched events.
- **Description**: This action checks for new events in the user's calendar that match the provided keyword and updates the state if new events are found.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /calendar/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Calendar Tracker service.

### Reactions

#### Add Event
- **Type**: Action
- **Endpoint**: `POST /calendar/add-event`
- **Parameters**:
  - `token`: The OAuth2 access token.
  - `description`: The description of the event.
  - `time-UTC`: The start time of the event in UTC format (RFC3339).
- **Returns**: JSON response with the status of the operation.
- **Description**: This action adds an event to the user's calendar using the provided OAuth2 access token, description, and start time.
