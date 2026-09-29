### Service Documentation - Christmas Service

## Links

- [Actions](#actions)
  - [Get Christmas Status](#get-christmas-status)
  - [Health Check](#health-check)

### Actions

#### Get Christmas Status
- **Type**: Action
- **Endpoint**: `GET /christmas/days`
- **Parameters**: None
- **Returns**: JSON response with:
  - `triggered`: Boolean indicating if it's Christmas day
  - `days`: Number of days until next Christmas
- **Description**: Returns whether it's currently Christmas and how many days remain until the next Christmas.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /christmas/health`
- **Parameters**: None
- **Returns**: JSON response with the status of the service
- **Description**: Simple health check endpoint to verify the service is running.