### SMS Provider Documentation

#### Reactions

##### Send SMS Reaction
- **Type**: Reaction
- **Endpoint**: `POST /sms/send_sms_reaction`
- **Parameters**:
  - `phone_number`: The phone number to send the SMS to.
  - `content`: The content of the SMS message.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction sends an SMS message to the specified phone number with the provided content.

#### Other Endpoints

##### Health Check
- **Type**: Endpoint
- **Endpoint**: `GET /sms/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint is used for health checks to determine the status of the service.