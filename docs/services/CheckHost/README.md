### Service Documentation - CheckHost Service

## Links

- [Actions](#actions)
  - [Check Ping](#check-ping)
  - [Check TCP](#check-tcp)
  - [Health Check](#health-check)

- [Reactions](#reactions)

### Actions

#### Check Ping
- **Type**: Action
- **Endpoint**: `POST /checkhost/ping`
- **Parameters**:
  - `host`: Target hostname or IP address
  - `max_ping_time`: (Optional) Maximum acceptable ping time in seconds
- **Returns**: JSON response containing:
  - `triggered`: Boolean indicating if threshold was exceeded
  - `message`: Status or error message
  - `ping_time`: Time taken for ping in seconds
- **Description**: Checks the ping response time to a specified host and optionally triggers if it exceeds a threshold.

#### Check TCP
- **Type**: Action
- **Endpoint**: `POST /checkhost/tcp`
- **Parameters**:
  - `host`: Target hostname or IP address
  - `max_tcp_time`: (Optional) Maximum acceptable TCP connection time in seconds
- **Returns**: JSON response containing:
  - `triggered`: Boolean indicating if threshold was exceeded
  - `message`: Status or error message
  - `tcp_time`: Connection time in seconds
  - `address`: Connected address
- **Description**: Tests TCP connectivity to a specified host and optionally triggers if connection time exceeds a threshold.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /checkhost/health`
- **Parameters**: None
- **Returns**: JSON response with service status
- **Description**: Simple health check endpoint to verify service availability.

### Reactions
No reactions are currently implemented for this service.