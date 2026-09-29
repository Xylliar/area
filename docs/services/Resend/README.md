### Service Documentation - Resend Email Provider

## Links

- [Actions](#actions)
  - [Send Email](#send-email)
  - [Health Check](#health-check)

- [Reactions](#reactions)
  - TODO

### Actions

#### Send Email
- **Type**: Action
- **Endpoint**: `POST /resend/send`
- **Parameters**:
  - `to`: The recipient's email address
  - `subject`: The email subject line
  - `body`: The HTML content of the email
  - `state`: (Optional) Previous state object
- **Returns**: JSON response containing:
  - `triggered`: Boolean indicating success
  - `state`: Updated state object containing `last_email`
  - `message`: Status message
- **Description**: Sends an HTML email to the specified recipient using the Resend API.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /resend/health`
- **Parameters**: None
- **Returns**: JSON response with service status
- **Description**: Simple health check endpoint to verify service availability.

### Reactions