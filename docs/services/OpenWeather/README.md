### Service Documentation - OpenWeather Provider

## Links

- [Actions](#actions)
  - [Check Weather Condition](#check-weather-condition)
  - [Check Sunset](#check-sunset)
  - [Check Sunrise](#check-sunrise)
  - [Health Check](#health-check)

### Actions

#### Check Weather Condition
- **Type**: Action
- **Endpoint**: `POST /openweather/check_weather`
- **Parameters**:
  - `condition`: The weather condition to check.
  - `description`: Description of the action.
  - `city_name`: The name of the city to check the weather for.
  - `state`: The current state of the weather condition.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action is triggered when the weather conditions are right.

#### Check Sunset
- **Type**: Action
- **Endpoint**: `POST /openweather/check_sunset`
- **Parameters**:
  - `condition`: The weather condition to check.
  - `description`: Description of the action.
  - `city_name`: The name of the city to check the weather for.
  - `state`: The current state of the weather condition.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action triggers every day at sunset.

#### Check Sunrise
- **Type**: Action
- **Endpoint**: `POST /openweather/check_sunrise`
- **Parameters**:
  - `condition`: The weather condition to check.
  - `description`: Description of the action.
  - `city_name`: The name of the city to check the weather for.
  - `state`: The current state of the weather condition.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action triggers every day at sunrise.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /openweather/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the OpenWeather service.
