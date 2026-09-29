### Service Documentation - Gmail Sender

## Links

- [Reactions](#reactions)
  - [Send Self Mail](#send-self-mail)
  - [Send Email](#send-email)
  
- [Health Check](#health-check)

### Reactions

#### Send Self Mail
- **Type**: Action
- **Endpoint**: `POST /gmail/send-selfmail`
- **Parameters**:
  - `token`: The OAuth2 access token.
  - `subject`: The subject of the email.
  - `body`: The body of the email.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action sends an email to the user's own email address using the provided OAuth2 access token, subject, and body.

#### Send Email
- **Type**: Action
- **Endpoint**: `POST /gmail/send-email`
- **Parameters**:
  - `token`: The OAuth2 access token.
  - `Email`: The recipient's email address.
  - `subject`: The subject of the email.
  - `body`: The body of the email.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action sends an email to the specified recipient's email address using the provided OAuth2 access token, subject, and body.

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /gmail/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the Gmail Sender service.
