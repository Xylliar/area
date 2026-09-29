### Service Documentation - Binance Provider

## Links

- [Actions](#actions)
  - [Check Decrease Price of a Coin](#check-decrease-price-of-a-coin)
  - [Check Increase Price of a Coin](#check-increase-price-of-a-coin)
  - [Health Check](#health-check)

### Actions

#### Check Decrease Price of a Coin
- **Type**: Action
- **Endpoint**: `POST /binance/checkDecrease`
- **Parameters**:
  - `symbol`: The symbol of the coin to check (e.g., "BTC").
  - `pourcentage`: The percentage decrease to check against.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint checks if the price of the specified coin has decreased by the given percentage.
- **Binance API Endpoint**: `GET https://api.binance.com/api/v3/avgPrice`

#### Check Increase Price of a Coin
- **Type**: Action
- **Endpoint**: `POST /binance/checkIncrease`
- **Parameters**:
  - `symbol`: The symbol of the coin to check (e.g., "BTC").
  - `pourcentage`: The percentage increase to check against.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint checks if the price of the specified coin has increased by the given percentage.
- **Binance API Endpoint**: `GET https://api.binance.com/api/v3/avgPrice`

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /binance/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Binance provider service.
